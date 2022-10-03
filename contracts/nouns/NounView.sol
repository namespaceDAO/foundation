// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import { Strings } from '@openzeppelin/contracts/utils/Strings.sol';
import "@openzeppelin/contracts/utils/Base64.sol";

contract NounView {
    using Strings for uint;
    using Strings for uint8;

    string private constant _SVG_START_TAG = '<svg width="420" height="420" viewBox="0 0 255 255" xmlns="http://www.w3.org/2000/svg" shape-rendering="crispEdges">';
    string private constant _SVG_END_TAG = '</svg>';

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