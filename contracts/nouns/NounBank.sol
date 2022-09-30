// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import "../money/Bank.sol";
import "./NounData.sol";

contract NounBank is Bank {
    address private _admin;
    NounData private _data;

    modifier onlyAdmin() {
        require(msg.sender == _admin, "Caller is not the admin");
        _;
    }

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
        NounData home_
    ) Bank(baseURI_) {
        _data = home_;
    }
}
