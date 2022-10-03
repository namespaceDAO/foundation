// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "../money/Coin.sol";

contract NounCoin is Coin {
    constructor(Bank bank_, uint coinId_) Coin(bank_, coinId_) {}
}

interface NounBase {
    function currentDay() virtual external view returns (uint);
    function coinToNoun(uint coinId) virtual external view returns (Noun memory);
}

struct NounParams {
    string name;
    address creator;
    uint64[] parts;
}

struct Noun {
    uint id;
    string name;
    address creator;
    uint64[] parts;
}
