// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import { Strings } from '@openzeppelin/contracts/utils/Strings.sol';

// TODO: fix comment
// Capitalism is an NFT that can be minted by staking an ERC20.
// When you start your stake your ERC20 is locked in the Capitalism contract.
// When you end your stake your ERC20 is transfered back to your address.
// Each stake has an expiration date and idea it was staked on.
// Art for the stake is stored in the descriptor contract.
struct StakeParams {
    address founder;
    address owner;
    uint idea;
    uint amount; 
    uint expiresAt;
}

struct Stake {
    uint id;
    uint idea;
    uint amount;
    uint expiresAt;
    uint startedAt;
    uint endedAt;
    address founder;
    address redeemer;
    address payee;
}

contract Capitalism is ERC721 {
    using Strings for uint;

    uint private _stakeCount;
    uint private _minimumDuration = 1 days;

    mapping(uint => Stake) private _stakes;
    
    event StakeStarted(
        uint id,
        uint idea,
        uint amount,
        uint expiresAt,
        uint startedAt
    );

    event StakeEnded(
        uint id,
        uint idea,
        uint amount,
        uint endedAt
    );

    function _startStake(
        StakeParams memory params
    ) internal returns (
        Stake memory
    ) {
        require(
            params.amount > 0, 
            "Stake more than 0"
        );

        require(
            params.expiresAt > block.timestamp  + _minimumDuration, 
            "Must expire further in the future"
        );

        Stake storage stake = _stakes[++_stakeCount];
        stake.id = _stakeCount;
        stake.idea = params.idea;
        stake.amount = params.amount;
        stake.expiresAt = params.expiresAt;
        stake.startedAt = block.timestamp;
        stake.founder = params.founder;

        _mint(params.owner, _stakeCount);

        emit StakeStarted(
            stake.id, 
            stake.idea,
            stake.amount,
            stake.expiresAt,
            stake.startedAt
        );

        return stake;
    }

    function _endStake(
        address owner,
        address payee, 
        uint id
    ) internal returns (
        Stake memory
    ) {
        require(owner == ownerOf(id), "You are not the stake owner");
        Stake storage stake = _stakes[id];

        require(stake.endedAt == 0, "Stake already ended");
        stake.endedAt = block.timestamp;
        stake.redeemer = owner;
        stake.payee = payee;

        _burn(id);

        emit StakeEnded(id, stake.idea, stake.amount, stake.endedAt);

        return stake;
    }

    function stakeCount() public view returns (uint) {
        return _stakeCount;
    }

    function getStake(uint id) public view returns (Stake memory) {
        _requireStake(id);
        return _stakes[id];
    }

    function _requireStake(uint stakeId) internal view {
        require(stakeId <= _stakeCount, "Stake not found");
    }
    
    constructor(
        string memory name_, 
        string memory symbol_
    ) ERC721(name_, symbol_) {}
}