// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import { Strings } from '@openzeppelin/contracts/utils/Strings.sol';
import "@openzeppelin/contracts/utils/Base64.sol";
import "./NounView.sol";
import "./shared.sol";

contract NounData is NounView {
    using Strings for uint;
    using Strings for address;

    uint private _nounCount;

    mapping(uint => Noun) private _nouns;

    event NounSubmitted(
        uint id,
        string name,
        address creator,
        uint64[] parts
    );

    function nounCount() public view returns (uint) {
        return _nounCount;
    }

    function getNoun(uint id) public view returns (Noun memory) {
        require(id <= _nounCount, "Noun not found");
        return _nouns[id];
    }

    function nounJSON(uint nounId) external view returns (string memory) {
        return string(_nounJSON(nounId));
    }

    function nounSVG(uint nounId) external view returns (string memory) {
        Noun memory noun = getNoun(nounId); 
        return string(_generateSVG(noun.parts));
    }
    
    function nounURI(uint nounId) public view returns (string memory) {
        return string(
            abi.encodePacked(
                'data:application/json;base64,',
                Base64.encode(_nounJSON(nounId))
            )
        );
    }

    function _nounJSON(uint nounId) public view returns (bytes memory) {
        Noun memory noun = getNoun(nounId); 

        return abi.encodePacked(
            '{',
                '"id":"', noun.id.toString(), '",',
                '"name":"', noun.name, '",',
                '"description":"', noun.name, ' is a Noun coin.",',
                '"image":"', string(
                    abi.encodePacked(
                        'data:image/svg+xml;base64,', 
                        Base64.encode(_generateSVG(noun.parts))
                    )
                ), '"',
            '}'
        );
    }

    function submitNoun(NounParams memory params) external {
        require(
            params.parts.length < 256 * 256,
            "Noun too large"
        );

        Noun storage noun = _nouns[++_nounCount];

        noun.id = _nounCount;
        noun.name = params.name;
        noun.parts = params.parts;
        noun.creator = params.creator;

        emit NounSubmitted(
            noun.id, 
            noun.name, 
            noun.creator,
            noun.parts
        );
    }
}