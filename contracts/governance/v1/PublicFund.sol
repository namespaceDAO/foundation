// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import "./Arch.sol";
import "./Foundation.sol";

struct Convertible {
  address payee;
  uint found;
  uint value;
}

struct Fund {
  uint id;
  address payee;
  uint found;
  uint value;
}

abstract contract PublicFund is Arch, Foundation {
  mapping(uint => Fund) private _funds;

  event FundCreated(uint indexed id, address indexed payee, uint found, uint value);
  event FundPaid(uint indexed id, address indexed payee, uint found, uint value);

  function _totalRequest(uint propId) public view returns (uint) {
    Fund storage fund = _funds[propId];
    return fund.found + _convertValueToFound(fund.value);
  }
  
  function _addFunding(uint id, Convertible memory note) internal {
    require(
      note.value > 0 || note.found > 0, 
      "You must request some funding"
    );

    Fund storage fund = _funds[id];

    fund.id = id;
    fund.payee = note.payee;
    fund.value = note.value;
    fund.found = note.found;

    emit FundCreated(id, fund.payee, fund.value, fund.found);
  }

  function _payFund(uint id) internal {
    Fund storage fund = _funds[id];
    
    if (fund.value > 0) {
      _treasuryTransferValue(fund.payee, fund.value);
    }
    
    if (fund.found > 0) {
      _treasuryTransferFound(fund.payee, fund.value);
    }

    emit FundPaid(id, fund.payee, fund.found, fund.value);
  }
}
