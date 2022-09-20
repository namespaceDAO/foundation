// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import "./Brachistochrone.sol";
import "./Treasury.sol";
import "./Token.sol";

contract Found is Brachistochrone, Treasury, Token {
    function mint(address to) external payable {
        require(msg.value > 0, "Must send more than 0 ETH");
        uint amount = calculateMintAmount(msg.value);
        _mintFound(to, amount);
        _addValue(msg.value);
    }

    function foundBalance() public view returns (uint) {
        return balanceOf(address(this));
    }

    function treasuryMint(address to, uint amount) external onlyTreasurer {
        _mintFound(to, amount);
    }

    function pushFound(address to,  uint amount) external onlyTreasurer {
        _transfer(address(this), to, amount);
    }

    function pullFound(address from, uint amount) external onlyTreasurer {
        _transfer(from, address(this), amount);
    }

    function _mintFound(address to, uint amount) internal {
        _mint(to, amount); 
        _mint(address(this), amount);
    }

    constructor(address origin_, bool flash_) 
    Token("FOUND", "FOUND", origin_)
    Brachistochrone(flash_) {}
}