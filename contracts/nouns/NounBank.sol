// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import { Strings } from '@openzeppelin/contracts/utils/Strings.sol';
import "../money/Bank.sol";
import "./NounData.sol";

abstract contract Nouns {
    function nounToCoin(uint nounId) virtual public view returns (uint);
    function coinToNoun(uint coinId) virtual public view returns (uint);
}

contract NounBank is Bank {
    using Strings for uint;
    
    Nouns private _nouns;
    NounData private _data;

    modifier onlyAdmin() {
        require(msg.sender == address(_nouns), "Caller is not the admin");
        _;
    }

    function nameOf(uint coinId) override public view returns (string memory) {
        uint nounId = _nouns.coinToNoun(coinId);
        Noun memory noun = _data.getNoun(nounId);
        return noun.name;
    }

    function symbolOf(uint coinId) override public view returns (string memory) {
        return string(abi.encodePacked('NOUN COIN ', coinId.toString()));
    }

    function decimals() override virtual public view returns (uint8) {
        return 14;
    }

    function mint(
        address to, 
        uint id, 
        uint amount, 
        bytes memory data
    ) external onlyAdmin {
        _mint(to, id, amount, data);
    }

    constructor(
        string memory baseURI_,
        Nouns nouns_,
        NounData data_
    ) Bank(baseURI_) {
        _nouns = nouns_;
        _data = data_;
    }
}
