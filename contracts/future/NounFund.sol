// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

struct FundParams {
    uint[] allowedCoins;
}

contract NounFund {
    uint private _worldId; 
    uint[] private _allowedCoins;

    function stake(address world) external {

    }

    constructor(uint worldId_, FundParams memory params) {
        _worldId = worldId_;
        _allowedCoins = params.allowedCoins;
    }
}
