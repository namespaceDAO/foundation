// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "../money/Coin.sol";

interface NounBase {
    function coinToNoun(uint coinId) external view returns (uint nounId);
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

struct NoteParams {
    uint nounId;
    uint amount; 
    uint expiresAt;
}

struct Note {
    uint id;
    uint nounId;
    uint amount;
    uint expiresAt;
    uint startedAt;
    uint endedAt;
}
