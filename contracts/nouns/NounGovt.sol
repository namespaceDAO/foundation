// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/access/Ownable.sol";

  /*$$$$$   /$$$$$$  /$$    /$$ /$$$$$$$$ /$$$$$$$  /$$   /$$ /$$      /$$ /$$$$$$$$ /$$   /$$ /$$$$$$$$ /$$$$$$ 
 /$$__  $$ /$$__  $$| $$   | $$| $$_____/| $$__  $$| $$$ | $$| $$$    /$$$| $$_____/| $$$ | $$|__  $$__//$$__  $$
| $$  \__/| $$  \ $$| $$   | $$| $$      | $$  \ $$| $$$$| $$| $$$$  /$$$$| $$      | $$$$| $$   | $$  | $$  \__/
| $$ /$$$$| $$  | $$|  $$ / $$/| $$$$$   | $$$$$$$/| $$ $$ $$| $$ $$/$$ $$| $$$$$   | $$ $$ $$   | $$  |  $$$$$$ 
| $$|_  $$| $$  | $$ \  $$ $$/ | $$__/   | $$__  $$| $$  $$$$| $$  $$$| $$| $$__/   | $$  $$$$   | $$   \____  $$
| $$  \ $$| $$  | $$  \  $$$/  | $$      | $$  \ $$| $$\  $$$| $$\  $ | $$| $$      | $$\  $$$   | $$   /$$  \ $$
|  $$$$$$/|  $$$$$$/   \  $/   | $$$$$$$$| $$  | $$| $$ \  $$| $$ \/  | $$| $$$$$$$$| $$ \  $$   | $$  |  $$$$$$/
 \______/  \______/     \_/    |________/|__/  |__/|__/  \__/|__/     |__/|________/|__/  \__/   |__/   \_____*/ 

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
