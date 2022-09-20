// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import "./Brachistochrone.sol";
import "./Token.sol";

contract Found is Brachistochrone, Token {
    event Mint(address indexed to, uint value, uint found);

    function mint(address to) external payable {
        require(msg.value > 0, "Must send more than 0 ETH");
        uint amount = consumeChronos(msg.value);
        
        _mintToken(to, amount);
        _addValue(msg.value);

        emit Mint(to, msg.value, amount);
    }

    function foundBalance() external view returns (uint) {
        return balanceOf(address(this));
    }

    function pushFound(address to,  uint amount) external onlyTreasurer {
        _transfer(address(this), to, amount);
    }

    function pullFound(address from, uint amount) external onlyTreasurer {
        _transfer(from, address(this), amount);
    }

    function treasuryMint(address to, uint amount) external onlyTreasurer {
        _mintToken(to, amount);
    }

    constructor(address origin_, uint lightning_) 
    Token("FOUND", "FOUND", origin_)
    Brachistochrone(lightning_) {}
}