// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import "../banking/Bank.sol";
import "../finance/JointVenture.sol";
import "./Nounish.sol";

contract BankOfNouns is Nounish, JointVenture, Bank {
    mapping(uint => uint) private _nounToDay;
    mapping(uint => uint) private _dayToNoun;
    event Mint(uint coinId, uint amount);

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

    function convertValue(uint coinId, uint value) public view returns (uint) {
        return value;
    }
    
    // for auctions
    mapping(uint => uint) private _totalOnNoun;
    mapping(uint => uint) private _totalOnDay;
    event MintNoun(uint coinId, uint nounId, uint amount);

    function mintNoun(
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
        _mint(to, day, amount * 3, data);
        
        emit MysteryMint(day, nounId, amount);
    }

    function _updateDailyNouns(uint nounId, uint value) internal {
        _totalOnNoun[nounId] += value;

        if (_totalOnNoun[nounId] > _totalOnDay[day]) {
            _nouns[day] = nounId;
            _totalOnDay[day] = _totalOnNoun[nounId];
        }
    }

    // for creators
    mapping(uint => bool) private _nounClaims;
    event CreatorClaim(uint nounId, uint amount);

    function creatorClaim(uint nounId, bytes memory data) external {
        Noun memory noun = getNoun(nounId);
        uint amount = _totalOnNoun[nounId] / 10;

        _nounClaims[nounId] = true;
        _mint(noun.creator, nounId, amount, data);

        emit CreatorClaim(nounId, amount);
    }
}
