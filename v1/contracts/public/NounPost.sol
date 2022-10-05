// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/finance/PaymentSplitter.sol";

// TODO: implement some sort of DAO
contract NounPost is PaymentSplitter {
    uint private _coinId;
    uint epochDuration = 28 days;

    mapping(uint => uint) private _funding;

    function coinId() external view returns (uint) {
        return _coinId;
    }

    function currentEpoch() public view returns (uint) {
        return block.timestamp / epochDuration;
    }

    function _goodAccounting(uint amount) internal {
        uint epoch = currentEpoch();
        uint balance = address(this).balance;

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

    function _transferValue(address to, uint amount) internal {
        bool capped = address(this).balance >= amount;
        require(capped, "Transfer exceeds balance");
        (bool success, ) = to.call{value:amount}("");
        require(success, "Treasury transfer failed");
    }

    constructor(
        uint coinId_,
        address[] memory payees,
        uint[] memory shares
    ) PaymentSplitter(payees, shares) {
        _coinId = coinId_;
    }
}