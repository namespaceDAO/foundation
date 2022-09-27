// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import "../../token/v1/Found.sol";

contract Foundation {
    Found1 private _found;

    function foundSupply() public view returns (uint) {
        return _found.totalSupply();
    }

    function tokenBalance() public view returns (uint) {
        return  _found.tokenBalance();
    }

    function valueBalance() public view returns (uint) {
        return _found.valueBalance();
    }

    function _treasuryPushValue(address payee, uint value) internal {
        _found.pushValue(payee, value);
    }

    function _treasuryPushToken(address payee, uint value) internal {
        _found.pushToken(payee, value);
    }

    function _treasuryPullToken(address depositor, uint value) internal {
        _found.pullToken(depositor, value);
    }

    function _treasuryMintToken(address to, uint amount) internal {
        _found.treasuryMint(to, amount);
    }

    constructor(Found1 found_) { _found = found_; }
}
