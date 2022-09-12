// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import { ERC721 } from '@openzeppelin/contracts/token/ERC721/ERC721.sol';
import "../daos/nouns/NounsDescriptor.sol";

contract MockDescriptor is NounsDescriptor {
    uint private _heads;

    function heads(uint) external pure returns (bytes memory) {
        bytes memory data;
        return data;
    }

    function headCount() external view returns (uint) {
        return _heads;
    }

    constructor(uint heads_) {
        _heads = heads_;
    }
}
