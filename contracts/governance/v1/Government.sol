// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import "./BallotBox.sol";
import "./Capitialist.sol";
import "./PublicForum.sol";

// What being has four legs, then two, and then three?
contract GovernmentV1 is Capitialist, BallotBox, PublicForum {
    function _isStartable(uint id) override internal view returns (bool) {
        return totalStaked(id) > _getFundTotal(id);
    }

    function _isCompleted(uint prop) override internal view returns (bool) {
        return _meetsQuorum(prop);
    }

    constructor(Found found_) Capitialist(found_) {}
}
