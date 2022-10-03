// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./Bank.sol";

contract Coin is IERC20 {
    Bank private _bank;
    uint private _coin;

    function id() external view returns (uint) {
        return _coin;
    }

    function name() external view returns (string memory) {
        return _bank.nameOf(_coin);
    }

    function symbol() external view returns (string memory) {
        return _bank.symbolOf(_coin);
    }

    function decimals() external view returns (uint8) {
        return _bank.decimals();
    }

    function totalSupply() external view returns (uint) {
        return _bank.totalSupplyOf(_coin);
    }

    function balanceOf(address account) external view returns (uint) {
        return _bank.balanceOf(account, _coin);
    }
    
    function allowance(address account, address spender) external view returns (uint) {
        return _bank.allowance(account, spender, _coin);
    }

    function transfer(address to, uint amount) external returns (bool) {
        _bank.safeTransferFrom(msg.sender, to, _coin, amount, new bytes(0));
        return true;
    }

    function transferFrom(address from, address to, uint amount) external returns (bool) {
        _bank.safeTransferFrom(from, to, _coin, amount, new bytes(0));
        return true;
    }

    function approve(address spender, uint amount) external returns (bool) {
        _bank.approve(spender, amount, _coin);
        return true;
    }

    constructor(Bank bank_, uint coin_) {
        _bank = bank_;
        _coin = coin_;
    }
}
