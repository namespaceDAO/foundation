// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./Claimable.sol";
import "./Treasury.sol";

contract Found is ERC20, Claimable, Treasury {
    function mint(address to) external payable {
        require(msg.value > 0, "Must send more than 0 ETH");
        
        uint amount = msg.value;        // 1 token = 1 ETH
        _mint(to, amount);              // 1 to minter
        _mint(address(this), amount);   // 1 to treasury

        _addValue(amount);
    }

    function treasuryMint(address to, uint amount) external onlyTreasurer {
        _mint(to, amount);              // 1 to minter
        _mint(address(this), amount);   // 1 to treasury
    }

    function treasuryTransfer(
        address from, 
        address to, 
        uint amount
    ) external onlyTreasurer {
        _transfer(from, to, amount);
    }

    constructor() ERC20("FOUND", "FOUND") {}
}