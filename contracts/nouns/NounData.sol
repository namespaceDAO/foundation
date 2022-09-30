// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

// import { Base64 } from 'base64-sol/base64.sol';

struct NounParams {
    string name;
    bytes pixels;
    address creator;
}

struct Noun {
    uint id;
    string name;
    bytes pixels;
    address creator;
}

contract NounData {
    uint private _nounCount;
    mapping(uint => Noun) private _nouns;

    event NounAdded(
        uint id,
        string name,
        bytes pixels,
        address creator
    );

    function nounCount() public view returns (uint) {
        return _nounCount;
    }

    function getNoun(uint id) public view returns (Noun memory) {
        requireNoun(id);
        return _nouns[id];
    }
    
    function tokenURI(uint tokenId) public pure returns (string memory) {
        return "";
    }

    function addNoun(NounParams memory params) external {
        Noun storage noun = _nouns[++_nounCount];
        noun.id = _nounCount;
        noun.name = params.name;
        noun.pixels = params.pixels;
        noun.creator = params.creator;
        emit NounAdded(noun.id, noun.name, noun.pixels, noun.creator);
    }

    function requireNoun(uint id) public view {
        require(id <= _nounCount, "Noun not found");
    }
}