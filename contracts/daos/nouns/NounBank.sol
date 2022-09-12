// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import "../../shared/Claimable.sol";
import "../../shared/Oracle.sol";
import "../../ledger/Bank.sol";
import "./NounsDescriptor.sol";

// TODO: deep fry the horse
// TODO: fix the gas cost for mintBatch

contract NounBank is Claimable, Oracle, Bank {
    NounsDescriptor private _desc;
    uint private _ampl = 20000;  // basis points

    function decimals() public view override returns (uint8) {
        return oracleDecimals();
    }

    function descriptor() public view returns (NounsDescriptor) {
        return _desc;
    }

    function ampl() public view returns (uint) {
        return _ampl;
    }

    function setAmpl(uint ampl_) external onlyOwner {
        _ampl = ampl_;
    }

    function setDescriptor(NounsDescriptor desc_) external onlyOwner {
        _desc = desc_;
    }

    function mint(
        address to, 
        uint coinId, 
        bytes memory data
    ) external payable {
        require(msg.value > 0, "Must mint some coins");
        uint amount = conversionRate(coinId, msg.value);
        
        _mint(to, coinId, amount, data);
        _addValue(msg.value);
    }

    function mintBatch(
        address to,
        uint[] memory ids,
        bytes memory data
    ) external payable {
        require(msg.value > 0, "Must mint some coins");
        
        uint split = msg.value / ids.length;
        uint[] memory amounts = new uint[](ids.length);
        
        for (uint i = 0; i < ids.length; i += 1) {
            amounts[i] = conversionRate(ids[i], split);
        }

        _mintBatch(to, ids, amounts, data);
        _addValue(msg.value);
    }

    function conversionRate(
        uint coinId, 
        uint value
    ) public view override returns (uint) {
        require(coinId != 101, "Deep fried");

        uint heads = _desc.headCount();
        require(heads > 0 && coinId < heads, "Not enough heads");

        uint totalSupply = totalSupply();
        if (totalSupply == 0) {
            require(value * 2 >= heads, "Not enough coins");
            return convertValueAtOraclePrice(value);  // seppuku mint;
        }

        uint avgSupply = totalSupply / heads;
        uint tokenSupply = totalSupplyOf(coinId);

        if (tokenSupply > avgSupply * _ampl / 10000) {
            return convertValueAtOraclePrice(value / (_ampl / 10000));
        }

        if (avgSupply > tokenSupply * _ampl / 10000) {
            return convertValueAtOraclePrice(value * _ampl / 10000);
        }

        return convertValueAtOraclePrice(value * avgSupply / tokenSupply);
    }

    constructor(
        OracleInterface oracle_,
        string memory baseURI_,
        NounsDescriptor desc_
    ) Oracle(oracle_) Bank(baseURI_) { 
        _desc = desc_; 
    }
}