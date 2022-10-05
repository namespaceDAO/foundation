// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import { Strings } from '@openzeppelin/contracts/utils/Strings.sol';
import "../money/Bank.sol";
import "../money/Coin.sol";
import "./shared.sol";
import "./NounData.sol";
import "./NounNote.sol";

contract NounBank is Bank {
    using Strings for uint;
    
    NounData private _data;
    NounBased private _base;

    uint private _difficulty = 10;    

    mapping(uint => Coin) private _coins;

    modifier onlyAdmin() {
        require(msg.sender == address(_base), "Caller is not based");
        _;
    }

    function nameOf(uint coinId) override public view returns (string memory) {
        return _base.coinToNoun(coinId).name;
    }

    function symbolOf(uint coinId) override public pure returns (string memory) {
        return string(abi.encodePacked('NOUN COIN ', coinId.toString()));
    }

    function decimals() override virtual public pure returns (uint8) {
        return 14;
    }

    function difficulty() external view returns (uint) {
        return _difficulty;
    }

    function addressOf(uint coinId) external view returns (Coin) {
        require(
            address(_coins[coinId]) != address(0), 
            "Coin has not been deployed"
        );

        return _coins[coinId];
    }

    function mint(address to, uint coinId, uint amount) external onlyAdmin {
        _mint(to, coinId, amount, new bytes(0));
    }

    function deployCoin(uint coinId) external returns (Coin) {
        require(coinId <= _data.currentDay(), "Coin has not been found");

        bool deployed = address(_coins[coinId]) != address(0);
        require(!deployed, "Coin has already been deployed");

        _coins[coinId] = new Coin(Bank(this), coinId);
        return _coins[coinId];
    }

    function convertCoin(uint coinId, uint amount) public view returns (uint) {
        uint totalSupply = totalSupply();
        if (totalSupply == 0) return amount;

        uint avgSupply = totalSupply / _data.currentDay();
        uint tokenSupply = totalSupplyOf(coinId);

        if (tokenSupply > avgSupply * _difficulty) {
            return amount / _difficulty;
        }

        if (avgSupply > tokenSupply * _difficulty) {
            return amount * _difficulty;
        }

        return amount * avgSupply / tokenSupply;
    }

    constructor(
        NounData data_, 
        NounBased base_,
        string memory baseURI_
    ) Bank(baseURI_) {
        _data = data_;
        _base = base_;
    }
}
