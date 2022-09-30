// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "../money/Coin.sol";

contract NounCoin is Coin {
    constructor(Bank bank_, uint coinId_) Coin(bank_, coinId_) {}
}
