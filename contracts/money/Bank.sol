// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "./Ledger.sol";
import "./Coin.sol";

abstract contract Bank is Ledger {
    mapping(uint => Coin) private _coins;

    function addressOf(uint coinId) external view returns (Coin) {
        require(
            address(_coins[coinId]) != address(0), 
            "Coin has not been deployed"
        );

        return _coins[coinId];
    }

    function _deployCoin(uint coinId) internal returns (Coin) {
        require(
            address(_coins[coinId]) == address(0), 
            "Coin has already been deployed"
        );

        _coins[coinId] = new Coin(Ledger(this), coinId);
        return _coins[coinId];
    }

    function _requireCoinCaller(uint coinId) internal view {
        require(
            _coins[coinId] == Coin(msg.sender) && msg.sender != address(0),
            "Caller is not an approved coin"
        );
    }

    constructor(string memory baseURI_) Ledger(baseURI_) {}
}
