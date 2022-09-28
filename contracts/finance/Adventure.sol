// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./Capitalism.sol";

contract Adventure {
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

        for (uint month = 0; month < served; month += 1) {

        }
    }

    function _addValue(uint value) internal {
        _totals[block.timestamp / _timedelta] += value;
        _days[currentDay()] += value;
    }

    constructor(
        string memory name_,
        string memory symbol_,
        ERC20 coin_
    ) {
        _capitalism = new Capitalism(name_, symbol_, coin_);
    }
}
