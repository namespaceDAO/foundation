// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Token is ERC20 {
    address private _address;
    address private _provenance; 

    uint private _totalValue;
    uint private _claimValue;
    uint private _claimFound;

    event ClaimFound(address indexed to, uint found);
    event ClaimValue(address indexed to, uint value);

    event UpdateOrigin(address indexed to);
    event RelinquishOrigin(address provenance);

    modifier onlyOrigin() {
        bool active = _address == msg.sender && _address != address(0);
        require(active, "Origin: caller is not the origin");
        _;
    }

    function _addValue(uint value) internal {
        _totalValue += value;
    }

    function originAddress() public view returns (address) { 
        return _address; 
    }    
    
    function originProvenance() public view returns (address) { 
        return _provenance; 
    }

    function updateOrigin(address to) external onlyOrigin {
        _address = to;
        emit UpdateOrigin(to);
    }

    function relinquishOrigin() external onlyOrigin {
        _provenance = _address;
        _address = address(0);
        emit RelinquishOrigin(_provenance);
    }

    function claimValue(address to, uint value) external onlyOrigin {
        uint maxValue = _totalValue / 10 - _claimValue;
        require(maxValue >= value, "Value claim is too large");
        (bool success, ) = to.call{value:value}("");
        require(success, "Treasury: transfer failed");
        _claimValue += value;
    }

    function claimFound(address to, uint found) external onlyOrigin {
        uint maxFound = totalSupply() / 20 - _claimFound;
        require(maxFound >= found, "Found claim is too large");
        _transfer(address(this), to, found);
        _claimFound += found;
        emit ClaimFound(to,found);
    }


    constructor() ERC20("FOUND", "FOUND") {
        _address = msg.sender;
    }
}