// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import "../oracles/PriceOracle.sol";

contract DollarOracle is OracleInterface {
    function decimals() external pure returns (uint8) {
        return 8;
    }

    function description() external pure returns (string memory) {
        return "USD-ETH";
    }

    function version() external pure returns (uint256) {
        return 1;
    }

    function getRoundData(uint80)
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        ) {
        return (0, 160000000000, block.timestamp, block.timestamp, 0);
    }

    function latestRoundData()
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        ) {
        return (0, 160000000000, block.timestamp, block.timestamp, 0);
    }
}

contract MockOracle is PriceOracle {
    constructor() PriceOracle(new DollarOracle()) {}
}