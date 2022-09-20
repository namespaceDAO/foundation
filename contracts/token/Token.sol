// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./Origin.sol";

contract Token is ERC20, Origin {
    uint private _valueClaim;
    uint private _foundClaim;
    uint private _totalValue;

    event ClaimFound(address indexed to, uint found);
    event ClaimValue(address indexed to, uint value);

    function claimValue(address to, uint value) external onlyOrigin {
        uint maxValue = _totalValue / 10 - _valueClaim;
        require(maxValue >= value, "Value claim is too large");
        
        _valueClaim += value;
        (bool success, ) = to.call{value:value}("");
        require(success, "Treasury: transfer failed");
        
        emit ClaimValue(to, value);
    }

    function claimFound(address to, uint found) external onlyOrigin {
        uint maxFound = totalSupply() / 20 - _foundClaim;
        require(maxFound >= found, "Found claim is too large");
        
        _foundClaim += found;
        _transfer(address(this), to, found);

        emit ClaimFound(to, found);
    }

    function _addValue(uint value) internal {
        _totalValue += value;
    }

    constructor(string memory name_, 
                string memory symbol_, 
                address origin_) 
    ERC20(name_, symbol_) 
    Origin(origin_) {}
}