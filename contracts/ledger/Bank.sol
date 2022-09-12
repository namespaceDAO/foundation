// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "./Ledger.sol";
import "./Token.sol";

abstract contract Bank is Ledger {
    mapping(uint => Token) private _tokens;

    function canonicalToken(uint coinId) external view returns (Token) {
        Token token = _tokens[coinId];
        _requireDeployed(token);
        return token;
    }

    // TOOD: fetch symbol
    function deployToken(uint coinId, string memory symbol) external {
        Token token = _tokens[coinId];
        _requireNotDeployed(token);
        _tokens[coinId] = new Token(Ledger(this), coinId, symbol);
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
