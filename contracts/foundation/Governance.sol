// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Governance is Ownable {
    uint private _tax = 0;
    uint private _bps = 10000;
    address private _treasury;

    function bps() external view returns (uint) {
        return _bps;
    }

    function tax() external view returns (uint) {
        return _tax;
    }

    function treasury() external view returns (address) {
        return _treasury;
    }

    function taxValue(uint value) external view returns (uint) {
        return value * _tax / _bps;
    }

    function setTax(uint tax_) external onlyOwner {
        require(5000 > tax_, "Too many apples");
        _tax = tax_; 
    }

    function setTreasury(address treasury_) external onlyOwner {
        _treasury = treasury_;
    }
}
