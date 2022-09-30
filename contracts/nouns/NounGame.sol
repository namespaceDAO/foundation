// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import "../foundation/Adventure.sol";
import "./NounBank.sol";
import "./NounData.sol";

contract NounGame is NounCoin, Adventure {
    uint private _start;

    NounData private _data;
    NounBank private _bank;

    mapping(uint => uint) private _nounToCoin;
    mapping(uint => uint) private _coinToNoun;
    mapping(uint => uint) private _totalOnNoun;
    mapping(uint => uint) private _totalOnCoin;
    mapping(uint => uint) private _nounClaims;
    
    event Mint(uint coinId, address to, uint amount);
    event Vote(uint coinId, uint nounId, uint amount);
    event Claim(uint nounId, uint amount);

    function data() public view returns (NounData) {
        return _data;
    }

    function bank() public view returns (NounBank) {
        return _bank;
    }

    function totalCoins() public view returns (uint) {
        return (block.timestamp - _start) / 1 days;
    }

    function currentDay() override public view returns (uint) {
        return (block.timestamp - _start) / 1 days;
    }
    
    function nounToCoin(uint nounId) public view returns (uint) {
        return _nounToCoin[nounId];
    }

    function coinToNoun(uint coinId) override public view returns (uint) {
        _requireMintedCoin(coinId);
        return _coinToNoun[coinId];
    }
    
    function totalOnNoun(uint nounId) external view returns (uint) {
        return _totalOnNoun[nounId];
    }
    
    function totalOnCoin(uint nounId) external view returns (uint) {
        return _totalOnCoin[nounId];
    }
    
    function nounClaims(uint nounId) external view returns (uint) {
        return _nounClaims[nounId];
    }

    function mint(address to, uint coinId) external payable {
        require(msg.value > 0, "Must mint some Nouns");

        uint nounId = coinToNoun(coinId);        
        uint amount = convertValue(coinId, msg.value);

        _addNounValue(nounId, msg.value);
        _bank.mint(to, coinId, amount);

        emit Mint(coinId, to, amount);
    }

    function vote(address payee, uint nounId) external payable {
        _requireMintableNoun(nounId);

        _addNounValue(nounId, msg.value);
        _updateDailyNouns(nounId, msg.value);
        
        uint day = currentDay();
        uint bonus = amplitude * msg.value;
        _bank.mint(payee, day, bonus);
        
        emit Vote(day, nounId, bonus);
    }

    function claim(uint coinId, uint amount) external {
        uint nounId = coinToNoun(coinId);
        Noun memory noun = _data.getNoun(nounId);

        uint claimed = _nounClaims[nounId];
        uint totalMinted = _totalOnNoun[nounId] - claimed;

        bool claimable = totalMinted / 10 >= amount + claimed;
        require(claimable, "Claim too large");

        _nounClaims[nounId] += amount;
        _bank.mint(noun.creator, nounId, amount);

        emit Claim(nounId, amount);
    }

    function convertValue(
        uint coinId, 
        uint value
    ) public view returns (uint) {
        uint totalSupply = _bank.totalSupply();
        if (totalSupply == 0) return value;

        uint avgSupply = totalSupply / totalCoins();
        uint tokenSupply = _bank.totalSupplyOf(coinId);

        if (tokenSupply > avgSupply * amplitude) {
            return value / amplitude;
        }

        if (avgSupply > tokenSupply * amplitude) {
            return value * amplitude;
        }

        return value * avgSupply / tokenSupply;
    }

    function _addNounValue(uint nounId, uint value) internal {
        _addValue(value);
        _totalOnNoun[nounId] += value;
    }

    function _updateDailyNouns(uint nounId, uint value) internal {
        uint day = currentDay();
        if (_totalOnNoun[nounId] > _totalOnCoin[day]) {
            _coinToNoun[day] = nounId;
            _totalOnCoin[day] = _totalOnNoun[nounId];
        }
    }

    function _requireMintedCoin(uint coinId) internal view {
        require(coinId <= currentDay(), "Coin has not been minted");
    }

    function _requireMintableNoun(uint nounId) internal view {
        require(nounId <= _data.nounCount(), "Noun not found");
        uint coinId = _nounToCoin[nounId];
        require(
            coinId == 0 || coinId == currentDay(),
            "Noun has been minted"
        );
    }

    constructor(ERC20 coin_, string memory baseURI_) 
    Adventure("FOUND NOUN", "FOUND NOUN", coin_) 
    {
        NounCoin base = NounCoin(address(this));

        _start = block.timestamp;
        _data = new NounData();
        _bank = new NounBank(_data, base, baseURI_);
    }
}
