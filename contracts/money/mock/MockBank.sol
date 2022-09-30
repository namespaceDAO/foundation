// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import { Strings } from '@openzeppelin/contracts/utils/Strings.sol';
import "../Bank.sol";

contract MockBank is Bank {
    using Strings for uint;

    function nameOf(uint coinId) override public pure returns (string memory) {
        return string(abi.encodePacked('COIN ', coinId.toString()));
    }

    function symbolOf(uint coinId) override public pure returns (string memory) {
        return string(abi.encodePacked('SYMBOL ', coinId.toString()));
    }

    function decimals() override public pure returns (uint8) {
        return 18;
    }

    function mint(address to, uint coinId) external payable {
        bytes memory data;
        _mint(to, coinId, msg.value, data);
    }

    function deployCoin(uint coinId) external returns (Coin) {
        return _deployCoin(coinId);
    }

    constructor(string memory baseURI_) Bank(baseURI_) {}    
}