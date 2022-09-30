// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

// import { Base64 } from 'base64-sol/base64.sol';
import "./Nounish.sol";

contract NounBase is Nounish {

    function tokenURI(uint tokenId) public view returns (string memory) {
        return "";
    }
}
