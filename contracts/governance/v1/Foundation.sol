// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import "../../token/Found.sol";

contract Foundation {
    Found private _found;

    function _treasuryTransferValue(address payee, uint value) internal {
        _found.sendValue(payee, value);
    }

    function _treasuryTransferFound(address payee, uint value) internal {
        _found.transferFound(address(_found), payee, value);
    }

    function _treasuryDepositFound(address depositor, uint value) internal {
        _found.transferFound(depositor, address(_found), value);
    }

    function _treasuryMintFound(address to, uint amount) internal {
        _found.mintFound(to, amount);
    }

    function _treasuryFoundSupply() internal view returns (uint) {
        return _found.totalSupply();
    }

    function _treasuryFoundBalance() internal view returns (uint) {
        return  _found.balanceOf(address(_found));
    }

    function _treasuryValueBalance() internal view returns (uint) {
        return address(_found).balance;
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

    constructor(Found found_) { _found = found_; }
}
