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
        Coin coin = _coins[coinId];
        _requireNotDeployed(coin);
        
        Coin token = new Coin(Ledger(this), coinId, symbol);
        _coins[coinId] = coin;

        return coin;
    }

    function deployedTokenTransfer(
        address from, 
        address to, 
        uint coinId, 
        uint amount
    ) virtual external override {
        require(
            _tokens[coinId] == Token(msg.sender) && msg.sender != address(0),
            "Ledger: sender is not an approved token"
        );

        bytes memory data;
        _safeTransferFrom(from, to, coinId, amount, data);
    }

    function _requireNotDeployed(Token token) internal pure {
        require(!_isDeployed(token), "Bank: token has already been deployed");
    }

    function _requireDeployed(Token token) internal pure {
        require(_isDeployed(token), "Bank: token has not been deployed");
    }

    function _isDeployed(Token token) internal pure returns (bool) {
        return address(token) != address(0);
    }

    constructor(string memory baseURI_) Ledger(baseURI_) {}
}
