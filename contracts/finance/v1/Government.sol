// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import "./Arch.sol";
import "./Capitalism.sol";

contract Government is Capitalism {
    function createProp(PropParams memory params) external whenNotPaused {
        _createProp(params);
    }

    function createStake(StakeParams memory params) external {
        _createStake(params);
    }

    function startProp(uint propId) external {
        require(isCapitalized(propId), "Prop cannot be started");
        _startProp(propId);
    }

    function completeProp(uint propId, string memory conclusion) external {
        _completeProp(propId, conclusion);
    }

    function endStake(uint propId) external {
        _endStake(propId);
    }

    function dailyBudget() public view returns (uint) {
        uint value = valueBalance();
        uint found = tokenBalance();
        uint balance = found + value;
        return balance / budgetRate();
    }

    function isCapitalized(uint propId) public view returns (bool) {
        uint day = currentDay();
        uint budget = dailyBudget();
        
        if (budget == 0) return false;

        uint stakeRate = stakedPerDay(day) / dailyBudget();
        uint shareRate = _totalRequest(propId) * stakedOnProp(propId);
        return shareRate > stakeRate;
    }

    constructor(FoundV1 found_) Foundation(found_) {}
}