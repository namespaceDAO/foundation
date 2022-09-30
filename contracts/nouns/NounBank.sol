// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import { Strings } from '@openzeppelin/contracts/utils/Strings.sol';
import "../money/Bank.sol";
import "./NounData.sol";

abstract contract NounCoin {
    function requireCoin(uint coinId) virtual public view;
    function nounToCoin(uint nounId) virtual public view returns (uint);
    function coinToNoun(uint coinId) virtual public view returns (uint);
}

contract NounBank is Bank {
    using Strings for uint;
    
    NounData private _data;
    NounCoin private _base;

    modifier onlyAdmin() {
        require(msg.sender == address(_base), "Caller is not the admin");
        _;
    }

    function nameOf(uint coinId) override public view returns (string memory) {
        uint nounId = _base.coinToNoun(coinId);
        Noun memory noun = _data.getNoun(nounId);
        return noun.name;
    }

    function symbolOf(uint coinId) override public view returns (string memory) {
        return string(abi.encodePacked('NOUN COIN ', coinId.toString()));
    }

    function decimals() override virtual public view returns (uint8) {
        return 14;
    }

    function deployCoin(uint coinId) external returns (Coin) {
        _base.requireCoin(coinId);
        return _deployCoin(coinId);
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
        NounData data_,
        NounCoin base_,
        string memory baseURI_
    ) Bank(baseURI_) {
        _data = data_;
        _base = base_;
    }
}
