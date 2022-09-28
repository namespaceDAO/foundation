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

    function capitalism() public view returns (Capitalism) {
        return _capitalism;
    }

    function startStake(StakeParams memory params) external {
        _capitalism.startStake(params);

        uint step = _steps[currentStep() - 1];
        // uint id = _capitalism.startStake(prop, amount, expiresAt);

        // TODO: update payment shares
    }

    function endStake(uint id) external {
        // uint served = _capitalism.endStake(id);
        // TODO: update payment shares

        // for (uint month = 0; month < served; month += 1) {

        // }
    }

    function _addValue(uint value) internal {
        _epochs[currentEpoch()] += value;
        _steps[currentStep()] += value;
    }

    constructor(
        string memory name_,
        string memory symbol_,
        ERC20 coin_
    ) {
        _capitalism = new Capitalism(
            name_,
            symbol_,
            coin_,
            address(this)
        );
    }
}
