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

    event AddGovernment(address addr);
    event RemoveGovernment(address addr);

    function tax() public view returns (uint) { 
        return _tax; 
    }

    function setTax(uint tax_) external onlyOwner {
        require(tax_ <= 3000, "Too many apples");
        _tax = tax_;
    }

    function isGovernment(address addr) external view returns (bool) { 
        return _govts[addr]; 
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
