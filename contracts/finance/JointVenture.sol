// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import "../token/Found.sol";
import "./Capitalism.sol";

contract JointVenture {
    Capitalism private _capitalism;
    
    uint epochDuration = 28 days;
    uint stepDuration = 1 days;

    mapping(uint => uint) private _epochs;
    mapping(uint => uint) private _steps;

    function currentEpoch() public view returns (uint) {
        return block.timestamp / epochDuration;
    }

    function currentStep() public view returns (uint) {
        return block.timestamp / stepDuration;
    }

    function startStake(uint prop, uint amount, uint expiresAt) external {
        _share.startStake(amount);

        uint step = _steps[currentStep() - 1];
        uint id = capitalism.startStake(prop, amount, expiresAt);

        // TODO: update payment shares
    }

    function endStake(uint id) external {
        uint served = _share.endStake(id);
        // TODO: update payment shares
    }

    function _addValue(uint value) internal {
        _totals[block.timestamp / _timedelta] += value;
        _days[currentDay()] += value;
    }

    constructor(
        Found found_,
        string memory name_,
        string memory symbol_
    ) {
        _capitalism = new Capitalism(found_, name_, symbol_);
    }
}
