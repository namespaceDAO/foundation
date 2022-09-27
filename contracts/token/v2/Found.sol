// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import "./Token.sol";
import "../v1/Found.sol";

contract Found2 is Token2 {
    Found1 private _f1;

    event Mint(address indexed to, uint value, uint found);

    function mint(address to) external payable {
        require(msg.value > 0, "Send more than 0");
        uint amount = msg.value;
        
        _addValue(msg.value);
        _mint(to, amount);
 
        emit Mint(to, msg.value, amount);
    }

    constructor(Found1 found_, address origin_) 
    Token2("FOUND", "FOUND", origin_) {
        _f1 = found_;
    }
}