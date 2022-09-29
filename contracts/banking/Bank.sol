// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "./Ledger.sol";
import "./Coin.sol";

abstract contract Bank is Ledger {
    mapping(uint => Coin) private _coins;

    function addressOf(uint coinId) external view returns (Coin) {
        _requireDeployed(coinId);
        return _coins[coinId];
    }

    function deployCoin(uint coinId) external returns (Coin) {
        _requireNotDeployed(coinId);
        _coins[coinId] = new Coin(Ledger(this), coinId);
        return _coins[coinId];
    }

    function secretTransferFrom(
        address from, 
        address to, 
        uint coinId, 
        uint amount
    ) virtual external override {
        bytes memory data;
        _requireCoinCaller(coinId);
        _safeTransferFrom(from, to, coinId, amount, data);
    }

    function secretApproveFrom(
        address from, 
        address spender, 
        uint coinId, 
        uint amount
    ) virtual external override {
        _requireCoinCaller(coinId);
        _approve(msg.sender, spender, coinId, amount);
    }

    function _requireCoinCaller(uint coinId) internal view {
        require(
            _coins[coinId] == Coin(msg.sender) && msg.sender != address(0),
            "Caller is not an approved coin"
        );
    }

    function _requireNotDeployed(uint coinId) internal view {
        require(
            address(_coins[coinId]) == address(0), 
            "Bank coin has already been deployed"
        );
    }

    function _requireDeployed(uint coinId) internal view {
        require(
            address(_coins[coinId]) != address(0), 
            "Bank coin has not been deployed"
        );
    }

    constructor(string memory baseURI_) Ledger(baseURI_) {}
}
