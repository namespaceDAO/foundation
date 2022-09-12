// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./Ledger.sol";

contract Token is IERC20 {
    Ledger private _ledger;
    uint private _coinId;
    string private _symbol;

    mapping(address => mapping(address => mapping(uint => uint))) private _allowances;

    function id() external view returns (uint) {
        return _coinId;
    }

    function name() external view returns (string memory) {
        return _symbol;
    }

    function symbol() external view returns (string memory) {
        return _symbol;
    }

    function decimals() external view returns (uint8) {
        return _ledger.decimals();
    }

    function totalSupply() external view returns (uint) {
        return _ledger.totalSupplyOf(_coinId);
    }

    function balanceOf(address account) external view returns (uint) {
        return _ledger.balanceOf(account, _coinId);
    }

    function transfer(address to, uint amount) external returns (bool) {
        _ledger.deployedTokenTransfer(msg.sender, to, _coinId, amount);
        return true;
    }

    function transferFrom(address from, address to, uint amount) external returns (bool) {
        _ledger.deployedTokenTransfer(from, to, _coinId, amount);
        return true;
    }

    function allowance(address account, address spender) external view returns (uint) {
        return _ledger.allowance(account, spender, _coinId);
    }

    function approve(address spender, uint amount) external returns (bool) {
        _ledger.approve(spender, amount, _coinId);
        return true;
    }

    constructor(
        Ledger ledger_, 
        uint coinId_,
        string memory symbol_
    ) {
        _ledger = ledger_;
        _coinId = coinId_;
        _symbol = symbol_;
    }
}
