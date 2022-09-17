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
    string conclusion;
    address author;
    uint createdAt;
    uint startedAt;
    uint expiresAt;
    uint completedAt;
    Fund fund;
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

  // TODO add fund
  event PropStarted(
    uint indexed id
  );

  event PropCompleted(
    uint indexed id, 
    string text
  );

  function propCount() public view returns (uint) { 
    return _propCount; 
  }

  function getProp(uint propId) public view returns (Prop memory) {
    _requiresProp(propId);
    return _props[propId];
  }

  function _createProp(PropParams memory params) internal returns (uint) {
    require(
      params.expiresAt >= block.timestamp + minimumDuration(),
      "Proposal window is too short"
    );

    require(
      params.expiresAt <= block.timestamp + maximumDuration(), 
      "Proposal window is too long"
    );

    Prop storage prop = _props[++_propCount];
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

    prop.fund = _addFunding(prop.id, params.note);

    return _propCount;
  }

  function _startProp(uint propId) internal {
    _requiresProp(propId);
    Prop storage prop = _props[propId];
  
    require(prop.startedAt == 0, "Prop has been started");
    require(prop.expiresAt > block.timestamp, "Prop is expired");

    prop.startedAt = block.timestamp;
    _payFund(propId);

    emit PropStarted(propId);
  }

  function _completeProp(uint propId, string memory conclusion) internal {
    _requiresProp(propId);
    Prop storage prop = _props[propId];
  
    require(prop.startedAt != 0, "Prop hasn't started");
    require(prop.expiresAt > block.timestamp, "Prop is expired");

    prop.completedAt = block.timestamp;
    prop.conclusion = conclusion;

    emit PropCompleted(propId, conclusion);
  }

  function _requiresProp(uint propId) internal view {
    require(propId <= _propCount, "Prop not found");
  }
}
