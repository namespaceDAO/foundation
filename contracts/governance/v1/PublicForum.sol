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

  function getProp(uint id) public view returns (Prop memory) {
    _requiresProp(id);
    Prop storage prop = _props[id];
    return prop;
  }

  function propCount() public view returns (uint) { 
    return _count; 
  }

  function _requiresDelay(uint id) internal view {
    _requiresProp(id);
    require(
        _props[id].week + 1 >= currentWeek(), 
        "Proposals must be started the following week"
    );
  }

  function _createProp(PropArgs memory args) internal returns (uint) {
    require(
      args.expiresAt > block.timestamp + 7 days,
      "Proposal expiration must be at least 7 days in the future"
    );

    Prop storage prop = _props[_count++];
    prop.id = _count;
    prop.creator = msg.sender;
    prop.text = args.text;
    prop.week = currentWeek();
    prop.expiresAt = args.expiresAt;
    prop.createdAt = block.timestamp;

    emit PropCreated(
      prop.id, 
      prop.creator,
      prop.expiresAt, 
      prop.createdAt,
      prop.text
    );

    _addFunding(prop.id, args.note);

    return _count;
  }

  function _startProp(uint id) internal {
    _requiresProp(id);
    Prop storage prop = _props[id];
  
    require(prop.startedAt == 0, "Prop already ended");
    require(prop.expiresAt > block.timestamp, "Prop is past the expiresAt");

    prop.startedAt = block.timestamp;
    _payFund(id);
  }

  function _requiresProp(uint id) internal view {
    require(id <= _count, "Prop not found");
  }
}
