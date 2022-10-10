// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "../money/Coin.sol";

interface Nounish {
    function coinToNoun(uint coinId) virtual external view returns (uint nounId);
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
    address founder;
    address owner;
    uint idea;
    uint amount; 
    uint expiresAt;
}

struct Note {
    uint id;
    uint idea;
    uint amount;
    uint expiresAt;
    uint startedAt;
    uint endedAt;
    address founder;
    address redeemer;
    address payee;
}
