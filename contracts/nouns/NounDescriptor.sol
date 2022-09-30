// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

// import { Base64 } from 'base64-sol/base64.sol';
import { Strings } from '@openzeppelin/contracts/utils/Strings.sol';
import "../finance/Capitalism.sol";
import "./Nounish.sol";

contract NounDescriptor is Nounish, CapitalismDescriptor {
    using Strings for uint;
    
    function stakeJSON(Stake memory stake) public view returns (string memory) {
        return string(_stakeJSON(stake));
    }

    function dataURI(Stake memory stake) override public view returns (string memory) {
        return string(
            abi.encodePacked(
                'data:application/json;base64,',
                _stakeJSON(stake)
                // Base64.encode(_stakeJSON(stake))
            )
        );
    }

    function tokenURI(Stake memory stake) override public view returns (string memory) {
        return "";
    }

    function _stakeJSON(Stake memory stake) internal view returns (bytes memory) {
        return abi.encodePacked(
            '{',
                '"id":"', stake.id.toString(), '",',
                '"idea":"', stake.idea.toString(), '",',
                '"amount":"', stake.amount.toString(), '",',
                '"expiresAt":"', stake.expiresAt.toString(), '",',
                '"startedAt":"', stake.startedAt.toString(), '",',
                '"endedAt":"', stake.endedAt.toString(), '"',
            '}'
        );
    }
}
