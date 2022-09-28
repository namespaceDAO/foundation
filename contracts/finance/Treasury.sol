// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// Treasury is a contract that can hold and transfer ETH
contract Treasury is Ownable {
    receive() external payable {}
    fallback() external payable {}

    function currentBalance() public view returns (uint) {
        return address(this).balance;
    } 

    function transferValue(address to, uint amount) external onlyOwner {
        _transferValue(to, amount);
    }

    function _transferValue(address to, uint amount) internal {
        require(
            address(this).balance >= amount, 
            "Treasury transfer exceeds balance"
        );
        (bool success, ) = to.call{value:amount}("");
        require(success, "Treasury transfer failed");
    }
}