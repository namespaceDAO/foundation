// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./Forge.sol";

contract Found is Ownable, ERC20 {
    uint foundClaim;

    event Mint(address indexed to, uint amount);
    event Burn(address indexed from, address indexed to, uint amount);
   
    receive() external payable {}
    fallback() external payable {}

    function burnValue(uint amount) public view returns (uint) {
        return amount * address(this).balance / totalSupply();
    }

    function mint(address to) external payable {
        require(msg.value > 0, "Send more than 0");

        _mint(to, msg.value);
        emit Mint(to, msg.value);
    }

    function burn(address from, address to, uint amount) external {
        require(amount > 0, "Burn more than 0");

        uint value = burnValue(amount);
        
        _burn(from, amount);
        _transferValue(to, value);
        emit Burn(from, to, amount);
    }

    function claim(address to, uint amount) external onlyOwner {
        require(
            totalSupply() / 10 >= amount + foundClaim, 
            "Claim too large"
        );

        foundClaim += amount;
        
        _mint(to, amount);
        emit Mint(to, amount);
    }

    function _transferValue(address to, uint amount) internal {
        require(
            address(this).balance >= amount, 
            "Treasury transfer exceeds balance"
        );
        (bool success, ) = to.call{value:amount}("");
        require(success, "Treasury transfer failed");
    }

    constructor(Treasury treasury_) 
    ERC20("FOUND", "FOUND") {}
}
