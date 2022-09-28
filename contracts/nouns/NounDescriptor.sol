// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import "../finance/Capitalism.sol";
import "./Nounish.sol";

contract NounDescriptor is Nounish, CapitalismDescriptor {
    function dataURI(Stake memory stake) override public view returns (string memory) {
        return "";
    }

    function tokenURI(Stake memory stake) override public view returns (string memory) {
        return "";
    }
}
