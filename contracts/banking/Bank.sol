// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "./Ledger.sol";
import "./Coin.sol";

abstract contract Bank is Ledger {
    address private _admin;
    mapping(uint => Coin) private _coins;

    modifier onlyAdmin() {
        require(msg.sender == _admin, "Caller is not the admin");
        _;
    }

    function addressOf(uint coinId) external view returns (Coin) {
        require(
            address(_coins[coinId]) != address(0), 
            "Bank coin has not been deployed"
        );

        return _coins[coinId];
    }

    function deployCoin(uint coinId) external returns (Coin) {
        require(
            address(_coins[coinId]) == address(0), 
            "Bank coin has already been deployed"
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

    constructor(
        address admin_,
        string memory baseURI_
    ) Ledger(baseURI_) {
        _admin = admin_;
    }
}
