// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import "./Arch.sol";
import "./Capitalism.sol";

contract Government is Capitalism {
    function startStake(StakeProps memory props) external {
        _startStake(props);
    }

    function endStake(uint id) external {
        _endStake(id);
    }

    function createProp(PropArgs memory prop) external whenNotPaused {
        _createProp(prop);
    }

    function startProp(uint id) external {
        require(_isStartable(id), "Government: prop cannot be started");
        _startProp(id);
    }

    function currentSpendingLimit() public view returns (uint) {
        return _treasuryNetBalance() / weeklyLimit();
    }

    function _isStartable(uint id) internal view returns (bool) {
        uint week = currentWeek();
        require(
            propWeek(id) + 1 == week, 
            "Proposals must be started the following week"
        );

        uint stakeRate = totalStakedByWeek(week) / currentSpendingLimit();
        uint shareRate = propAsk(id) * totalStakedByGoal(id);

        return shareRate > stakeRate;
    }

    constructor(Found found_) Arch(found_) {}
}