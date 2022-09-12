// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface OracleInterface is AggregatorV3Interface {}

contract Oracle is Ownable {
    OracleInterface private _oracle;

    function convertValueAtOraclePrice(uint value) public view returns (uint) {
        uint deno = 10 ** _oracle.decimals();
        uint nemo = oraclePrice();
        return value * nemo / deno;
    }

    function oraclePrice() public view returns (uint) {
        (
            /*uint80 roundID*/,
            int price,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = _oracle.latestRoundData();

        require(price > 0, "Oracle: invalid price");
        return uint(price);
    }

    function oracleDecimals() public view returns (uint8) {
        return _oracle.decimals();
    }

    function oracleAddress() public view returns (OracleInterface) {
        return _oracle;
    }

    function setOracle(OracleInterface oracle_) external onlyOwner {
        _oracle = oracle_;
    }

    constructor (OracleInterface oracle_) {
        _oracle = oracle_;
    }
}