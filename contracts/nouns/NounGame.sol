// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import "../finance/Venture.sol";
import "./NounBank.sol";
import "./NounNote.sol";

// NounBank creates a new cryptocurrency every day.
contract NounGame is Venture {
    NounBank private _bank;
    NounNote private _note;

    mapping(uint => uint) private _nounToDay;
    mapping(uint => uint) private _dayToNoun;
    mapping(uint => uint) private _totalOnNoun;
    mapping(uint => uint) private _totalOnDay;
    mapping(uint => bool) private _nounClaims;
    
    event Mint(uint coinId, address to, uint amount);
    event Vote(uint coinId, uint nounId, uint amount);
    event Claim(uint nounId, uint amount);

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
        _bank.mint(to, coinId, amount, data);

        emit Mint(coinId, to, amount);
    }

    function vote(
        address payee, 
        uint nounId,
        bytes memory data
    ) external payable {
        _note.requireNoun(nounId);

        uint day = currentDay();
        require(
            nounToDay(nounId) == 0 || nounToDay(nounId) == day,
            "Noun has been minted"
        );

        uint amount = msg.value;

        _updateDailyNouns(nounId, amount);
        _bank.mint(payee, day, amount * amplitude, data);
        
        emit Vote(day, nounId, amount);
    }

    function claim(uint nounId, bytes memory data) external {
        Noun memory noun = _note.getNoun(nounId);
        uint amount = _totalOnNoun[nounId] / 10;

        _nounClaims[nounId] = true;
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

        if (_totalOnNoun[nounId] > _totalOnDay[day]) {
            _dayToNoun[day] = nounId;
            _totalOnDay[day] = _totalOnNoun[nounId];
        }
    }

    constructor(
        string memory baseURI_,
        NounNote note_,
        ERC20 coin_
    ) Venture("NOUN NOTE", "NOUN NOTE", note_, coin_) {
        _note = note_;
        _bank = new NounBank(address(this), baseURI_, note_);
    }
}
