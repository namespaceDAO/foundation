// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import "../Token.sol";

contract Found2 is Token {
    event Mint(address indexed to, uint value, uint found);
   
    function mint(address to) external payable {
        require(msg.value > 0, "Send more than 0");
        uint amount = msg.value;
        
        _addValue(msg.value);
        _mint(to, amount);
 
        emit Mint(to, msg.value, amount);
    }

    constructor(address origin_) 
    Token("FOUND", "FOUND", origin_) {}
}