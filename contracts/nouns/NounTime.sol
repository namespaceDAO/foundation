// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import "../foundation/Adventure.sol";
import "./shared.sol";
import "./NounData.sol";

contract NounTime is NounBase, Adventure {
    NounData private _data;
    ERC20 private _coin;
    uint private _start;

    mapping(uint => uint) private _nounToCoin;
    mapping(uint => uint) private _coinToNoun;
    mapping(uint => uint) private _cashOnNoun;
    mapping(uint => uint) private _cashOnCoin;
    mapping(uint => uint) private _nounClaims;

    function coin() external view returns (ERC20) {
        return _coin;
    }

    function data() external view returns (NounData) {
        return _data;
    }

    function totalCoins() public view returns (uint) {
        return (block.timestamp - _start) / 1 days + 1;
    }

    function currentDay() override public view returns (uint) {
        return (block.timestamp - _start) / 1 days + 1;
    }
    
    function nounToCoin(uint nounId) public view returns (uint) {
        require(nounId <= _data.nounCount(), "Noun not found");
        return _nounToCoin[nounId];
    }

    function coinToNoun(uint coinId) override public view returns (Noun memory) {
        uint nounId = _requireMintedNoun(coinId);
        return _data.getNoun(nounId);
    }

    function cashOnNoun(uint nounId) external view returns (uint) {
        return _cashOnNoun[nounId];
    }
    
    function cashOnCoin(uint nounId) external view returns (uint) {
        return _cashOnCoin[nounId];
    }
    
    function nounClaims(uint nounId) external view returns (uint) {
        return _nounClaims[nounId];
    }

    // TODO: EVERYTHING BELOW HERE NEEDS A PASS

    function _collectVote(address payee, uint nounId, uint amount) internal returns (uint) {
        require(nounId <= _data.nounCount(), "Noun not found");

        uint coinId = currentDay();
        uint existing = _nounToCoin[nounId];

        require(
            existing == 0 || existing == coinId, 
            "Noun has been minted"
        );

        _coin.transferFrom(payee, address(this), amount);

        _addMintValue(nounId, amount);
        _updateDailyNouns(nounId, amount);

        return coinId;
    }

    function _collectMint(address from, uint coinId, uint amount) internal returns (uint nounId) {
        require(amount > 0, "Must mint some Nouns");
        _addMintValue(coinId, amount);
        _coin.transferFrom(from, address(this), amount);
        return _coinToNoun[coinId];
    }

    function _addMintValue(uint coinId, uint amount) internal {
        uint nounId = _requireMintedNoun(coinId);
        _cashOnNoun[nounId] += amount;
        _addValue(amount);
    }

    function _addClaimValue(uint coinId, uint amount) internal returns (address) {
        // TODO: ensure that this account is the owner of the claim

        uint nounId = _requireMintedNoun(coinId);
        Noun memory noun = _data.getNoun(nounId);

        uint claimed = _nounClaims[nounId];
        uint cashMinted = _cashOnNoun[nounId] - claimed;

        bool claimable = cashMinted / 10 >= amount + claimed;
        require(claimable, "Claim too large");

        _nounClaims[nounId] += amount;
        return noun.creator;
    }

    function _updateDailyNouns(uint nounId, uint value) internal {
        uint coinId = currentDay();
        uint current = _cashOnCoin[coinId];

        // TODO: could relying on current (without slippage) here cause a problem with MEV?
        if (_cashOnNoun[nounId] > current || current == 0) {
            _coinToNoun[coinId] = nounId;
            _nounToCoin[nounId] = coinId;
            _cashOnCoin[coinId] = _cashOnNoun[nounId];
        }
    }

    function _requireMintedNoun(uint coinId) internal view returns (uint) {
        require(coinId <= totalCoins(), "Coin has not been minted");
        return _coinToNoun[coinId];
    }

    constructor(ERC20 coin_) 
    Adventure("FOUND NOUN", "FOUND NOUN", coin_) {
        _start = block.timestamp;
        _data = new NounData();
        _coin = coin_;
    }
}
