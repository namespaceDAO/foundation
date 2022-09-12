// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import "../../token/Found.sol";

struct Convertible {
  address payee;
  uint found;
  uint value;
}

struct Fund {
  uint id;
  address creator;
  address payee;
  uint found;
  uint value;
}

abstract contract PublicFund {
  Found private _found;
  mapping(uint => Fund) private _funds;

  event FundCreated(uint indexed id, address indexed payee, uint found, uint value);
  event FundPaid(uint indexed id, address indexed payee, uint found, uint value);

  function _addFunding(uint id, Convertible memory note) internal {
    require(
      note.value > 0 || note.found > 0, 
      "You must request some funding"
    );

    Fund storage fund = _funds[id];

    fund.id = id;
    fund.creator = msg.sender;
    fund.payee = note.payee;
    fund.value = note.value;
    fund.found = note.found;

    emit FundCreated(id, fund.payee, fund.value, fund.found);
  }

  function _payFund(uint id) internal {
    Fund storage fund = _funds[id];
    
    if (fund.value > 0) {
      _found.transferValue(fund.payee, fund.value);
    }
    
    if (fund.found > 0) {
      _found.transferFound(address(_found), fund.payee, fund.found);
    }

    emit FundPaid(id, fund.payee, fund.found, fund.value);
  }

  function _proposalAsk(uint id) internal view returns (uint) {
      address treasury = address(_found);
      uint treasuryValue = treasury.balance;
      uint treasuryFound = _found.balanceOf(treasury);

      Fund storage fund = _funds[id];
      uint value = fund.value * (treasuryFound / treasuryValue);
      return fund.found + value;
  }
}
