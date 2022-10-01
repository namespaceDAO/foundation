// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "../money/Coin.sol";

contract NounCoin is Coin {
    constructor(Bank bank_, uint coinId_) Coin(bank_, coinId_) {}
}

abstract contract NounBase {
    function currentDay() virtual public view returns (uint);
    function coinToNoun(uint coinId) virtual public view returns (uint);
}
