// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./Origin.sol";
import "./Treasury.sol";

contract Token is Origin, ERC20 {
    uint private _totalValue;
    uint private _claimValue;
    uint private _claimFound;

    event Claim(address indexed to, uint value, uint found);

    function _addValue(uint value) internal {
        _totalValue += value;
    }

    function _transferValue(address to, uint amount) internal {
        require(
            address(this).balance >= amount, 
            "Treasury: transfer exceeds treasury balance"
        );

        (bool success, ) = to.call{value:amount}("");
        require(success, "Treasury: transfer failed");
    }

    function originClaim(
        address to, uint value, uint found
    ) external onlyOrigin {
        if (value > 0) {
            uint maxValue = _totalValue / 10 - _claimValue;
            require(maxValue >= value, "Value claim is too large");
            _transferValue(to, value);
            _claimValue += value;
        }

        if (found > 0) {
            uint maxFound = totalSupply() / 20 - _claimFound;
            require(maxFound >= found, "Found claim is too large");
            _transfer(address(this), to, found);
            _claimFound += found;
        }

        emit Claim(to, value, found);
    }

    constructor() ERC20("FOUND", "FOUND") {}
}