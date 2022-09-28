// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface Treasury is IERC20 {
    function pushValue(address to, uint amount) external;
    function pullToken(address from, uint amount) external;
}

abstract contract Presale is IERC20 {
    Treasury private _treasury;

    event Forge(address indexed from, address indexed to, uint amount, uint created);

    function _forgeFound(address from, uint amount) internal returns (uint) {
        require(
            block.timestamp < 1666666667 + 696969,
            "Forge is closed"
        );

        uint balance = address(_treasury).balance;
        uint circulating = _circulatingSupply();
        uint value = balance * amount / circulating;

        _treasury.pullToken(from, amount);
        _treasury.pushValue(address(this), value);

        return 2 * value;
    }

    function _circulatingSupply() internal view returns (uint) {
        uint balance = _treasury.balanceOf(address(_treasury));
        uint supply = _treasury.totalSupply();
        return supply - balance;
    }

    constructor(Treasury treasury_) {
        _treasury = treasury_;
    }
}
