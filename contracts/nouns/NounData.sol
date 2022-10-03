// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import { Strings } from '@openzeppelin/contracts/utils/Strings.sol';
import "@openzeppelin/contracts/utils/Base64.sol";
import "./shared.sol";

contract NounData {
    using Strings for uint;
    using Strings for uint8;
    using Strings for address;

    uint private _nounCount;
    mapping(uint => Noun) private _nouns;

    string private constant _SVG_START_TAG = '<svg width="420" height="420" viewBox="0 0 255 255" xmlns="http://www.w3.org/2000/svg" shape-rendering="crispEdges">';
    string private constant _SVG_END_TAG = '</svg>';

    event NounSubmitted(
        uint id,
        string name,
        address creator,
        uint64[] image,
        string[] traits
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
        return string(_generateSVG(noun.image));
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
        bytes memory traits;
       
        for (uint i = 0; i < noun.traits.length; i += 1) {
            traits = abi.encodePacked(traits, ',', noun.traits[i], ',');
        }

        return abi.encodePacked(
            '{',
                '"id":"', noun.id.toString(), '",',
                '"name":"', noun.name, '",',
                '"description":"', noun.name, ' is a Noun coin.",',
                '"traits":[', string(traits), '],',
                '"image":"', string(
                    abi.encodePacked(
                        'data:image/svg+xml;base64,', 
                        Base64.encode(_generateSVG(noun.image))
                    )
                ), '"',
            '}'
        );
    }

    function submitNoun(NounParams memory params) external {
        require(
            params.image.length < 256 * 256,
            "Noun too large"
        );

        Noun storage noun = _nouns[++_nounCount];

        noun.id = _nounCount;
        noun.name = params.name;
        noun.image = params.image;
        noun.creator = params.creator;
        noun.traits = params.traits;

        emit NounSubmitted(
            noun.id, 
            noun.name, 
            noun.creator,
            noun.image,
            noun.traits
        );
    }

    function _generateSVG(uint64[] memory image) internal view returns (bytes memory) {
        bytes memory chunk;
       
        for (uint i = 0; i < image.length; i += 1) {
            chunk = abi.encodePacked(chunk, _generateSVGPart(image[i]));
        }
       
        return abi.encodePacked(
            _SVG_START_TAG, 
            string(chunk), 
            _SVG_END_TAG
        );
    }

    function _generateSVGPart(uint64 part) internal pure returns (bytes memory) {
        uint8 x = uint8(part >> 56);
        uint8 y = uint8(part >> 48);
        uint8 w = uint8(part >> 40);
        uint8 h = uint8(part >> 32);
        uint8 r = uint8(part >> 24);
        uint8 g = uint8(part >> 16);
        uint8 b = uint8(part >> 8);
        uint8 a = uint8(part);

        return abi.encodePacked(
            '<rect',
                ' width="', w.toString(), '"',
                ' height="', h.toString(), '"',
                ' x="', x.toString(), '"',
                ' y="', y.toString(), '"',
                ' fill="rgba(',
                    r.toString(), ',',
                    g.toString(), ',',
                    b.toString(), ',',
                    a.toString(),
                ')"',
            '/>'
        );
    }
}