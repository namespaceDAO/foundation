// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Found is Ownable, ERC20 {
    uint claimed;

    event Mint(address indexed to, uint found);
    event Burn(address indexed from, address indexed to, uint found, uint value);
    event Claim(address indexed to, uint found);

    function foundValue(uint found) public view returns (uint) {
        return found * address(this).balance / totalSupply();
    }

    function mint(address to) external payable {
        _mintFound(to, msg.value);
    }

    function mint2x(address to) external payable {
        require(block.timestamp < 1666666667, "2x closed");
        _mintFound(to, msg.value * 2);
    }

    function _mintFound(address to, uint amount) internal {
        require(amount > 0, "Mint more than 0");
        _mint(to, amount);
        emit Mint(to, amount);
    }

    function burn(address from, address to, uint amount) external {
        require(amount > 0, "Burn more than 0");
        
        uint value = foundValue(amount);
        bool burnable = address(this).balance >= value;
        require(burnable, "Burn exceeds balance");

        _burn(from, amount);
        (bool success, ) = to.call{value:value}("");
        require(success, "Burn failed");

        emit Burn(from, to, amount, value);
    }

    function claim(address to, uint amount) external onlyOwner {
        bool claimable = totalSupply() / 10 >= amount + claimed;
        require(claimable, "Claim too large");

        claimed += amount;
        _mint(to, amount);

        emit Claim(to, amount);
    }

    constructor() ERC20("FOUND", "FOUND") {}
}
