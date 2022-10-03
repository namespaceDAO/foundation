// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import { Strings } from '@openzeppelin/contracts/utils/Strings.sol';
import "@openzeppelin/contracts/utils/Base64.sol";
import "./shared.sol";

contract NounData {
    using Strings for uint;
    using Strings for uint8;
    using Strings for uint64;
    using Strings for address;

    uint private _nounCount;
    mapping(uint => Noun) private _nouns;
    
    event NounSubmitted(
        uint id,
        string name,
        address creator,
        uint64[] shapes,
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
        Noun memory noun = getNoun(nounId); 
        return string(_nounJSON(noun));
    }
    
    function nounURI(uint nounId) public view returns (string memory) {
        Noun memory noun = getNoun(nounId); 
        return string(_nounURI(noun));
    }

    function nounSVG(uint nounId) external view returns (string memory) {
        Noun memory noun = getNoun(nounId); 
        return string(_nounSVG(noun.shapes));
    }

    function submitNoun(NounParams memory params) external {
        require(
            params.shapes.length < 256 * 256,
            "Noun too large"
        );

        Noun storage noun = _nouns[++_nounCount];

        noun.id = _nounCount;
        noun.name = params.name;
        noun.shapes = params.shapes;
        noun.creator = params.creator;
        noun.traits = params.traits;

        emit NounSubmitted(
            noun.id, 
            noun.name, 
            noun.creator,
            noun.shapes,
            noun.traits
        );
    }

    function _nounURI(Noun memory noun) internal pure returns (bytes memory) {
        return abi.encodePacked(
            'data:application/json;base64,',
            Base64.encode(_nounJSON(noun))
        );
    }

    function _nounJSON(Noun memory noun) internal pure returns (bytes memory) {
        return abi.encodePacked(
            '{',
                '"id":', noun.id.toString(), ',',
                '"name":"', noun.name, '",',
                '"description":"', noun.name, ' is a Noun coin.",',
                '"traits":[', string(_nounTraits(noun)), '],',
                '"shapes":[', string(_nounShapes(noun)), '],',
                '"image":"', string(
                    abi.encodePacked(
                        'data:image/svg+xml;base64,', 
                        Base64.encode(_nounSVG(noun.shapes))
                    )
                ), '"',
            '}'
        );
    }

    function _nounTraits(Noun memory noun) internal pure returns (bytes memory) {
        bytes memory list;
        for (uint i = 0; i < noun.traits.length; i += 1) {
            list = abi.encodePacked(
                list, 
                '"', noun.traits[i], '"', 
                i == noun.traits.length - 1 ? '' : ','
            );
        }
        return list;
    }

    function _nounShapes(Noun memory noun) internal pure returns (bytes memory) {
        bytes memory list;
        for (uint i = 0; i < noun.shapes.length; i += 1) {
            list = abi.encodePacked(
                list, 
                '"', noun.shapes[i].toHexString(), '"', 
                i == noun.shapes.length - 1 ? '' : ','
            );
        }
        return list;
    }

    function _nounSVG(uint64[] memory shapes) internal pure returns (bytes memory) {
        bytes memory image;
       
        for (uint i = 0; i < shapes.length; i += 1) {
            image = abi.encodePacked(image, _nounSVGShape(shapes[i]));
        }
       
        return abi.encodePacked(
            '<svg',
            ' width="420"',
            ' height="420"',
            ' viewBox="0 0 255 255"',
            ' xmlns="http://www.w3.org/2000/svg"',
            ' shape-rendering="crispEdges">', 
            string(image), 
            '</svg>'
        );
    }

    function _nounSVGShape(uint64 part) internal pure returns (bytes memory) {
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