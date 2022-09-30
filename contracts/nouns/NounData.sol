// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

// import { Base64 } from 'base64-sol/base64.sol';

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
    
    function tokenURI(uint tokenId) public view returns (string memory) {
        return "";
    }

    function addNoun(
        string memory name,
        bytes memory pixels,
        address creator
    ) external {
        Noun storage noun = _nouns[++_nounCount];
        noun.id = _nounCount;
        noun.name = name;
        noun.pixels = pixels;
        noun.creator = creator;
        emit NounAdded(noun.id, name, pixels, noun.creator);
    }

    function requireNoun(uint id) public view {
        require(id <= _nounCount, "Noun not found");
    }
}