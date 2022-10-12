// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import { Strings } from '@openzeppelin/contracts/utils/Strings.sol';
import "@openzeppelin/contracts/access/Ownable.sol";
import "../money/Bank.sol";
import "../money/Coin.sol";
import "./NounData.sol";

  /*$$$$$   /$$$$$$  /$$    /$$ /$$$$$$$$ /$$$$$$$  /$$   /$$ /$$      /$$ /$$$$$$$$ /$$   /$$ /$$$$$$$$ /$$$$$$ 
 /$$__  $$ /$$__  $$| $$   | $$| $$_____/| $$__  $$| $$$ | $$| $$$    /$$$| $$_____/| $$$ | $$|__  $$__//$$__  $$
| $$  \__/| $$  \ $$| $$   | $$| $$      | $$  \ $$| $$$$| $$| $$$$  /$$$$| $$      | $$$$| $$   | $$  | $$  \__/
| $$ /$$$$| $$  | $$|  $$ / $$/| $$$$$   | $$$$$$$/| $$ $$ $$| $$ $$/$$ $$| $$$$$   | $$ $$ $$   | $$  |  $$$$$$ 
| $$|_  $$| $$  | $$ \  $$ $$/ | $$__/   | $$__  $$| $$  $$$$| $$  $$$| $$| $$__/   | $$  $$$$   | $$   \____  $$
| $$  \ $$| $$  | $$  \  $$$/  | $$      | $$  \ $$| $$\  $$$| $$\  $ | $$| $$      | $$\  $$$   | $$   /$$  \ $$
|  $$$$$$/|  $$$$$$/   \  $/   | $$$$$$$$| $$  | $$| $$ \  $$| $$ \/  | $$| $$$$$$$$| $$ \  $$   | $$  |  $$$$$$/
 \______/  \______/     \_/    |________/|__/  |__/|__/  \__/|__/     |__/|________/|__/  \__/   |__/   \_____*/ 

interface NounBase {
    function currentDay() external view returns (uint day);
    function coinToNoun(uint coinId) external view returns (uint nounId);
}

contract NounGovt is Ownable {
    uint private _tax;

    mapping(address => bool) private _govts;

    event SetTax(uint tax);
    event AddGovernment(address addr);
    event RemoveGovernment(address addr);

    function tax() external view returns (uint) { 
        return _tax; 
    }

    function isGovernment(address addr) external view returns (bool) { 
        return _govts[addr]; 
    }

    function setTax(uint tax_) external onlyOwner {
        require(tax_ < 5000, "Too damn high");
        _tax = tax_;
        emit SetTax(tax_);
    }

    function addGovernment(address addr) external onlyOwner {
        _govts[addr] = true;
        emit AddGovernment(addr);
    }

    function removeGovernment(address addr) external onlyOwner {
        _govts[addr] = false;
        emit RemoveGovernment(addr);
    }
}

 /*$      /$$ /$$$$$$ /$$   /$$ /$$$$$$$$
| $$$    /$$$|_  $$_/| $$$ | $$|__  $$__/
| $$$$  /$$$$  | $$  | $$$$| $$   | $$   
| $$ $$/$$ $$  | $$  | $$ $$ $$   | $$   
| $$  $$$| $$  | $$  | $$  $$$$   | $$   
| $$\  $ | $$  | $$  | $$\  $$$   | $$   
| $$ \/  | $$ /$$$$$$| $$ \  $$   | $$   
|__/     |__/|______/|__/  \__/   |_*/   

contract NounMint is Bank {
    using Strings for uint;
    
    NounData private _data;
    NounBase private _base;   

    uint private _difficulty = 10; 
    mapping(uint => Coin) private _coins;

    modifier onlyAdmin() {
        require(msg.sender == address(_base), "Caller is not based");
        _;
    }

    function data() external view returns (NounData) { 
        return _data;
    }

    function base() external view returns (NounBase) { 
        return _base; 
    }

    function difficulty() external view returns (uint) {
        return _difficulty;
    }

    function mintCoin(address to, uint coinId, uint amount) external onlyAdmin {
        _mint(to, coinId, amount, new bytes(0));
    }

    function convertCoin(uint coinId, uint amount) public view returns (uint) {
        uint totalSupply = totalSupply();
        if (totalSupply == 0) return amount;

        uint avgSupply = totalSupply / _base.currentDay();
        uint tokenSupply = totalSupplyOf(coinId);

        if (tokenSupply > avgSupply * _difficulty) {
            return amount / _difficulty;
        }

        if (avgSupply > tokenSupply * _difficulty) {
            return amount * _difficulty;
        }

        return amount * avgSupply / tokenSupply;
    }
    
      /*$$$$$   /$$$$$$  /$$$$$$ /$$   /$$  /$$$$$$ 
     /$$__  $$ /$$__  $$|_  $$_/| $$$ | $$ /$$__  $$
    | $$  \__/| $$  \ $$  | $$  | $$$$| $$| $$  \__/
    | $$      | $$  | $$  | $$  | $$ $$ $$|  $$$$$$ 
    | $$      | $$  | $$  | $$  | $$  $$$$ \____  $$
    | $$    $$| $$  | $$  | $$  | $$\  $$$ /$$  \ $$
    |  $$$$$$/|  $$$$$$/ /$$$$$$| $$ \  $$|  $$$$$$/
     \______/  \______/ |______/|__/  \__/ \_____*/ 

    function coinToNoun(uint coinId) external view returns (uint nounId) {
        return _base.coinToNoun(coinId);
    }

    function nameOf(uint coinId) override public view returns (string memory) {
        uint nounId = _base.coinToNoun(coinId);
        return _data.getNoun(nounId).name;
    }

    function symbolOf(uint coinId) override public pure returns (string memory) {
        return string(abi.encodePacked('NOUN COIN ', coinId.toString()));
    }

    function decimals() override virtual public pure returns (uint8) {
        return 14;
    }

    function uri(uint coinId) override virtual public view returns (string memory) {
        uint nounId = _base.coinToNoun(coinId);
        return _data.tokenURI(nounId);
    }

    function addressOf(uint coinId) external view returns (Coin) {
        require(
            address(_coins[coinId]) != address(0), 
            "Coin has not been deployed"
        );

        return _coins[coinId];
    }

    function deployCoin(uint coinId) external returns (Coin) {
        require(coinId <= _base.currentDay(), "Coin has not been found");

        bool deployed = address(_coins[coinId]) != address(0);
        require(!deployed, "Coin has already been deployed");

        _coins[coinId] = new Coin(Bank(this), coinId);
        return _coins[coinId];
    }

    constructor(NounData data_, NounBase base_) Bank('') {
        _data = data_;
        _base = base_;
    }
}