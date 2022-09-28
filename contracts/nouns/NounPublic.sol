// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorPreventLateQuorum.sol";
import "../finance/Treasury.sol";

contract NounPublic is Treasury {
    address origin;
    uint epochDuration = 28 days;

    mapping(uint => uint) private _sent;

    function currentEpoch() public view returns (uint) {
        return block.timestamp / epochDuration;
    }

    function _goodAccounting(uint amount) internal {
        uint epoch = currentEpoch();
        uint balance = currentBalance();

        uint lb = balance * 69 / 1000;
        uint ub = balance * 15 / 100;

        _sent[epoch] += amount;
        require(_sent[epoch] < ub, "No more than 15%");

        // If last epoch did not spend 6.9%, send remainder to origin.
        if (_sent[epoch - 1] < lb) {
            uint excess = lb - _sent[epoch - 1];
            _sent[epoch - 1] += excess;
            _transferValue(origin, excess);
        }
    }

    function sendValue(address to, uint amount) external {
        _goodAccounting(amount);
        _transferValue(to, amount);
    }

    constructor(address origin_) {
        origin = origin_;
    }
}