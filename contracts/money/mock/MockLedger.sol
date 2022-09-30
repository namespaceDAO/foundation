// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import "../Ledger.sol";

contract MockLedger is Ledger {
    function nameOf(uint coinId) override public view returns (string memory) {
        return "NAME";
    }

    function symbolOf(uint coinId) override public view returns (string memory) {
        return "SYMBOL";
    }

    function decimals() override public pure returns (uint8) {
        return 18;
    }

    function mint(address to, uint coinId) external payable {
        bytes memory data;
        _mint(to, coinId, msg.value, data);
    }

    constructor(string memory baseURI_) Ledger(baseURI_) {}    
}