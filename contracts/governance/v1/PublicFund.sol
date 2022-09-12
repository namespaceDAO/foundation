// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import "../../token/Found.sol";

struct Convertible {
  address payee;
  uint startToken;
  uint startCash;
  uint endToken;
  uint endCash;
}

struct Fund {
  uint id;
  address creator;
  address payee;
  uint startToken;
  uint startCash;
  uint endToken;
  uint endCash;
}

abstract contract PublicFund {
  Found private _found;
  mapping(uint => Fund) private _funds;

  event FundCreated(
    uint id,
    address payee,
    uint startToken,
    uint startCash,
    uint endToken,
    uint endCash
  );

   event PaidStart(
    uint id,
    address payee,
    uint token,
    uint cash
  );

   event PaidEnd(
    uint id,
    address payee,
    uint token,
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
      fund.startToken,
      fund.startCash,
      fund.endToken,
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

    _found.transferValueFromTreasury(fund.payee, fund.startCash);

    emit PaidStart(
      id, 
      fund.payee,
      fund.startToken,
      fund.startCash
    );
  }

  function _payEnd(uint id) internal {
    Fund storage fund = _funds[id];

    _found.transferValueFromTreasury(fund.payee, fund.endCash);

    emit PaidEnd(
      id, 
      fund.payee, 
      fund.endToken,
      fund.endCash
    );
  }
}
