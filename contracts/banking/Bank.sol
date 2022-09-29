// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "./Ledger.sol";
import "./Coinage.sol";

// TODO: fetch name and symbol

abstract contract Bank is Ledger {
    mapping(uint => Coin) private _coins;

    function coinAddress(uint coinId) external view returns (Coin) {
        Coin coin = _coins[coinId];
        _requireDeployed(coin);
        return coin;
    }

    function deployCoin(
        uint coinId, 
        string memory symbol
    ) external returns (Coin) {
        _requireNotDeployed(_coins[coinId]);
        _coins[coinId] = new Coin(Ledger(this), coinId, symbol);
        return _coins[coinId];
    }

    function deployedTokenTransfer(
        address from, 
        address to, 
        uint coinId, 
        uint amount
    ) virtual external override {
        require(
            _coins[coinId] == Coin(msg.sender) && msg.sender != address(0),
            "Ledger: sender is not an approved coin"
        );

        bytes memory data;
        _safeTransferFrom(from, to, coinId, amount, data);
    }

    function _requireNotDeployed(Coin coin) internal pure {
        require(!_isDeployed(coin), "Bank: coin has already been deployed");
    }

    function _requireDeployed(Coin coin) internal pure {
        require(_isDeployed(coin), "Bank: coin has not been deployed");
    }

    function _isDeployed(Coin coin) internal pure returns (bool) {
        return address(coin) != address(0);
    }

    constructor(string memory baseURI_) Ledger(baseURI_) {}
}
