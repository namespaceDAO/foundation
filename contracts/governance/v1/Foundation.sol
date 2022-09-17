// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import "../../token/Found.sol";

contract Foundation {
    Found private _found;

    function totalFoundSupply() public view returns (uint) {
        return _found.totalSupply();
    }

    function treasuryFoundBalance() public view returns (uint) {
        return  _found.treasuryFoundBalance();
    }

    function treasuryValueBalance() public view returns (uint) {
        return _found.treasuryValueBalance();
    }

    // what's the correct word here?
    function treasuryNetBalance() public view returns (uint) {
        uint treasuryValue = treasuryValueBalance();
        uint treasuryFound = treasuryFoundBalance();
        uint converted = treasuryValue * (treasuryFound / treasuryValue);
        return treasuryFound + converted;
    }

    function convertValueToFound(uint value) public view returns (uint) {
        uint treasuryValue = treasuryValueBalance();
        uint treasuryFound = treasuryFoundBalance();
        return value * (treasuryFound / treasuryValue);
    }

    function _treasuryTransferValue(address payee, uint value) internal {
        _found.transferValue(payee, value);
    }

    function _treasuryTransferFound(address payee, uint value) internal {
        _found.treasuryTransfer(address(_found), payee, value);
    }

    function _treasuryDepositFound(address depositor, uint value) internal {
        _found.treasuryTransfer(depositor, address(_found), value);
    }

    function _treasuryMintFound(address to, uint amount) internal {
        _found.treasuryMint(to, amount);
    }

    constructor(Found found_) { _found = found_; }
}
