// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "../ledger/Ledger.sol";

struct Convertible {
  address payee;
  uint startCash;
  uint endCash;
}

struct Fund {
  uint id;
  address creator;
  address payee;
  uint startCash;
  uint endCash;
}

abstract contract Payable {
  Ledger private _coin;
  mapping(uint => Fund) private _funds;

  event FundCreated(
    uint id,
    address payee,
    uint startCash,
    uint endCash
  );

   event PaidStart(
    uint id,
    address payee,
    uint cash
  );

   event PaidEnd(
    uint id,
    address payee,
    uint cash
  );

  function _addFunding(uint id, Convertible memory note) internal {
    require(
      note.startCash > 0 || note.endCash > 0, 
      "You must request some funding"
    );

    Fund storage fund = _funds[id];

    fund.id = id;
    fund.creator = msg.sender;
    fund.payee = note.payee;
    fund.startCash = note.startCash;
    fund.endCash = note.endCash;

    emit FundCreated(
      fund.id,
      fund.payee,
      fund.startCash,
      fund.endCash
    );
  }

  function _getCash(uint id) internal view returns (
    uint startCash, 
    uint endCash
  ) {
    Fund storage fund = _funds[id];
    return (fund.startCash, fund.endCash);
  }

  function _payStart(uint id) internal {
    Fund storage fund = _funds[id];

    _coin.transferValueFromTreasury(fund.payee, fund.startCash);

    emit PaidStart(
      id, 
      fund.payee,
      fund.startCash
    );
  }

  function _payEnd(uint id) internal {
    Fund storage fund = _funds[id];

    _coin.transferValueFromTreasury(fund.payee, fund.endCash);

    emit PaidEnd(
      id, 
      fund.payee, 
      fund.endCash
    );
  }
}
