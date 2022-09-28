// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

// Capitalism is an NFT that can be minted by staking an ERC20.
// When you start your stake your ERC20 is locked in the Capitalism contract.
// When you end your stake your ERC20 is transfered back to your address.
// Each stake has an expiration date. 

struct StakeParams {
    address founder;
    address owner;
    uint prop;
    uint amount; 
    uint expiresAt;
}

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
    address private _admin;
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

    modifier onlyAdmin() {
        require(msg.sender == _admin, "Caller is not the admin");
        _;
    }

    function getStake(uint id) public view returns (Stake memory) {
        _requireStake(id);
        return _stakes[id];
    }

    function startStake(StakeParams memory params) external onlyAdmin returns (Stake memory) {
        require(
            params.amount > 0, 
            "Stake more than 0"
        );

        require(
            params.expiresAt > block.timestamp  + _minimumDuration, 
            "Must expire further in the future"
        );

        _coin.transferFrom(
            params.founder,
            address(this),
            params.amount
        );

        Stake storage stake = _stakes[++_stakeCount];
        stake.id = _stakeCount;
        stake.prop = params.prop;
        stake.amount = params.amount;
        stake.expiresAt = params.expiresAt;
        stake.startTime = block.timestamp;

        _mint(params.owner, _stakeCount);

        emit StakeStarted(
            stake.id, 
            stake.prop,
            stake.amount,
            stake.expiresAt,
            stake.startTime
        );

        return stake;
    }

    function endStake(address payee, uint id) external onlyAdmin returns (Stake memory) {
        address owner = _requireOwner(id);
        Stake storage stake = _stakes[id];

        require(stake.endTime == 0, "Stake already ended");
        stake.endTime = block.timestamp;

        _burn(id);
        _coin.transferFrom(
            address(this), 
            payee, 
            stake.amount
        );

        emit StakeEnded(id, stake.prop, stake.amount, stake.endTime);

        return stake;
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
        ERC20 coin_,
        address admin_
    ) ERC721(name_, symbol_) {
        _coin = coin_;
        _admin = admin_;
    }
}