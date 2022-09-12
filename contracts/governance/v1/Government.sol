// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import "./Capitialist.sol";
import "./PublicForum.sol";

contract GovernmentV1 is Capitialist, PublicForum {
    function _isStartable(uint id) override internal view returns (bool) {
        return totalStaked(id) > _proposalAsk(id);
    }

    constructor(Found found_) Capitialist(found_) {}
}
