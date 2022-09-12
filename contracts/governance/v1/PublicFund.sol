// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import "../../token/Found.sol";

struct Convertible {
  address payee;
  uint startFound;
  uint startValue;
  uint endFound;
  uint endValue;
}

struct Fund {
  uint id;
  address creator;
  address payee;
  uint startFound;
  uint startValue;
  uint endFound;
  uint endValue;
}

abstract contract PublicFund {
  Found private _found;
  mapping(uint => Fund) private _funds;

  event FundCreated(
    uint id,
    address payee,
    uint startFound,
    uint startValue,
    uint endFound,
    uint endValue
  );

   event PaidStart(
    uint id,
    address payee,
    uint found,
    uint value
  );

   event PaidEnd(
    uint id,
    address payee,
    uint found,
    uint value
  );

  function _addFunding(uint id, Convertible memory note) internal {
    require(
      note.startValue > 0 || note.endValue > 0, 
      "You must request some funding"
    );

    Fund storage fund = _funds[id];

    fund.id = id;
    fund.creator = msg.sender;
    fund.payee = note.payee;
    fund.startValue = note.startValue;
    fund.endValue = note.endValue;

    emit FundCreated(
      fund.id,
      fund.payee,
      fund.startFound,
      fund.startValue,
      fund.endFound,
      fund.endValue
    );
  }

  function _payStart(uint id) internal {
    Fund storage fund = _funds[id];

    _found.transferValueFromTreasury(fund.payee, fund.startValue);

    emit PaidStart(
      id, 
      fund.payee,
      fund.startFound,
      fund.startValue
    );
  }

  function _payEnd(uint id) internal {
    Fund storage fund = _funds[id];

    _found.transferValueFromTreasury(fund.payee, fund.endValue);

    emit PaidEnd(
      id, 
      fund.payee, 
      fund.endFound,
      fund.endValue
    );
  }

  function _getFundTotal(uint id) internal view returns (uint) {
      Fund storage fund = _funds[id];
      uint fnd = fund.startFound + fund.endFound;
      uint val = fund.startValue + fund.endValue;
      return fnd + _etherToFound(val);
  }

  // convert ether to found to maintain balance in the treasury
  function _etherToFound(uint value) internal view returns (uint) {
    address treasury = address(_found);
    uint treasuryValue = treasury.balance;
    uint treasuryFound = _found.balanceOf(treasury);
    return value * (treasuryFound / treasuryValue);
  }
}
