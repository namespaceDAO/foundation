// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract OriginToken is ERC20 {
    address private _address;
    address private _provenance; 
    uint private _totalValue;
    uint private _claimValue;
    uint private _claimFound;

    event Claim(address indexed to, uint value, uint found);

    event MoveOrigin(address indexed previousAddress, address indexed newAddress);
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

    function originClaim(
        address to, 
        uint value,
        uint found
    ) external onlyOrigin {
        if (value > 0) {
            uint maxValue = _totalValue / 10 - _claimValue;
            require(maxValue >= value, "Value claim is too large");
            (bool success, ) = to.call{value:value}("");
            require(success, "Treasury: transfer failed");
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

    constructor() ERC20("FOUND", "FOUND") {
        _address = msg.sender;
    }
}