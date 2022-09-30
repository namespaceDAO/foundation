// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import "../foundation/Venture.sol";
import "./NounBank.sol";
import "./NounData.sol";

contract NounGame is NounCoin, Venture {
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

    function currentDay() public view returns (uint) {
        return (block.timestamp - _start) / 1 days;
    }
    
    function nounToCoin(uint nounId) override public view returns (uint) {
        return _nounToCoin[nounId];
    }

    function requireCoin(uint coinId) override public view {
        require(coinId <= currentDay(), "Noun has not been found");
    }

    function coinToNoun(uint coinId) override public view returns (uint) {
        requireCoin(coinId);
        return _coinToNoun[coinId];
    }

    function mint(
        address to, 
        uint coinId, 
        bytes memory data
    ) external payable {
        require(msg.value > 0, "Must mint some Nouns");
        
        uint amount = convertValue(coinId, msg.value);
        uint nounId = coinToNoun(coinId);
        
        _totalOnNoun[nounId] += msg.value;
        _bank.mint(to, coinId, amount, data);

        emit Mint(coinId, to, amount);
    }

    function vote(
        address payee, 
        uint nounId,
        bytes memory data
    ) external payable {
        _data.requireNoun(nounId);

        uint day = currentDay();
        require(
            nounToCoin(nounId) == 0 || nounToCoin(nounId) == day,
            "Noun has been minted"
        );

        uint amount = msg.value;

        _updateDailyNouns(nounId, amount);
        _bank.mint(payee, day, amount * amplitude, data);
        
        emit Vote(day, nounId, amount);
    }

    function claim(uint nounId, uint amount) external {
        Noun memory noun = _data.getNoun(nounId);

        uint claimed = _nounClaims[nounId];
        uint totalMinted = _totalOnNoun[nounId] - claimed;

        bool claimable = totalMinted / 10 >= amount + claimed;
        require(claimable, "Claim too large");

        _nounClaims[nounId] += amount;

        bytes memory data;
        _bank.mint(noun.creator, nounId, amount, data);

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

    function _updateDailyNouns(uint nounId, uint value) internal {
        uint day = currentDay();
        _totalOnNoun[nounId] += value;

        if (_totalOnNoun[nounId] > _totalOnCoin[day]) {
            _coinToNoun[day] = nounId;
            _totalOnCoin[day] = _totalOnNoun[nounId];
        }
    }

    constructor(ERC20 coin_, string memory baseURI_) 
    Venture("NOUN DEPOSIT", "NOUN DEPOSIT", coin_) 
    {
        NounCoin base = NounCoin(address(this));

        _start = block.timestamp;
        _data = new NounData();
        _bank = new NounBank(_data, base, baseURI_);
    }
}
