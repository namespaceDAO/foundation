// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import "./PublicFund.sol";

struct PropArgs {
    string text;
    uint expiresAt;
    Convertible note;
}

struct Prop {
    uint id;
    uint week;
    string text;
    address creator;
    uint createdAt;
    uint startedAt;
    uint expiresAt;
}

abstract contract PublicForum is PublicFund {
  uint private _count;
  mapping(uint => Prop) private _props;

  event PropCreated(
    uint indexed id, 
    address indexed creator, 
    uint expiresAt, 
    uint createdAt, 
    string text
  );

  function propCount() public view returns (uint) { 
    return _count; 
  }

  function propDuration(uint id) public view returns (uint) {
    Prop storage prop = _props[id];
    return prop.expiresAt - prop.createdAt;
  }

  function propWeek(uint id) internal view returns (uint) {
    return _props[id].week;
  }

  function _createProp(PropArgs memory args) internal returns (uint) {
    Prop storage prop = _props[_count++];
    prop.id = _count;
    prop.creator = msg.sender;
    prop.text = args.text;
    prop.week = currentWeek();
    prop.expiresAt = args.expiresAt;
    prop.createdAt = block.timestamp;

    _addFunding(prop.id, args.note);

    emit PropCreated(
      prop.id, 
      prop.creator,
      prop.expiresAt, 
      prop.createdAt,
      prop.text
    );

    return _count;
  }

  function _startProp(uint id) internal {
    require(id <= _count, "Prop not found");
    Prop storage prop = _props[id];
  
    require(prop.startedAt == 0, "Prop already ended");
    require(prop.expiresAt > block.timestamp, "Prop is past the expiresAt");

    prop.startedAt = block.timestamp;
    _payFund(id);
  }
}
