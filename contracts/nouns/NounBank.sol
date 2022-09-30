// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import { Strings } from '@openzeppelin/contracts/utils/Strings.sol';
import "../money/Bank.sol";
import "./NounData.sol";

abstract contract NounCoin {
    function currentDay() virtual public view returns (uint);
    function coinToNoun(uint coinId) virtual public view returns (uint);
}

contract NounBank is Bank {
    using Strings for uint;
    
    NounData private _data;
    NounCoin private _base;

    modifier onlyAdmin() {
        require(msg.sender == address(_base), "Caller is not based");
        _;
    }

    function nameOf(uint coinId) override public view returns (string memory) {
        uint nounId = _base.coinToNoun(coinId);
        Noun memory noun = _data.getNoun(nounId);
        return noun.name;
    }

    function symbolOf(uint coinId) override public pure returns (string memory) {
        return string(abi.encodePacked('NOUN COIN ', coinId.toString()));
    }

    function decimals() override virtual public pure returns (uint8) {
        return 14;
    }

    function deployCoin(uint coinId) external returns (Coin) {
        require(coinId <= _base.currentDay(), "Noun has not been found");
        return _deployCoin(coinId);
    }

    function mint(address to, uint id, uint amount) external onlyAdmin {
        _mint(to, id, amount, new bytes(0));
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
