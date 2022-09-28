// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

abstract contract Ledger is ERC1155 {
    uint private _bank;
    uint private _supply;
    mapping(uint => uint) _supplies;
    mapping(address => mapping(address => mapping(uint => uint))) private _allowances;

    event Approval(
        address indexed owner, 
        address indexed spender, 
        uint indexed coinId, 
        uint value
    );

    function decimals() virtual public view returns (uint8);

    function totalSupply() public view returns (uint) {
        return _supply;
    }

    function totalSupplyOf(uint coinId) public view returns (uint) {
        return _supplies[coinId];
    }

    function allowance(
        address owner, 
        address spender,
        uint coinId
    ) external view returns (uint) {
        return _allowances[owner][spender][coinId];
    }

    function approve(
        address spender, 
        uint amount, 
        uint coinId
    ) external {
        _approve(msg.sender, spender, coinId, amount);
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
                _supplies[ids[i]] += amounts[i];
                _supply += amounts[i];
            }
        }
    }

    function _beforeTokenTransfer(
        address spender,
        address from,
        address to,
        uint[] memory ids,
        uint[] memory amounts,
        bytes memory
    ) internal override {
        if (from != address(0) && from != spender) {
            for (uint i = 0; i < ids.length; i++) {
                _spendAllowance(from, spender, ids[i], amounts[i]);
            }
        }
    }

    function _spendAllowance(
        address owner,
        address spender,
        uint coinId,
        uint amount
    ) internal virtual {
        uint currentAllowance = _allowances[owner][spender][coinId];
        if (currentAllowance != type(uint).max) {
            require(currentAllowance >= amount, "Ledger: insufficient allowance");
            _approve(owner, spender, coinId, currentAllowance - amount);
        }
    }

    function _approve(
        address owner,
        address spender,
        uint coinId,
        uint amount
    ) internal {
        require(owner != address(0), "Cannot approve from the zero address");
        require(spender != address(0), "Cannot approve to the zero address");

        _allowances[owner][spender][coinId] = amount;
        emit Approval(owner, spender, coinId, amount);
    }

    function deployedTokenTransfer(
        address from, 
        address to, 
        uint coinId, 
        uint amount
    ) virtual external;

    constructor(string memory baseURI_) ERC1155(baseURI_) {}  
}
