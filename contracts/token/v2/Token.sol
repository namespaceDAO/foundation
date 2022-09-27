// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "../Origin.sol";

contract Token2 is ERC20, Origin {
    uint private _valueClaim;
    uint private _tokenClaim;
    uint private _totalValue;

    event ClaimValue(address indexed to, uint value, string memo);
    event ClaimToken(address indexed to, uint token, string memo);

    receive() external payable {}
    fallback() external payable {}

    function _addValue(uint value) internal {
        _totalValue += value;
    }

    function tokenBalance() public view returns (uint) {
        return balanceOf(address(this));
    }

    function totalValue() external view returns (uint) {
        return _totalValue;
    }

    function valueBalance() public view returns (uint) {
        return address(this).balance;
    }

    function _pushValue(address to, uint amount) internal {
        require(
            address(this).balance >= amount, 
            "Treasury transfer exceeds balance"
        );
        (bool success, ) = to.call{value:amount}("");
        require(success, "Treasury transfer failed");
    }

    function claimedValue() external view returns (uint) {
        return _valueClaim;
    }

    function claimedToken() external view returns (uint) {
        return _tokenClaim;
    }

    function claimValue(address to, uint value, string memory memo) external onlyOrigin {
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
        emit ClaimValue(to, value, memo);
    }

    function claimToken(address to, uint token, string memory memo) external onlyOrigin {
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
        emit ClaimToken(to, token, memo);
    }

    constructor(string memory name_, 
                string memory symbol_, 
                address origin_) 
    ERC20(name_, symbol_) 
    Origin(origin_) {}
}