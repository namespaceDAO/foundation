// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import "./Token.sol";

contract Found is Token {
    event Mint(address indexed to, uint found);
    event Burn(address indexed from, address indexed to, uint found, uint value);

    function mint(address to) external payable {
        _mintFound(to, msg.value);
    }

    function mint10x(address to) external payable {
        require(block.timestamp < 1666666667, "10x closed");
        _mintFound(to, msg.value * 10);
    }

    function foundValue(uint found) public view returns (uint) {
        return found * address(this).balance / totalSupply();
    }

    function burn(address from, address to, uint amount) external {
        require(amount > 0, "Burn more than 0");
        _burn(from, amount);
        
        uint value = foundValue(amount);
        (bool success, ) = to.call{value:value}("");
        require(success, "Burn failed");

        emit Burn(from, to, amount, value);
    }

    function _mintFound(address to, uint amount) internal {
        require(amount > 0, "Mint more than 0");
        _mint(to, amount);
        emit Mint(to, amount);
    }

    constructor() ERC20("FOUND", "FOUND") {}
}
