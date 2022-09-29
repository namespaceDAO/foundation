// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import "../finance/Treasury.sol";

contract NounderDAO is Treasury {
    uint private _coinId;
    address private _origin;
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

    function origin() external view returns (address) {
        return _origin;
    }

    function currentEpoch() public view returns (uint) {
        return block.timestamp / epochDuration;
    }

    function _goodAccounting(uint amount) internal {
        uint epoch = currentEpoch();
        uint balance = currentBalance();

        uint lb = balance * 7 / 100;
        uint ub = balance * 15 / 100;

        _funding[epoch] += amount;
        require(_funding[epoch] < ub, "No more than 15%");

        // If last epoch did not spend 7%, send remainder to origin.
        if (_funding[epoch - 1] < lb) {
            uint excess = lb - _funding[epoch - 1];
            _funding[epoch - 1] += excess;
            _transferValue(_origin, excess);
        }
    }

    constructor(
        uint coinId_,
        address origin_
    ) {
        _coinId = coinId_;
        _origin = origin_;
    }
}