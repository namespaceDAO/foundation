// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/finance/PaymentSplitter.sol";
import "../token/Found.sol";

contract FoundShare is ERC721 {
    Found private _found;
    
    function startStake(uint amount) external {
        _found.transfer(address(this), amount);
        // Store the stake
    }

    function endStake(uint amount) external returns (uint) {
        _found.transfer(address(this), amount);
        // Store the stake
        return 0;
    }

    constructor(
        Found found_,
        string memory name_,
        string memory symbol_
    ) ERC721(name_, symbol_) {
        _found = found_;
    }
}