// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

contract Origin {
    address private _address;
    address private _provenance; 

    event MoveOrigin(address indexed previousAddress, address indexed newAddress);
    event RelinquishOrigin(address provenance);

    modifier onlyOrigin() {
        bool active = _address == msg.sender && _address != address(0);
        require(active, "Origin: caller is not the origin");
        _;
    }

    function originAddress() public view returns (address) { 
        return _address; 
    }    
    
    function originProvenance() public view returns (address) { 
        return _provenance; 
    }

    function moveOrigin(address newAddress) external onlyOrigin {
        address previousAddress = _address;
        _address = newAddress;
        emit MoveOrigin(previousAddress, newAddress);
    }

    function relinquishOrigin() external onlyOrigin {
        _provenance = _address;
        _address = address(0);
        emit RelinquishOrigin(_provenance);
    }

    constructor() {
        _address = msg.sender;
    }
}