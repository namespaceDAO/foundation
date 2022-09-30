// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import "../banking/Bank.sol";
import "./NounBase.sol";

contract NounBank is Bank {
    NounBase private _base;

    function nameOf(uint coinId) override public view returns (string memory) {
        return "NOUN COIN";
    }

    function symbolOf(uint coinId) override public view returns (string memory) {
        return "NOUN COIN";
    }

    function decimals() override virtual public view returns (uint8) {
        return 14;
    }

    function mint(
        address to, 
        uint id, 
        uint amount, 
        bytes memory data
    ) external onlyAdmin {
        _mint(to, id, amount, data);
    }

    constructor(
        address admin_,
        string memory baseURI_,
        NounBase base_
    ) Bank(admin_, baseURI_) {
        _base = base_;
    }
}
