// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "../money/Coin.sol";

abstract contract NounBased {
    function coinToNoun(uint coinId) virtual public view returns (Noun memory);
}

struct NounParams {
    string name;
    address creator;
    uint64[] shapes;
    string[] traits;
}

struct Noun {
    uint id;
    string name;
    address creator;
    uint64[] shapes;
    string[] traits;
}
