// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import "./Treasury.sol";

contract Governance is Treasury {
    uint private _tax = 0;
    uint private _bps = 10000;

    function bps() external view returns (uint) {
        return _bps;
    }

    function tax() external view returns (uint) {
        return _tax;
    }

    function taxValue(uint value) external view returns (uint) {
        return value * _tax / _bps;
    }

    function setTax(uint tax_) external onlyOwner {
        require(5000 >= tax_, "Too many apples");
        _tax = tax_; 
    }
}
