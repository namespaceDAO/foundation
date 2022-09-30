// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import "../Bank.sol";

contract MockBank is Bank {
    function mint(
        address to, 
        uint coinId, 
        bytes memory data
    ) external payable {
        _mint(to, coinId, msg.value, data);
    }

    function nameOf(uint coinId) override public view returns (string memory) {
        return "NAME";
    }

    function symbolOf(uint coinId) override public view returns (string memory) {
        return "SYMBOL";
    }

    function decimals() override public pure returns (uint8) {
        return 18;
    }

    constructor(string memory baseURI_) Bank(address(this), baseURI_) {}    
}