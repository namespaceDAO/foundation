// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import "../finance/Adventure.sol";
import "../banking/Bank.sol";
import "./Nounish.sol";

contract BankOfNouns is Nounish, Adventure, Bank {
    uint amplitude = 10;

    mapping(uint => uint) private _nounToDay;
    mapping(uint => uint) private _dayToNoun;
    mapping(uint => uint) private _totalOnNoun;
    mapping(uint => uint) private _totalOnDay;
    mapping(uint => bool) private _nounClaims;
    
    event Mint(uint coinId, uint amount);
    event Vote(uint coinId, uint nounId, uint amount);
    event Claim(uint nounId, uint amount);

    function totalCoins() public view returns (uint) {
        return block.timestamp / 1 days;
    }

    function currentDay() public view returns (uint) {
        return block.timestamp / 1 days;
    }

    function nounToDay(uint noun) public view returns (uint) {
        _requireNoun(noun);
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
        _totalOnNoun[_dayToNoun(coinId)] += msg.value;
        _mint(to, coinId, amount, data);
        emit Mint(coinId, amount);
    }

    function convertValue(
        uint coinId, 
        uint value
    ) public view returns (uint) {
        uint totalSupply = totalSupply();
        if (totalSupply == 0) return value;

        uint avgSupply = totalSupply / totalCoins();
        uint tokenSupply = _totalSupplies[coinId];

        if (tokenSupply > avgSupply * amplitude) {
            return value / amplitude;
        }

        if (avgSupply > tokenSupply * amplitude) {
            return value * amplitude;
        }

        return value * avgSupply / tokenSupply;
    }

    function vote(
        address payee, 
        uint nounId,
        bytes memory data
    ) external payable {
        _requireNoun(nounId);

        uint day = currentDay();
        require(
            _nounToDay(nounId) == 0 || _nounToDay(nounId) == day,
            "Noun has been minted"
        );

        uint amount = msg.value;

        _updateDailyNouns(nounId, amount);
        _mint(to, day, amount * amplitude, data);
        
        emit Vote(day, nounId, amount);
    }

    function _updateDailyNouns(uint nounId, uint value) internal {
        _totalOnNoun[nounId] += value;

        if (_totalOnNoun[nounId] > _totalOnDay[day]) {
            _nouns[day] = nounId;
            _totalOnDay[day] = _totalOnNoun[nounId];
        }
    }

    function creatorClaim(uint nounId, bytes memory data) external {
        Noun memory noun = getNoun(nounId);
        uint amount = _totalOnNoun[nounId] / 10;

        _nounClaims[nounId] = true;
        _mint(noun.creator, nounId, amount, data);

        emit Claim(nounId, amount);
    }
}
