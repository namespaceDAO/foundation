// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import "../finance/Venture.sol";
import "../banking/Bank.sol";
import "./NounDescriptor.sol";

// NounBank creates a new cryptocurrency every day.
contract NounBank is Venture, Bank {
    mapping(uint => uint) private _nounToDay;
    mapping(uint => uint) private _dayToNoun;
    mapping(uint => uint) private _totalOnNoun;
    mapping(uint => uint) private _totalOnDay;
    mapping(uint => bool) private _nounClaims;

    NounDescriptor private _descriptor;
    
    event Mint(uint coinId, uint amount);
    event Vote(uint coinId, uint nounId, uint amount);
    event Claim(uint nounId, uint amount);

    function nameOf(uint coinId) override public view returns (string memory) {
        return "NOUN COIN";
    }

    function symbolOf(uint coinId) override public view returns (string memory) {
        return "NOUN COIN";
    }

    function decimals() override virtual public view returns (uint8) {
        return 14;
    }

    function totalCoins() public view returns (uint) {
        return block.timestamp / 1 days;
    }

    function currentDay() public view returns (uint) {
        return block.timestamp / 1 days;
    }
    
    function nounToDay(uint noun) public view returns (uint) {
        return _nounToDay[noun];
    }

    function dayToNoun(uint day) public view returns (uint) {
        require(day <= currentDay(), "Noun has not been found");
        return _dayToNoun[day];
    }

    function mint(
        address to, 
        uint coinId, 
        bytes memory data
    ) external payable {
        require(msg.value > 0, "Must mint some Nouns");
        
        uint amount = convertValue(coinId, msg.value);
        uint nounId = dayToNoun(coinId);
        
        _totalOnNoun[nounId] += msg.value;
        _mint(to, coinId, amount, data);

        emit Mint(coinId, amount);
    }

    function vote(
        address payee, 
        uint nounId,
        bytes memory data
    ) external payable {
        _requireNoun(nounId);

        uint day = currentDay();
        require(
            nounToDay(nounId) == 0 || nounToDay(nounId) == day,
            "Noun has been minted"
        );

        uint amount = msg.value;

        _updateDailyNouns(nounId, amount);
        _mint(payee, day, amount * amplitude, data);
        
        emit Vote(day, nounId, amount);
    }

    function claim(uint nounId, bytes memory data) external {
        Noun memory noun = _descriptor.getNoun(nounId);
        uint amount = _totalOnNoun[nounId] / 10;

        _nounClaims[nounId] = true;
        _mint(noun.creator, nounId, amount, data);

        emit Claim(nounId, amount);
    }

    function convertValue(
        uint coinId, 
        uint value
    ) public view returns (uint) {
        uint totalSupply = totalSupply();
        if (totalSupply == 0) return value;

        uint avgSupply = totalSupply / totalCoins();
        uint tokenSupply = totalSupplyOf(coinId);

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

        if (_totalOnNoun[nounId] > _totalOnDay[day]) {
            _dayToNoun[day] = nounId;
            _totalOnDay[day] = _totalOnNoun[nounId];
        }
    }

    function _requireNoun(uint nounId) internal view {
        _descriptor.requireNoun(nounId);
    }

    constructor(
        string memory baseURI_,
        CapitalismDescriptor desc_,
        ERC20 coin_
    ) 
    Bank(baseURI_)
    Venture("NOUN NOTE", "NOUN NOTE", desc_, coin_) {}
}
