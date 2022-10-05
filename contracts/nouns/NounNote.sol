// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../foundation/Capitalism.sol";
import "./NounData.sol";
import "./shared.sol";

contract NounNote is NounBased, Capitalism {
    NounData private _data;
    IERC20 private _cash;

    uint private _start;
    uint private _amplitude = 10;
    uint private _totalShares = 0;

    mapping(uint => uint) private _shares;
    mapping(uint => uint) private _nounToCoin;
    mapping(uint => uint) private _cashToNoun;
    mapping(uint => uint) private _cashOnNoun;
    mapping(uint => uint) private _cashOnCoin;

    function nounToCoin(uint nounId) public view returns (uint) {
        require(nounId <= _data.nounCount(), "Noun not found");
        return _nounToCoin[nounId];
    }

    function coinToNoun(uint coinId) override public view returns (Noun memory) {
        uint nounId = _requireFoundNoun(coinId);
        return _data.getNoun(nounId);
    }

    function cashOnNoun(uint nounId) external view returns (uint) {
        return _cashOnNoun[nounId];
    }
    
    function cashOnCoin(uint nounId) external view returns (uint) {
        return _cashOnCoin[nounId];
    }

    function getStakeShares(uint day, uint amount) public view returns (uint) {
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

    function _updateDailyNouns(uint coinId, uint nounId) internal {
        uint current = _cashOnCoin[coinId];

        // TODO: could relying on current (without slippage) 
        // here cause a problem with MEV?
        if (_cashOnNoun[nounId] > current || current == 0) {
            _cashToNoun[coinId] = nounId;
            _nounToCoin[nounId] = coinId;
            _cashOnCoin[coinId] = _cashOnNoun[nounId];
        }
    }

    function _stakeCoins(StakeParams memory params) internal {
        Stake memory stake = _startStake(params);

        uint day = _data.currentDay();
        uint shares = getStakeShares(day, params.amount);
        _shares[stake.id] = shares;
        _totalShares += shares;
    }

    function _collectMint(uint coinId, uint amount) internal returns (uint) {
        uint nounId = _requireFoundNoun(coinId);
        require(amount > 0, "Must mint some Nouns");
        _cashOnNoun[nounId] += amount;
        return _cashToNoun[coinId];
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

        return _cashToNoun[coinId];
    }

    constructor(IERC20 cash_, NounData data_) 
    Capitalism("FOUND NOUN", "FOUND NOUN") {
        _start = block.timestamp;
        _cash = cash_;
        _data = data_;
        _cash.approve(address(this), type(uint).max);
    }
}
