// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import { Strings } from '@openzeppelin/contracts/utils/Strings.sol';
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "./NounData.sol";

abstract contract NounToken is INounToken, ERC721 {
    using Strings for uint;
    NounData _data;

    function _encodeData(uint tokenId) virtual internal view returns (bytes memory);
    function _tokenToNoun(uint tokenId) virtual internal view returns (uint);

    function tokenURI(uint tokenId) public view virtual override returns (string memory) {
        return string(_encodeURI(tokenId));
    }

    function tokenData(uint tokenId) external view returns (string memory) {
        return string(_encodeData(tokenId));
    }

    function tokenImage(uint tokenId) external view returns (string memory) {
        return _data.tokenImage(_tokenToNoun(tokenId));
    }

    function tokenSVG(uint tokenId) external view returns (string memory) {
        return _data.tokenSVG(_tokenToNoun(tokenId));
    }

    function _encodeURI(uint tokenId) internal view returns (bytes memory) {
        return abi.encodePacked(
            'data:application/json;base64,',
            Base64.encode(_encodeData(tokenId))
        );
    }

    constructor(
        string memory name_,
        string memory symbol_,
        NounData data_
    ) ERC721(name_, symbol_) {
        _data = data_;
    }        
}
