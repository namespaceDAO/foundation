// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import "./PublicFund.sol";

struct PropParams {
    string text;
    uint expiresAt;
    Convertible note;
}

struct Prop {
    uint id;
    string text;
    address author;
    uint createdAt;
    uint startedAt;
    uint expiresAt;
}

abstract contract PublicForum is PublicFund {
  uint private _propCount;
  mapping(uint => Prop) private _props;

  event PropCreated(
    uint indexed id, 
    address indexed author, 
    uint expiresAt, 
    uint createdAt, 
    string text
  );

  function getProp(uint propId) public view returns (Prop memory) {
    _requiresProp(propId);
    return _props[propId];
  }

  function propCount() public view returns (uint) { 
    return _propCount; 
  }

  function _createProp(PropParams memory params) internal returns (uint) {
    require(
      params.expiresAt > block.timestamp + 7 days,
      "Proposal expiration must be at least 7 days in the future"
    );

    Prop storage prop = _props[_propCount++];
    prop.id = _propCount;
    prop.author = msg.sender;
    prop.text = params.text;
    prop.expiresAt = params.expiresAt;
    prop.createdAt = block.timestamp;

    emit PropCreated(
      prop.id, 
      prop.author,
      prop.expiresAt, 
      prop.createdAt,
      prop.text
    );

    _addFunding(prop.id, params.note);

    return _propCount;
  }

  function _startProp(uint propId) internal {
    _requiresProp(propId);
    Prop storage prop = _props[propId];
  
    require(prop.startedAt == 0, "Prop already ended");
    require(prop.expiresAt > block.timestamp, "Prop is past the expiresAt");

    prop.startedAt = block.timestamp;
    _payFund(propId);
  }

  function _requiresProp(uint propId) internal view {
    require(propId <= _propCount, "Prop not found");
  }
}
