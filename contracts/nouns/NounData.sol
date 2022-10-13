// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import { Strings } from '@openzeppelin/contracts/utils/Strings.sol';
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
                                                                           
 /*$   /$$  /$$$$$$  /$$   /$$ /$$   /$$  /$$$$$$                                                                         
| $$$ | $$ /$$__  $$| $$  | $$| $$$ | $$ /$$__  $$                                                                        
| $$$$| $$| $$  \ $$| $$  | $$| $$$$| $$| $$  \__/                                                                        
| $$ $$ $$| $$  | $$| $$  | $$| $$ $$ $$|  $$$$$$                                                                         
| $$  $$$$| $$  | $$| $$  | $$| $$  $$$$ \____  $$                                                                        
| $$\  $$$| $$  | $$| $$  | $$| $$\  $$$ /$$  \ $$                                                                        
| $$ \  $$|  $$$$$$/|  $$$$$$/| $$ \  $$|  $$$$$$/                                                                        
|__/  \__/ \______/  \______/ |__/  \__/ \_____*/                                                                         

struct Noun {
    uint id;
    string name;
    address creator;
    uint64[] shapes;
    string[] traits;
}

contract NounData is ERC721 {
    using Strings for uint;
    using Strings for uint8;
    using Strings for uint64;
    using Strings for address;

    uint private _nounCount;

    mapping(uint => Noun) private _nouns;

    function nounCount() external view returns (uint) {
        return _nounCount;
    }

    function getNoun(uint nounId) public view returns (Noun memory) {
        require(nounId <= _nounCount, "Noun not found");
        return _nouns[nounId];
    }

      /*$$$$$$  /$$$$$$$  /$$$$$$$$  /$$$$$$  /$$$$$$$$ /$$$$$$$$
     /$$__  $$| $$__  $$| $$_____/ /$$__  $$|__  $$__/| $$_____/
    | $$  \__/| $$  \ $$| $$      | $$  \ $$   | $$   | $$      
    | $$      | $$$$$$$/| $$$$$   | $$$$$$$$   | $$   | $$$$$   
    | $$      | $$__  $$| $$__/   | $$__  $$   | $$   | $$__/   
    | $$    $$| $$  \ $$| $$      | $$  | $$   | $$   | $$      
    |  $$$$$$/| $$  | $$| $$$$$$$$| $$  | $$   | $$   | $$$$$$$$
     \______/ |__/  |__/|________/|__/  |__/   |__/   |_______*/

    event NounSubmitted(
        uint id,
        string name,
        address creator,
        uint64[] shapes,
        string[] traits
    );

    struct NounParams {
        string name;
        address creator;
        uint64[] shapes;
        string[] traits;
    }

    function submitNoun(NounParams memory params) external returns (uint) {
        require(params.shapes.length <= 0xffff, "Noun too large");
        Noun storage noun = _nouns[++_nounCount];

        noun.id = _nounCount;
        noun.name = params.name;
        noun.shapes = params.shapes;
        noun.creator = params.creator;
        noun.traits = params.traits;

        _mint(params.creator, noun.id);

        emit NounSubmitted(
            noun.id, 
            noun.name, 
            noun.creator,
            noun.shapes,
            noun.traits
        );

        return noun.id;
    }  

     /*$$$$$$$ /$$$$$$  /$$$$$$$  /$$      /$$ /$$       /$$$$$$$$  /$$$$$$   /$$$$$$ 
    | $$_____//$$__  $$| $$__  $$| $$$    /$$$| $$      | $$_____/ /$$__  $$ /$$__  $$
    | $$     | $$  \ $$| $$  \ $$| $$$$  /$$$$| $$      | $$      | $$  \__/| $$  \__/
    | $$$$$  | $$  | $$| $$$$$$$/| $$ $$/$$ $$| $$      | $$$$$   |  $$$$$$ |  $$$$$$ 
    | $$__/  | $$  | $$| $$__  $$| $$  $$$| $$| $$      | $$__/    \____  $$ \____  $$
    | $$     | $$  | $$| $$  \ $$| $$\  $ | $$| $$      | $$       /$$  \ $$ /$$  \ $$
    | $$     |  $$$$$$/| $$  | $$| $$ \/  | $$| $$$$$$$$| $$$$$$$$|  $$$$$$/|  $$$$$$/
    |__/      \______/ |__/  |__/|__/     |__/|________/|________/ \______/  \_____*/ 

    function tokenURI(uint nounId) public view virtual override returns (string memory) {
        Noun memory noun = getNoun(nounId); 
        return string(_encodeURI(noun));
    }

    function tokenData(uint nounId) external view returns (string memory) {
        Noun memory noun = getNoun(nounId); 
        return string(_encodeJSON(noun));
    }

    function tokenImage(uint nounId) external view returns (string memory) {
        Noun memory noun = getNoun(nounId); 
        return string(_encodeImage(noun));
    }

    function tokenSVG(uint nounId) external view returns (string memory) {
        Noun memory noun = getNoun(nounId); 
        return string(_encodeSVG(noun.shapes));
    }

    function _encodeURI(Noun memory noun) internal pure returns (bytes memory) {
        return abi.encodePacked(
            'data:application/json;base64,',
            Base64.encode(_encodeJSON(noun))
        );
    }

    function _encodeImage(Noun memory noun) internal pure returns (bytes memory) {
        return abi.encodePacked(
            'data:image/svg+xml;base64,', 
            Base64.encode(_encodeSVG(noun.shapes))
        );
    }
    
    function _encodeJSON(Noun memory noun) internal pure returns (bytes memory) {
        return abi.encodePacked(
            '{',
                '"id":', noun.id.toString(), ',',
                '"name":"', noun.name, '",',
                '"description":"', noun.name, ' is a Noun coin.",',
                '"traits":[', string(_encodeTraits(noun)), '],',
                '"shapes":[', string(_encodeShapes(noun)), '],',
                '"image":"', string(_encodeImage(noun)), '"',
            '}'
        );
    }

    function _encodeTraits(Noun memory noun) internal pure returns (bytes memory) {
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

    function _encodeShapes(Noun memory noun) internal pure returns (bytes memory) {
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

      /*$$$$$  /$$   /$$  /$$$$$$  /$$$$$$$  /$$$$$$$$  /$$$$$$ 
     /$$__  $$| $$  | $$ /$$__  $$| $$__  $$| $$_____/ /$$__  $$
    | $$  \__/| $$  | $$| $$  \ $$| $$  \ $$| $$      | $$  \__/
    |  $$$$$$ | $$$$$$$$| $$$$$$$$| $$$$$$$/| $$$$$   |  $$$$$$ 
     \____  $$| $$__  $$| $$__  $$| $$____/ | $$__/    \____  $$
     /$$  \ $$| $$  | $$| $$  | $$| $$      | $$       /$$  \ $$
    |  $$$$$$/| $$  | $$| $$  | $$| $$      | $$$$$$$$|  $$$$$$/
     \______/ |__/  |__/|__/  |__/|__/      |________/ \_____*/ 

    function _encodeSVG(uint64[] memory shapes) internal pure returns (bytes memory) {
        return abi.encodePacked(
            '<svg',
            ' width="420"',
            ' height="420"',
            ' viewBox="0 0 255 255"',
            ' xmlns="http://www.w3.org/2000/svg"',
            ' shape-rendering="crispEdges">', 
            string(_encodeSVGShapes(shapes)), 
            '</svg>'
        );
    }

    function _encodeSVGShapes(uint64[] memory shapes) internal pure returns (bytes memory) {
        bytes memory image;

        for (uint i = 0; i < shapes.length; i += 1) {
            uint64 part = shapes[i];
            uint8 w = uint8(part >> 56);
            uint8 h = uint8(part >> 48);
            uint8 x = uint8(part >> 40);
            uint8 y = uint8(part >> 32);
            uint8 r = uint8(part >> 24);
            uint8 g = uint8(part >> 16);
            uint8 b = uint8(part >> 8);
            uint8 a = uint8(part);
    
            // default, rect
            // width = 0, ellipse
            // height = 0, transform

            bytes memory shape = _encodeSVGRect(w, h, x, y, r, g, b, a);
            image = abi.encodePacked(image, shape);
        }

        return image;
    }

    // function _encodeSVGTransform(
    //     uint8 rx,
    //     uint8 ry,
    //     uint8 rz,
    //     uint8 sx,
    //     uint8 sy
    // ) internal returns (bytes memory) {
    //     return abi.encodePacked(
    //         'skewX(', sx.toString() ,')',
    //         'skewY(', sy.toString() ,')',
    //         'transform="rotate(',
    //             rx.toString(), ' ',
    //             ry.toString(), ' ',
    //             rz.toString(), ' ',
    //         ')',
    //         '"'
    //     );
    // }

    // function _encodeSVGEllipse(
    //     uint8 cx, 
    //     uint8 cy, 
    //     uint8 rx, 
    //     uint8 ry, 
    //     uint8 g, 
    //     uint8 b, 
    //     uint8 a
    // ) internal returns (bytes memory) {
    //     return abi.encodePacked(
    //         '<ellipse',
    //             ' cx="', cx.toString(), '"',
    //             ' cy="', cy.toString(), '"',
    //             ' rx="', rx.toString(), '"',
    //             ' ry="', ry.toString(), '"',
    //             ' fill="rgba(',
    //                 r.toString(), ',',
    //                 g.toString(), ',',
    //                 b.toString(), ',',
    //                 a.toString(),
    //             ')"',
    //         '/>'
    //     );
    // }

    function _encodeSVGRect(
        uint8 w, 
        uint8 h, 
        uint8 x, 
        uint8 y, 
        uint8 r, 
        uint8 g, 
        uint8 b, 
        uint8 a
    ) internal pure returns (bytes memory) {
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
    
    constructor() ERC721("ORIGINAL NOUN", "ORIGINAL NOUN") {}
}