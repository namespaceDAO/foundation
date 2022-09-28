// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./Presale.sol";

contract Found is Ownable, Presale, ERC20 {
    uint foundClaim;

    event Mint(
        address indexed to, 
        uint value, 
        uint found    
    );

    event Burn(
        address indexed from, 
        address indexed to,
        uint value, 
        uint found    
    );

    event Claim(
        address indexed to, 
        uint found,
        string memo 
    );
   
    receive() external payable {}
    fallback() external payable {}

    function burnValue(uint amount) public view returns (uint) {
        uint balance = address(this).balance;
        uint supply = totalSupply();
        return amount * balance / supply;
    }

    function forge(address from, address to, uint amount) external {
        uint forged = _forgeFound(from, amount);
        _mint(to, forged);
        emit Forge(from, to, amount, forged);
    }

    function mint(address to) external payable {
        require(msg.value > 0, "Send more than 0");
        uint amount = msg.value;
        _mint(to, amount);
        emit Mint(to, msg.value, amount);
    }

    function burn(address from, address to, uint amount) external {
        require(amount > 0, "Burn more than 0");

        uint value = burnValue(amount);
        
        _burn(from, amount);
        _transferValue(to, value);

        emit Burn(from, to, value, amount);
    }

    function claim(address to, uint amount, string memory memo) external onlyOwner {
        require(
            totalSupply() / 10 >= amount + foundClaim, 
            "Claim too large"
        );

        foundClaim += amount;
        _mint(to, amount);
        emit Claim(to, amount, memo);
    }

    function _transferValue(address to, uint amount) internal {
        require(
            address(this).balance >= amount, 
            "Treasury transfer exceeds balance"
        );
        (bool success, ) = to.call{value:amount}("");
        require(success, "Treasury transfer failed");
    }

    constructor() ERC20("FOUND", "FOUND") {}
}
