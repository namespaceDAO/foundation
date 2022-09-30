// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import "../finance/Treasury.sol";

contract NounPost is Treasury {
    uint private _coinId;
    uint epochDuration = 28 days;

    mapping(uint => uint) private _funding;

    // TODO: governance contract
    function sendValue(address to, uint amount) external {
        _goodAccounting(amount);
        _transferValue(to, amount);
    }

    function coinId() external view returns (uint) {
        return _coinId;
    }

    function currentEpoch() public view returns (uint) {
        return block.timestamp / epochDuration;
    }

    function _goodAccounting(uint amount) internal {
        uint epoch = currentEpoch();
        uint balance = currentBalance();

        uint lb = balance * 8 / 100;
        uint ub = balance * 2 / 10;

        _funding[epoch] += amount;
        require(_funding[epoch] < ub, "No more than 20%");

        // If last epoch did not spend 8%, send remainder to zero address.
        if (_funding[epoch - 1] < lb) {
            uint excess = lb - _funding[epoch - 1];
            _funding[epoch - 1] += excess;
            _transferValue(address(0), excess);
        }
    }

    constructor(uint coinId_) {
        _coinId = coinId_;
    }
}