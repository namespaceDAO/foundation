// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./Origin.sol";
import "./Treasury.sol";

contract Found is ERC20, Origin, Treasury {
    uint private _totalValue;
    uint private _claimValue;
    uint private _claimFound;

    function mint(address to) external payable {
        require(msg.value > 0, "Must send more than 0 ETH");
        
        uint amount = msg.value;        // 1 token = 1 ETH
        _mint(to, amount);              // 1 to minter
        _mint(address(this), amount);   // 1 to treasury
        _totalValue += amount;
    }

    function treasuryMint(address to, uint amount) external onlyTreasurer {
        _mint(to, amount);              // 1 to minter
        _mint(address(this), amount);   // 1 to treasury
    }

    function treasuryTransfer(
        address from, 
        address to, 
        uint amount
    ) external onlyTreasurer {
        _transfer(from, to, amount);
    }

    function originClaim(
        address to, 
        uint value,
        uint found
    ) external onlyOrigin {
        uint maxValue = _totalValue / 10 - _claimValue; 
        uint maxFound = _totalValue / 10 - _claimFound;

        require(maxValue >= value, "Claim is too large");
        require(maxFound >= found, "Claim is too large");

        if (value > 0) {
            _transferValue(to, value);
            _claimValue += value;
        }

        if (found > 0) {
            _transfer(address(this), to, found);
            _claimFound += found;
        }
    }

    constructor() ERC20("FOUND", "FOUND") {}
}