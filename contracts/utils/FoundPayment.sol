// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/finance/PaymentSplitter.sol";
import "../token/Found.sol";
import "./FoundShare.sol";

contract FoundPayment {
    FoundShare private _share;

    uint private _timedelta = 28 days;

    mapping(uint => uint) private _days;
    mapping(uint => uint) private _totals;

    function _addValue(uint value) internal {
        _totals[block.timestamp / _timedelta] += value;
        _days[currentDay()] += value;
    }

    function currentDay() public view returns (uint) {
        return block.timestamp / 1 days;
    }

    function shareAddress() external view returns (address) {
        return address(_share);
    }

    function startStake(uint amount) external {
        _share.startStake(amount);
        uint rate = _days[currentDay() - 1];

        // TODO: update payment shares
    }

    function endStake(uint id) external {
        uint served = _share.endStake(id);
        // TODO: update payment shares
    }

    constructor(
        Found found_,
        string memory name_,
        string memory symbol_
    ) {
        _share = new FoundShare(found_, name_, symbol_);
    }
}
