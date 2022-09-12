// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
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
    uint expiresAt;
}

abstract contract PublicForum is Ownable, Pausable, PublicFund {
  uint private _count;
  mapping(uint => Prop) private _props;

  event PropCreated(
    uint indexed id, address indexed creator, 
    uint expiresAt, uint createdAt, string text
  );

  function _isStartable(uint prop) virtual internal view returns (bool);
  
  function propCount() public view returns (uint) { 
    return _count; 
  }

  function createProp(PropArgs memory prop) external whenNotPaused {
      _createProp(prop);
  }

  function startProp(uint id) external {
    require(_isStartable(id), "Government: prop cannot be started");
    _startProp(id);
  }

  function pause() external onlyOwner {
    _pause();
  }

  function unpause() external onlyOwner {
    _unpause();
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
      prop.id, prop.creator,
      prop.expiresAt, prop.createdAt,
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
