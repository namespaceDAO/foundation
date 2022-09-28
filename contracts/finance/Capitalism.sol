// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

struct Stake {
    uint id;
    uint prop;
    uint amount;
    uint expiresAt;
    uint startTime;
    uint endTime;
}

contract Capitalism is ERC721 {
    ERC20 private _coin;
    uint private _stakeCount;
    uint private _minimumDuration = 1 days;

    mapping(uint => Stake) private _stakes;
    
    event StakeStarted(
        uint id,
        uint prop,
        uint amount,
        uint expiresAt,
        uint startTime
    );

    event StakeEnded(
        uint id,
        uint prop,
        uint amount,
        uint endTime
    );

    function startStake(
        address founder,
        address owner,
        uint prop,
        uint amount, 
        uint expiresAt
    ) external {
        require(
            amount > 0, 
            "Stake more than 0"
        );

        require(
            expiresAt > block.timestamp  + _minimumDuration, 
            "Must expire further in the future"
        );

        _coin.transferFrom(
            founder,
            address(this),
            amount
        );

        Stake storage stake = _stakes[++_stakeCount];
        stake.id = _stakeCount;
        stake.prop = prop;
        stake.amount = amount;
        stake.expiresAt = expiresAt;
        stake.startTime = block.timestamp;

        _mint(owner, _stakeCount);

        emit StartStake(id, prop, amount, expiresAt, stake.startTime);
    }

    function endStake(
        address payee,
        uint id
    ) external returns (uint under, uint over) {
        address owner = _requireOwner(stakeId);
        Stake storage stake = _stakes[id];

        require(stake.endTime == 0, "Stake already ended");
        stake.endTime = block.timestamp;

        _burn(id);
        _coin.transferFrom(
            address(this), 
            payee, 
            stake.amount
        );

        emit StakeEnded(id, stake.prop, amount, stake.endTime);
    }

    function _requireStake(uint stakeId) internal view {
        require(stakeId <= _stakeCount, "Stake not found");
    }

    function _requireOwner(uint stakeId) internal view returns (address) {
        require(msg.sender == ownerOf(stakeId), "You are not the stake owner");
        return msg.sender;
    }

    constructor(
        string memory name_,
        string memory symbol_,
        ERC20 coin_
    ) ERC721(name_, symbol_) {
        _coin = coin_;
    }
}