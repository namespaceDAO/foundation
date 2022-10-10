// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract NounGood {
    IERC20 private _cash;

    function pay(address payee, uint amount) external {
        _cash.transferFrom(address(this), payee, amount);
    } 
}
