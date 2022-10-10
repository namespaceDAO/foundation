// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import { Strings } from '@openzeppelin/contracts/utils/Strings.sol';
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./NounBank.sol";
import "./NounData.sol";
import "./shared.sol";

/*
TODO:
optional governance tax, optional card art changes?
*/

contract NounGame is Nounish, ERC721 {
    using Strings for uint;

    NounBank private _bank;
    NounData private _data;
    IERC20 private _cash;

    mapping(uint => uint) private _nounToCoin;
    mapping(uint => uint) private _coinToNoun;
    mapping(uint => uint) private _cashOnNoun;
    mapping(uint => uint) private _cashOnCoin;
    
    uint private _stakeCount;
    uint private _totalShares;
    uint private _minimumDuration = 1 days;
    
    mapping(uint => uint) private _claims;
    mapping(uint => uint) private _shares;
    mapping(uint => Note) private _notes;

    event Claim(
        address creator,
        address minter,
        uint coinId,
        uint nounId,
        uint coins
    );

    event Vote(
        address payer,
        address minter,
        uint coinId,
        uint nounId,
        uint found,
        uint coins
    );

    event Mint(
        address payer,
        address minter,
        uint coinId,
        uint nounId,
        uint found,
        uint coins
    );

    event Stake(
        uint id,
        uint idea,
        uint amount,
        uint expiresAt,
        uint startedAt
    );

    event Burn(
        uint id,
        uint idea,
        uint amount,
        uint endedAt
    );

    function bank() external view returns (NounBank) { 
        return _bank; 
    }

    function data() external view returns (NounData) {
        return _data;
    }

    function cash() external view returns (IERC20) {
        return _cash;
    }

    function nounToCoin(uint nounId) external view returns (uint coinId) {
        return _nounToCoin[nounId];
    }

    function coinToNoun(uint coinId) external view returns (uint nounId) {
        return _coinToNoun[coinId];
    }

    function cashOnNoun(uint nounId) external view returns (uint amount) {
        return _cashOnNoun[nounId];
    }
    
    function cashOnCoin(uint nounId) external view returns (uint amount) {
        return _cashOnCoin[nounId];
    }

    function stakeCount() external view returns (uint) {
        return _stakeCount;
    }

    function totalShares() external view returns (uint) {
        return _totalShares;
    }

    function minimumDuration() external view returns (uint) {
        return _minimumDuration;
    }

    function getShares(uint noteId) external view returns (uint) {
        return _shares[noteId];
    }

    function getNote(uint stakeId) public view returns (Note memory) {
        require(stakeId <= _stakeCount, "Note not found");
        return _notes[stakeId];
    }

    function calculateShares(uint day, uint amount) public view returns (uint) {
        uint last = _cashOnCoin[day - 1];
        uint ampl = 10;

        if (last == 0) {
            return amount;
        }

        if (last > amount * ampl) {
            return amount / ampl;
        }

        if (last < amount / ampl) {
            return amount * ampl;
        }

        return amount * amount / last;
    }
    
    function calculatePayout(uint noteId, uint timestamp) external view returns (uint, uint) {
        Note memory note = getNote(noteId);
        
        uint earnings = _calculateEarnings(noteId);
        uint penalty = _calculatePenalty(note, timestamp);

        return (earnings, penalty);
    }

    function _calculateEarnings(uint noteId) internal view returns (uint) {
        uint balance = _cash.balanceOf(address(this));
        uint earnings = balance * _shares[noteId] / _totalShares;
        return earnings;
    }

    function _calculatePenalty(Note memory note, uint timestamp) internal pure returns (uint) {
        if (timestamp > note.expiresAt + 2 weeks) {
            uint late = (timestamp - note.expiresAt - 2 weeks) / 1 days;
            return late * note.amount / 14;
        }

        return 0;
    }

    function tokenURI(uint noteId) public view virtual override returns (string memory) {
        Note memory note = getNote(noteId); 
        return string(_noteURI(note));
    }

    function tokenData(uint noteId) external view returns (string memory) {
        Note memory note = getNote(noteId); 
        return string(_noteJSON(note));
    }

    function _noteURI(Note memory note) internal view returns (bytes memory) {
        return abi.encodePacked(
            'data:application/json;base64,',
            Base64.encode(_noteJSON(note))
        );
    }

    function _noteJSON(Note memory note) internal view returns (bytes memory) {
        Noun memory noun = _data.getNoun(note.nounId); 
        return abi.encodePacked(
            '{',
                '"id":', note.id.toString(), ',',
                '"name":"FOUND ', noun.name, '",',
                '"description":"', noun.name, ' is FOUND.",',
                '"noun":[', _data.tokenData(note.nounId), '],',
                '"image":"', _data.tokenImage(note.nounId), '"',
            '}'
        );
    }

    function claim(
        address minter, 
        uint coinId, 
        uint amount
    ) external {
        uint nounId = _requireFoundNoun(coinId);
        address owner = _verifyClaim(nounId, coinId, amount);

        _claims[coinId] += amount;
        _bank.mint(minter, coinId, amount);
        
        emit Claim(
            owner,
            minter,
            coinId, 
            nounId,
            amount
        );
    }

    function _verifyClaim(
        uint nounId, 
        uint coinId, 
        uint amount
    ) internal view returns (address) {
        address owner = _data.ownerOf(nounId);

        require(
            msg.sender == owner, 
            "Caller is not the Noun owner"
        );

        uint claimed = _claims[coinId];
        uint minted = _bank.totalSupplyOf(coinId) - claimed;

        bool claimable = minted / 10 >= amount + claimed;
        require(claimable, "Claim too large");

        return owner;
    }
    
    function vote(
        address payer, 
        address minter, 
        uint nounId, 
        uint found
    ) external {
        uint minted = found * _bank.difficulty();
        uint coinId = _collectVote(nounId, minted);

        _cash.transferFrom(payer, address(this), found);
        _bank.mint(minter, coinId, minted);

        emit Vote(
            payer,
            minter, 
            coinId,
            nounId, 
            found,
            minted
        );
    }

    function _collectVote(uint nounId, uint amount) internal returns (uint) {
        uint coinId = _requireFreshNoun(nounId);
        uint minimum = _cashOnCoin[coinId] * 101 / 100;
        
        _cashOnNoun[nounId] += amount;
        
        if (_cashOnNoun[nounId] > minimum || minimum == 0) {
            _coinToNoun[coinId] = nounId;
            _nounToCoin[nounId] = coinId;
            _cashOnCoin[coinId] = _cashOnNoun[nounId];
        }

        return coinId;
    }

    function _requireFreshNoun(uint nounId) internal view returns (uint) {
        require(nounId <= _data.nounCount(), "Noun not found");
        
        uint coinId = _data.currentDay();
        uint existing = _nounToCoin[nounId];
        
        require(
            existing == 0 || existing == coinId, 
            "Noun has been minted"
        );
        
        return coinId;
    }

    function mint(
        address payer, 
        address minter, 
        uint coinId, 
        uint found
    ) external {
        uint nounId = _collectMint(coinId, found);
        uint minted = _bank.convertCoin(coinId, found);

        _cash.transferFrom(payer, address(this), found);
        _bank.mint(minter, coinId, minted);

        emit Mint(
            payer, 
            minter, 
            coinId, 
            nounId,
            found, 
            minted
        );
    }

    function _collectMint(uint coinId, uint amount) internal returns (uint) {
        uint nounId = _requireFoundNoun(coinId);
        
        require(amount > 0, "Must mint some Nouns");
        _cashOnNoun[nounId] += amount;

        return _coinToNoun[coinId];
    }

    function _requireFoundNoun(uint coinId) internal view returns (uint nounId) {
        require(
            coinId > 0 && coinId <= _data.currentDay(), 
            "Coin has not been minted"
        );

        return _coinToNoun[coinId];
    }

    // TODO: double check the params
    // TODO: transfer the found to the appropriate address
    function stake(address minter, NoteParams memory params) external {
        Note memory note = _createNote(params);

        _mint(minter, note.id);

        emit Stake(
            note.id, 
            note.nounId,
            note.amount,
            note.expiresAt,
            note.startedAt
        );
    }

    function _createNote(NoteParams memory params) internal returns (Note memory) {
        require(
            params.amount > 0, 
            "Note more than 0"
        );

        require(
            params.expiresAt > block.timestamp  + _minimumDuration, 
            "Must expire further in the future"
        );

        Note storage note = _notes[++_stakeCount];
        note.id = _stakeCount;
        note.nounId = params.nounId;
        note.amount = params.amount;
        note.expiresAt = params.expiresAt;
        note.startedAt = block.timestamp;

        uint day = _data.currentDay();
        uint shares = calculateShares(day, params.amount);
    
        _shares[note.id] = shares;
        _totalShares += shares;

        return note;
    }

    function burn(address payee, uint noteId) internal {
        Note memory note = getNote(noteId);
        uint payout = _burnNote(note);

        _cash.transferFrom(address(this), payee, payout);

        emit Burn(note.id, note.nounId, note.amount, note.endedAt);
    }

    function _burnNote(Note memory note) internal returns (uint payout) {
        address owner = ownerOf(note.id);
        require(owner == msg.sender, "You are not the owner");

        require(note.endedAt == 0, "Note already ended");
        note.endedAt = block.timestamp;

        _burn(note.id);

        uint earnings = _calculateEarnings(note.id);
        uint penalty = _calculatePenalty(note, block.timestamp);

        return earnings - penalty;
    }

    constructor(
        IERC20 cash_, 
        NounData data_,
        string memory baseURI_
    ) ERC721("FOUND NOUN", "FOUND NOUN") {
        _data = data_;
        _cash = cash_;

        Nounish _base = Nounish(address(this));
        _bank = new NounBank(data_, _base, baseURI_);
        _cash.approve(address(this), type(uint).max);
    }
}
