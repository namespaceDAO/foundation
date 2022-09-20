// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./Origin.sol";
import "./Treasury.sol";

contract Token is Origin, ERC20, Treasury {
    uint private _valueClaim;
    uint private _tokenClaim;
    uint private _totalValue;

    event ClaimValue(address indexed to, uint value);
    event ClaimToken(address indexed to, uint token);

    function tokenBalance() public view returns (uint) {
        return balanceOf(address(this));
    }

    function claimValue(address to, uint value) external onlyOrigin {
        require(
            valueBalance() >= value, 
            "Value claim too large"
        );

        require(
            _totalValue / 10 >= value + _valueClaim, 
            "Value claim too large"
        );
        
        _valueClaim += value;
        _pushValue(to, value);
        emit ClaimValue(to, value);
    }

    function claimToken(address to, uint token) external onlyOrigin {
        require(
            tokenBalance() >= token, 
            "Token claim too large"
        );

        require(
            totalSupply() / 20 >= token + _tokenClaim, 
            "Token claim too large"
        );
        
        _tokenClaim += token;
        _transfer(address(this), to, token);
        emit ClaimToken(to, token);
    }

    function _mintToken(address to, uint amount) internal {
        _mint(to, amount); 
        _mint(address(this), amount);
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