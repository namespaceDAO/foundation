// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

abstract contract NounBase {
    function currentDay() virtual public view returns (uint);
    function coinToNoun(uint coinId) virtual public view returns (uint);
}
