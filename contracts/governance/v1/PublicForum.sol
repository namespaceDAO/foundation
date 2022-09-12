// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "./PublicFund.sol";

struct PropArgs {
    string text;
    uint expiresAt;
    Convertible note;
}

struct Prop {
    uint id;
    string text;
    address creator;
    uint createdAt;
    uint startedAt;
    uint endedAt;
    uint expiresAt;
    bool success;
}

abstract contract PublicForum is PublicFund {
  uint private _count;
  mapping(uint => Prop) private _props;
  mapping(uint => bool) private _success;

  event PropCreated(
    uint id,
    string text,
    address creator,
    uint expiresAt,
    uint createdAt
  );
  
  function propCount() public view returns (uint) { 
    return _count; 
  }

  function _createProp(PropArgs memory args) internal returns (uint) {
    Prop storage prop = _props[_count++];
    prop.id = _count;
    prop.creator = msg.sender;
    prop.text = args.text;
    prop.expiresAt = args.expiresAt;
    prop.createdAt = block.timestamp;

    _addFunding(prop.id, args.note);

    emit PropCreated(
      prop.id,
      prop.text,
      prop.creator,
      prop.expiresAt,
      prop.createdAt
    );

    return _count;
  }

  function _startProp(uint id) internal {
    require(id <= _count, "Prop not found");
    Prop storage prop = _props[id];
  
    require(prop.endedAt == 0, "Prop already ended");
    require(prop.expiresAt > block.timestamp, "Prop is past the expiresAt");

    prop.startedAt = block.timestamp;
    _payStart(id);
  }

  function _completeProp(uint id, bool success) internal returns (bool) {
    require(id <= _count, "Prop not found");
    Prop storage prop = _props[id];
  
    require(prop.startedAt > 0, "Prop not started");
    require(prop.endedAt == 0, "Prop already ended");

    if (prop.endedAt < prop.expiresAt) {
      prop.success = success;
    }

    prop.endedAt = block.timestamp;
    
    if (prop.success) {
      _payEnd(id);
    }

    return prop.success;
  }
}
