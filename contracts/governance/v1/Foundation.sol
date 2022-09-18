// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import "../../token/Found.sol";

contract Foundation {
    Found private _found;

    function foundSupply() public view returns (uint) {
        return _found.totalSupply();
    }

    function foundBalance() public view returns (uint) {
        return  _found.foundBalance();
    }

    function valueBalance() public view returns (uint) {
        return _found.valueBalance();
    }

    function _treasuryPullValue(address payee, uint value) internal {
        _found.pullValue(payee, value);
    }

    function _treasuryPullFound(address payee, uint value) internal {
        _found.pullFound(payee, value);
    }

    function _treasuryPushFound(address depositor, uint value) internal {
        _found.pushFound(depositor, value);
    }

    function _treasuryMintFound(address to, uint amount) internal {
        _found.treasuryMint(to, amount);
    }

    constructor(Found found_) { _found = found_; }
}
