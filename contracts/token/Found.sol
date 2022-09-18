// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import "./OriginToken.sol";
import "./Treasury.sol";

contract Found is OriginToken, Treasury {

    function foundBalance() public view returns (uint) {
        return balanceOf(address(this));
    }

    function mint(address to) external payable {
        require(msg.value > 0, "Must send more than 0 ETH");
        uint amount = msg.value;        // 1 token = 1 ETH
        _mint(to, amount);              // 1 to minter
        _mint(address(this), amount);   // 1 to treasury
        _addValue(amount);
    }

    function treasuryMint(address to, uint amount) external onlyTreasurer {
        _mint(to, amount);              // 1 to minter
        _mint(address(this), amount);   // 1 to treasury
    }

    function pullFound(address to,  uint amount) external onlyTreasurer {
        _transfer(address(this), to, amount);
    }

    function pushFound(address from, uint amount) external onlyTreasurer {
        _transfer(from, address(this), amount);
    }

    constructor() OriginToken() {}
}