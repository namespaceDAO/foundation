// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorPreventLateQuorum.sol";

contract Nouner is ERC721 {
    uint private _coinId;

    modifier onlyNouner() {
        require(balanceOf(msg.sender) > 0, "You are not a Nouner");
        _;
    }

    constructor(
        string memory name_,
        string memory symbol_,
        uint coinId_
    ) ERC721(name_, symbol_) {
        _coinId = coinId_;
    }
}