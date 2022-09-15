// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import "./Arch.sol";
import "./Capitalism.sol";

contract Government is Capitalism {
    function createProp(PropParams memory params) external whenNotPaused {
        _createProp(params);
    }

    function startStake(StakeParams memory params) external {
        _startStake(params);
    }

    function startProp(uint propId) external {
        require(_isStartable(propId), "Prop cannot be started");
        _startProp(propId);
    }

    function endStake(uint propId) external {
        _endStake(propId);
    }

    function dailyBudget() public view returns (uint) {
        return _treasuryNetBalance() / budgetRate();
    }

    function _isStartable(uint propId) internal view returns (bool) {
        uint day = currentDay();
        uint stakeRate = stakedPerDay(day) / dailyBudget();
        uint shareRate = _totalRequest(propId) * stakedOnProp(propId);
        return shareRate > stakeRate;
    }

    constructor(Found found_) Foundation(found_) {}
}