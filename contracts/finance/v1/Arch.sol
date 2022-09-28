// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Arch is Ownable, Pausable {
    uint private _budgetRate = 52;
    uint private _inflationRate = 20;
    uint private _minimumDuration = 7 days;
    uint private _penaltyDuration = 14 days;
    uint private _maximumDuration = 2048 weeks;
    bool private _goodAccounting = true;
    
    function currentDay() public view returns (uint) { return block.timestamp / 1 days; }
    function budgetRate() public view returns (uint) {return _budgetRate; }
    function inflationRate() public view returns (uint) { return _inflationRate; }
    function minimumDuration() public view returns (uint) {return _minimumDuration; }
    function penaltyDuration() public view returns (uint) {return _penaltyDuration; }
    function maximumDuration() public view returns (uint) {return _maximumDuration; }
    function goodAccounting() public view returns (bool) { return _goodAccounting; }

    function setBudgetRate(uint budgetRate_) external onlyOwner { _budgetRate = budgetRate_; }
    function setInflationRate(uint inflationRate_) external onlyOwner { _inflationRate = inflationRate_; }
    function setMinimumDuration(uint minimumDuration_) external onlyOwner { _minimumDuration = minimumDuration_; }
    function setPenaltyDuration(uint penaltyDuration_) external onlyOwner { _penaltyDuration = penaltyDuration_; }
    function setMaximumDuration(uint maximumDuration_) external onlyOwner { _maximumDuration = maximumDuration_; }
    function setGoodAccounting(bool goodAccounting_) external onlyOwner {_goodAccounting = goodAccounting_; }

    function pause() external onlyOwner { _pause(); }
    function unpause() external onlyOwner { _unpause(); }
}