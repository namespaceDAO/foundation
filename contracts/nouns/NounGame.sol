// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./NounBank.sol";
import "./NounData.sol";
import "./shared.sol";

contract NounGame is ERC721 {
    NounBank private _bank;
    NounData private _data;
    IERC20 private _cash;

    uint private _stakeCount;
    uint private _amplitude = 10;
    uint private _totalShares = 0;
    uint private _minimumDuration = 1 days;

    mapping(uint => uint) private _shares;
    mapping(uint => uint) private _nounToCoin;
    mapping(uint => uint) private _coinToNoun;
    mapping(uint => uint) private _cashOnNoun;
    mapping(uint => uint) private _cashOnCoin;
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

    function stakeCount() public view returns (uint) { return _stakeCount; }

    function bank() external view returns (NounBank) { return _bank; }
    function data() external view returns (NounData) { return _data; }
    function cash() external view returns (IERC20) { return _cash; }

    function nounToCoin(uint nounId) external view returns (uint coinId) {
        return _nounToCoin[nounId];
    }

    function coinToNoun(uint coinId) external view returns (uint nounId) {
        return _coinToNoun[coinId];
    }

    function cashOnNoun(uint nounId) external view returns (uint) {
        return _cashOnNoun[nounId];
    }
    
    function cashOnCoin(uint nounId) external view returns (uint) {
        return _cashOnCoin[nounId];
    }

    function getNoteShares(uint day, uint amount) public view returns (uint) {
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

    function stakeShares(uint stakeId) public view returns (uint) {
        return _shares[stakeId];
    }

    function totalShares() public view returns (uint) {
        return _totalShares;
    }

    function getNote(uint id) public view returns (Note memory) {
        _requireNote(id);
        return _notes[id];
    }

    function claim(
        address minter, 
        uint coinId, 
        uint amount
    ) external {
        // TODO: check if the creator is the claimer
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

    function stake(NoteParams memory params) external {
        require(
            params.amount > 0, 
            "Note more than 0"
        );

        require(
            params.expiresAt > block.timestamp  + _minimumDuration, 
            "Must expire further in the future"
        );

        Note storage stake = _notes[++_stakeCount];
        stake.id = _stakeCount;
        stake.idea = params.idea;
        stake.amount = params.amount;
        stake.expiresAt = params.expiresAt;
        stake.startedAt = block.timestamp;
        stake.founder = params.founder;

        uint day = _data.currentDay();
        uint shares = getNoteShares(day, params.amount);
    
        _shares[stake.id] = shares;
        _totalShares += shares;

        _mint(params.owner, stake.id);

        emit Stake(
            stake.id, 
            stake.idea,
            stake.amount,
            stake.expiresAt,
            stake.startedAt
        );
    }

    function burn(address payee, uint stakeId) internal {
        address owner = ownerOf(stakeId);

        require(owner == msg.sender, "You are not the stake owner");
        Note storage stake = _notes[stakeId];

        require(stake.endedAt == 0, "Note already ended");
        stake.endedAt = block.timestamp;
        stake.redeemer = owner;
        stake.payee = payee;

        uint penalty;
        if (block.timestamp > stake.expiresAt + 2 weeks) {
            uint late = (block.timestamp - stake.expiresAt - 2 weeks) / 1 days;
            penalty = late * stake.amount / 14;
        }

        uint shares = _shares[stakeId];

        uint balance = _cash.balanceOf(address(this));
        uint earnings = balance * shares / _totalShares;

        uint payout = earnings - penalty;

        _cash.transferFrom(address(this), payee, payout);

        _burn(stake.id);

        emit Burn(stake.id, stake.idea, stake.amount, stake.endedAt);
    }

    function _requireNote(uint stakeId) internal view {
        require(stakeId <= _stakeCount, "Note not found");
    }

    function _updateDailyNouns(uint coinId, uint nounId) internal {
        uint minimum = _cashOnCoin[coinId] * 101 / 100;
        if (_cashOnNoun[nounId] > minimum || minimum == 0) {
            _coinToNoun[coinId] = nounId;
            _nounToCoin[nounId] = coinId;
            _cashOnCoin[coinId] = _cashOnNoun[nounId];
        }
    }

    function _collectMint(uint coinId, uint amount) internal returns (uint) {
        uint nounId = _requireFoundNoun(coinId);
        require(amount > 0, "Must mint some Nouns");
        _cashOnNoun[nounId] += amount;
        return _coinToNoun[coinId];
    }

    function _collectVote(uint nounId, uint amount) internal returns (uint) {
        uint coinId = _requireFreshNoun(nounId);
        _cashOnNoun[nounId] += amount;
        _updateDailyNouns(coinId, nounId);
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

    function _requireFoundNoun(uint coinId) internal view returns (uint nounId) {
        require(
            coinId > 0 && coinId <= _data.currentDay(), 
            "Coin has not been minted"
        );

        return _coinToNoun[coinId];
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
