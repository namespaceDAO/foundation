// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./NounBank.sol";
import "./NounData.sol";
import "./shared.sol";

/*
TODO:
ERC721 contract URI for notes
data URI, token URI
special card art?

optional governance tax, optional card art changes?

*/

contract NounGame is ERC721 {
    NounBank private _bank;
    NounData private _data;
    IERC20 private _cash;

    function bank() external view returns (NounBank) { 
        return _bank; 
    }

    function data() external view returns (NounData) {
        return _data;
    }

    function cash() external view returns (IERC20) {
        return _cash;
    }

    mapping(uint => uint) private _nounToCoin;
    mapping(uint => uint) private _coinToNoun;
    mapping(uint => uint) private _cashOnNoun;
    mapping(uint => uint) private _cashOnCoin;

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

    uint private _stakeCount;
    uint private _amplitude = 10;
    uint private _totalShares = 0;
    uint private _minimumDuration = 1 days;
    
    mapping(uint => uint) private _shares;
    mapping(uint => Note) private _notes;

    function stakeCount() external view returns (uint) {
        return _stakeCount;
    }

    function amplitude() external view returns (uint) {
        return _amplitude;
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

    function getNote(uint stakeId) external view returns (Note memory) {
        require(stakeId <= _stakeCount, "Note not found");
        return _notes[stakeId];
    }

    // TODO: test this function
    function calculateShares(uint day, uint amount) public view returns (uint) {
        uint last = _cashOnCoin[day - 1];

        if (last == 0) {
            return amount;
        }

        if (last > amount * _amplitude) {
            return amount / _amplitude;
        }

        if (last < amount / _amplitude) {
            return amount * _amplitude;
        }

        return amount * amount / last;
    }

    event Claim(
        address creator,
        address minter,
        uint coinId,
        uint nounId,
        uint coins
    );

    // TODO: check if the creator is the claimer
    // TODO: increment the claim count to prevent over minting
    // TODO: transfer the ownership of the claim via an NFT
    function claim(
        address minter, 
        uint coinId, 
        uint amount
    ) external {
        uint nounId = _coinToNoun[coinId];

        Noun memory noun = _data.getNoun(nounId);

        require(
            msg.sender == noun.creator, 
            "Sender is not the Noun creaotr"
        );

        _bank.mint(minter, coinId, amount);
        
        emit Claim(
            noun.creator,
            minter,
            coinId, 
            nounId,
            amount
        );
    }

    event Vote(
        address payer,
        address minter,
        uint coinId,
        uint nounId,
        uint found,
        uint coins
    );
    
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

    event Mint(
        address payer,
        address minter,
        uint coinId,
        uint nounId,
        uint found,
        uint coins
    );

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

    event Stake(
        uint id,
        uint idea,
        uint amount,
        uint expiresAt,
        uint startedAt
    );

    // TODO: double check the params
    // TODO: transfer the found to the appropriate address
    function stake(NoteParams memory params) external {
        Note memory note = _createNote(params);

        _mint(params.owner, note.id);

        emit Stake(
            note.id, 
            note.idea,
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
        note.idea = params.idea;
        note.amount = params.amount;
        note.expiresAt = params.expiresAt;
        note.startedAt = block.timestamp;
        note.founder = params.founder;

        uint day = _data.currentDay();
        uint shares = calculateShares(day, params.amount);
    
        _shares[note.id] = shares;
        _totalShares += shares;

        return note;
    }

    event Burn(
        uint id,
        uint idea,
        uint amount,
        uint endedAt
    );

    function burn(address payee, uint noteId) internal {
        address owner = ownerOf(noteId);
        require(owner == msg.sender, "You are not the owner");

        Note storage note = _notes[noteId];
        require(note.endedAt == 0, "Note already ended");
        note.endedAt = block.timestamp;
        note.redeemer = owner;
        note.payee = payee;
        (note.earnings, note.penalty) = _calculatePayout(note, block.timestamp);

        _cash.transferFrom(
            address(this), 
            payee, 
            note.earnings - note.penalty
        );

        _burn(note.id);

        emit Burn(note.id, note.idea, note.amount, note.endedAt);
    }
    
    function calculatePayout(
        uint noteId, 
        uint timestamp
    ) external view returns (
        uint earnings, 
        uint penalty
    ) {
       Note memory note = _notes[noteId];
       return _calculatePayout(note, timestamp);
    }

    function _calculatePayout(
        Note memory note, 
        uint timestamp
    ) internal view returns (uint, uint) {
        uint penalty;

         if (timestamp > note.expiresAt + 2 weeks) {
            uint late = (timestamp - note.expiresAt - 2 weeks) / 1 days;
            penalty = late * note.amount / 14;
        }

        uint balance = _cash.balanceOf(address(this));
        uint earnings = balance * _shares[note.id] / _totalShares;

        return (earnings, penalty);
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
