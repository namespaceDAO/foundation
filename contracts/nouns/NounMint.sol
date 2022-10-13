// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import { Strings } from '@openzeppelin/contracts/utils/Strings.sol';
import "@openzeppelin/contracts/access/Ownable.sol";
import "../money/Bank.sol";
import "../money/Coin.sol";
import "./NounData.sol";

 /*$$$$$$  /$$$$$$$$  /$$$$$$  /$$$$$$$  /$$       /$$$$$$$$
| $$__  $$| $$_____/ /$$__  $$| $$__  $$| $$      | $$_____/
| $$  \ $$| $$      | $$  \ $$| $$  \ $$| $$      | $$      
| $$$$$$$/| $$$$$   | $$  | $$| $$$$$$$/| $$      | $$$$$   
| $$____/ | $$__/   | $$  | $$| $$____/ | $$      | $$__/   
| $$      | $$      | $$  | $$| $$      | $$      | $$      
| $$      | $$$$$$$$|  $$$$$$/| $$      | $$$$$$$$| $$$$$$$$
|__/      |________/ \______/ |__/      |________/|_______*/
                                                                             
interface NounBase {
    function currentCoin() external view returns (uint coin);
    function coinToNoun(uint coinId) external view returns (uint nounId);
}

interface INounGovt {
    function tax() external view returns (uint);
    function isActive(address govt) external view returns (bool);
}

contract NounGovt is INounGovt, Ownable {
    INounGovt private _proxy;

    event SetGovt(INounGovt addr);

    function setGovt(INounGovt govt) external onlyOwner { 
        _proxy = govt;
        emit SetGovt(govt);
    }

    function tax() external view returns (uint) { 
        return _isSet() ? _proxy.tax() : 0;
    }

    function isActive(address govt) external view returns (bool) { 
        return _isSet() ? _proxy.isActive(govt) : false;
    }

    function _isSet() internal view returns (bool) {
        return address(_proxy) != address(0);
    }
}

  /*$$$$$$  /$$$$$$$  /$$$$$$$$  /$$$$$$  /$$$$$$$$ /$$$$$$$$
 /$$__  $$| $$__  $$| $$_____/ /$$__  $$|__  $$__/| $$_____/
| $$  \__/| $$  \ $$| $$      | $$  \ $$   | $$   | $$      
| $$      | $$$$$$$/| $$$$$   | $$$$$$$$   | $$   | $$$$$   
| $$      | $$__  $$| $$__/   | $$__  $$   | $$   | $$__/   
| $$    $$| $$  \ $$| $$      | $$  | $$   | $$   | $$      
|  $$$$$$/| $$  | $$| $$$$$$$$| $$  | $$   | $$   | $$$$$$$$
 \______/ |__/  |__/|________/|__/  |__/   |__/   |_______*/

contract NounMint is Bank {
    using Strings for uint;
    
    NounData private _data;
    NounBase private _base;   

    uint private _difficulty = 10; 
    mapping(uint => Coin) private _coins;

    function data() external view returns (NounData) { 
        return _data;
    }

    function base() external view returns (NounBase) { 
        return _base; 
    }

    function difficulty() external view returns (uint) {
        return _difficulty;
    }

    modifier onlyAdmin() {
        require(
            msg.sender == address(_base), 
            "Caller is not based"
        );
        _;
    }

    function mintCoin(address to, uint coinId, uint amount) external onlyAdmin {
        _mint(to, coinId, amount, new bytes(0));
    }

    function convertCoin(uint coinId, uint amount) public view returns (uint) {
        uint totalSupply = totalSupply();
        if (totalSupply == 0) return amount;

        uint avgSupply = totalSupply / _base.currentCoin();
        uint tokenSupply = totalSupplyOf(coinId);

        if (tokenSupply > avgSupply * _difficulty) {
            return amount / _difficulty;
        }

        if (avgSupply > tokenSupply * _difficulty) {
            return amount * _difficulty;
        }

        return amount * avgSupply / tokenSupply;
    }

     /*$      /$$  /$$$$$$  /$$   /$$ /$$$$$$$$ /$$     /$$
    | $$$    /$$$ /$$__  $$| $$$ | $$| $$_____/|  $$   /$$/
    | $$$$  /$$$$| $$  \ $$| $$$$| $$| $$       \  $$ /$$/ 
    | $$ $$/$$ $$| $$  | $$| $$ $$ $$| $$$$$     \  $$$$/  
    | $$  $$$| $$| $$  | $$| $$  $$$$| $$__/      \  $$/   
    | $$\  $ | $$| $$  | $$| $$\  $$$| $$          | $$    
    | $$ \/  | $$|  $$$$$$/| $$ \  $$| $$$$$$$$    | $$    
    |__/     |__/ \______/ |__/  \__/|________/    |_*/                      

    function addressOf(uint coinId) external view returns (Coin) {
        require(
            address(_coins[coinId]) != address(0), 
            "Coin has not been deployed"
        );

        return _coins[coinId];
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

    function deployCoin(uint coinId) external returns (Coin) {
        require(
            coinId <= _base.currentCoin(), 
            "Coin has not been found"
        );

        require(
            address(_coins[coinId]) == address(0),
            "Coin has already been deployed"
        );

        _coins[coinId] = new Coin(Bank(this), coinId);
        
        return _coins[coinId];
    }

    constructor(NounData data_, NounBase base_) Bank('') {
        _data = data_;
        _base = base_;
    }
}