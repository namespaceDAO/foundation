// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import "./Token.sol";
import "./Treasury.sol";

contract Found is Token, Treasury {
    function mint(address to) external payable {
        require(msg.value > 0, "Must send more than 0 ETH");

        bool presale = false;
        uint amount = presale ? (msg.value * 2) : msg.value;

        _mintFound(to, amount);
        _addValue(msg.value);
    }

    function foundBalance() public view returns (uint) {
        return balanceOf(address(this));
    }

    function treasuryMint(address to, uint amount) external onlyTreasurer {
        _mintFound(to, amount);
    }

    function pushFound(address to,  uint amount) external onlyTreasurer {
        _transfer(address(this), to, amount);
    }

    function pullFound(address from, uint amount) external onlyTreasurer {
        _transfer(from, address(this), amount);
    }

    function _mintFound(address to, uint amount) internal {
        _mint(to, amount); 
        _mint(address(this), amount);
    }

    constructor() Token() {}
}