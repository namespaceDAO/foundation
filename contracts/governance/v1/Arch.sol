// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../../token/Found.sol";

contract FoundArch {
    Found private _found;

    function _transferTreasuryValue(address payee, uint value) internal {
        _found.transferValue(payee, value);
    }

    function _transferFound(address payee, uint value) internal {
        _found.transferFound(address(_found), payee, value);
    }

    function _depositTreasuryFound(address depositor, uint value) internal {
        _found.transferFound(depositor, address(_found), value);
    }

    function _mintTreasuryFound(address to, uint amount) internal {
        _found.mintFound(to, amount);
    }

    function _totalFoundSupply() internal view returns (uint) {
        return _found.totalSupply();
    }

    function _treasuryValueBalance() internal view returns (uint) {
        return address(_found).balance;
    }

    function _treasuryFoundBalance() internal view returns (uint) {
        return  _found.balanceOf(address(_found));
    }

    function _treasuryNetBalance() internal view returns (uint) {
        uint treasuryValue = _treasuryValueBalance();
        uint treasuryFound = _treasuryFoundBalance();
        uint converted = treasuryValue * (treasuryFound / treasuryValue);
        return treasuryFound + converted;
    }

    function _convertValueToFound(uint value) internal view returns (uint) {
        uint treasuryValue = _treasuryValueBalance();
        uint treasuryFound = _treasuryFoundBalance();
        return value * (treasuryFound / treasuryValue);
    }

    constructor(Found found_) {
        _found = found_;
    }
}

contract Arch is Ownable, Pausable, FoundArch {
    uint private _inflationRate = 20;
    uint private _weeklyLimit = 52;
    
    function currentWeek() public view returns (uint) {
        return block.timestamp / 7 days;
    }

    function inflationRate() public view returns (uint) {
        return _inflationRate;
    }

    function setInflationRate(uint rate) external onlyOwner {
        _inflationRate = rate;
    }

    function weeklyLimit() public view returns (uint) {
        return _weeklyLimit;
    }

    function setWeeklyLimit(uint limit) external onlyOwner {
        _weeklyLimit = limit;
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    constructor(Found found_) FoundArch(found_) {}
}