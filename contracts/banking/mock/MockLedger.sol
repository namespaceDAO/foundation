// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import "../Ledger.sol";

contract MockLedger is Ledger {
    function mint(
        address to, 
        uint coinId, 
        bytes memory data
    ) external payable {
        _mint(to, coinId, msg.value, data);
    }

    function decimals() override public pure returns (uint8) {
        return 18;
    }

    function deployedTokenTransfer(
        address from, 
        address to, 
        uint coinId, 
        uint amount
    ) override external {}

    constructor(string memory baseURI_) Ledger(baseURI_) {}    
}