// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import "./Origin.sol";

contract Claimable is Origin {
    uint private _totalMinted;
    uint private _originClaim;

    function _addValue(uint amount) internal {
        _totalMinted += amount;
    }

    function originClaim(address to, uint amount) external onlyOrigin {
        uint max = _totalMinted / 10 - _originClaim;  // up to 10%
        require(amount <= max, "Claimable: origin claim is too large");
        (bool success, ) = to.call{value:amount}("");
        require(success, "Claimable: transfer failed");
        _originClaim += amount;
    }
}