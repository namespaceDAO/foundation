// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "../shared/Treasury.sol";

// TODO: spend allowance

abstract contract Ledger is Treasury, ERC1155 {
    uint private _bank;
    uint private _totalSupply;
    mapping(uint => uint) _totalSupplies;
    mapping(address => mapping(address => mapping(uint => uint))) private _allowances;

    event Approval(
        address indexed account, 
        address indexed spender, 
        uint indexed coinId, 
        uint value
    );

    function conversionRate(
        uint coinId, 
        uint amount
    ) virtual public view returns (uint);

    function deployedTokenTransfer(
        address from, 
        address to, 
        uint coinId, 
        uint amount
    ) virtual external;

    function decimals() virtual public view returns (uint8);

    function totalSupply() public view returns (uint) {
        return _totalSupply;
    }

    function totalSupplyOf(uint coinId) public view returns (uint) {
        return _totalSupplies[coinId];
    }

    function _beforeTokenTransfer(
        address to,
        address from,
        address,
        uint[] memory ids,
        uint[] memory amounts,
        bytes memory
    ) internal override {
        if (from != address(0)) {
            for (uint i = 0; i < ids.length; i++) {
                // TODO
                // _spendAllowance(from, to, ids[i], amounts[i]);
            }
        }
    }

    function _afterTokenTransfer(
        address,
        address from,
        address,
        uint[] memory ids,
        uint[] memory amounts,
        bytes memory
    ) internal override {
        if (from == address(0)) {
            for (uint i = 0; i < ids.length; i++) {
                uint id = ids[i];
                uint amount = amounts[i];
                _totalSupplies[id] += amount;
                _totalSupply += amount;
            }
        }
    }

    function allowance(
        address account, 
        address spender, 
        uint coinId
    ) external view returns (uint) {
        return _allowances[account][spender][coinId];
    }

    function approve(
        address spender, 
        uint amount, 
        uint coinId
    ) external {
        _approve(msg.sender, spender, coinId, amount);
    }

    function _approve(
        address account,
        address spender,
        uint coinId,
        uint amount
    ) internal {
        require(account != address(0), "Ledger: approve from the zero address");
        require(spender != address(0), "Ledger: approve to the zero address");

        _allowances[account][spender][coinId] = amount;
        emit Approval(account, spender, coinId, amount);
    }

    function _spendAllowance(
        address account,
        address spender,
        uint coinId,
        uint amount
    ) internal virtual {
        uint currentAllowance = _allowances[account][spender][coinId];
        if (currentAllowance != type(uint).max) {
            require(currentAllowance >= amount, "Ledger: insufficient allowance");
            unchecked {
                _approve(account, spender, coinId, currentAllowance - amount);
            }
        }

    }

    constructor(string memory baseURI_) ERC1155(baseURI_) {}  
}
