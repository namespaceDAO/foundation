// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./Ledger.sol";

contract Coin is IERC20 {
    Ledger private _ledger;
    uint private _coinId;

    function id() external view returns (uint) {
        return _coinId;
    }

    function name() external view returns (string memory) {
        return _ledger.nameOf(_coinId);
    }

    function symbol() external view returns (string memory) {
        return _ledger.symbolOf(_coinId);
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
    
    function allowance(address account, address spender) external view returns (uint) {
        return _ledger.allowance(account, spender, _coinId);
    }

    function transfer(address to, uint amount) external returns (bool) {
        _ledger.secretTransferFrom(msg.sender, to, _coinId, amount);
        return true;
    }

    function transferFrom(address from, address to, uint amount) external returns (bool) {
        _ledger.secretTransferFrom(from, to, _coinId, amount);
        return true;
    }

    function approve(address spender, uint amount) external returns (bool) {
        _ledger.secretApproveFrom(msg.sender, spender, amount, _coinId);
        return true;
    }

    constructor(Ledger ledger_, uint coinId_) {
        _ledger = ledger_;
        _coinId = coinId_;
    }
}
