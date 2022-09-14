// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./PublicForum.sol";

struct StakeParams {
    uint prop;
    uint amount;
}

struct Stake {
    uint id;
    uint prop;
    address staker;
    address redeemer;
    uint amount;
    uint createdAt;
    uint expiresAt;
    uint completedAt;
    uint totalStaked;
    uint totalSupply;
}

abstract contract Capitalism is PublicForum, ERC721 {
    uint private _stakeCount;
    uint private _stakeTotal;

    mapping (uint => Stake) private _stakes;
    mapping (uint => uint) private _stakedPerProp;
    mapping (uint => uint) private _stakedPerDay;

    event StakeCreated(
        uint indexed id, 
        uint indexed prop, 
        address staker,
        uint amount,
        uint totalStaked,
        uint totalSupply
    );

    event StakeEnded(
        uint indexed id, 
        uint indexed prop, 
        address redeemer,
        uint amount,
        uint penalty,
        uint interest
    );

    function totalStaked() public view returns (uint) {
        return _stakeTotal;
    }

    function stakedPerProp(uint prop) public view returns (uint) {
        return _stakedPerProp[prop];
    }

    function stakedPerDay(uint day) public view returns (uint) {
        return _stakedPerDay[day];
    }

    function _startStake(StakeParams memory params) internal {
        require(params.amount > 0, "Must stake some FOUND");

        Prop memory prop = getProp(params.prop);
        _treasuryDepositFound(msg.sender, params.amount);
        
        Stake storage stake = _stakes[++_stakeCount];
        stake.id = _stakeCount;
        stake.prop = params.prop;
        stake.staker = msg.sender;
        stake.amount = params.amount;
        stake.createdAt = currentDay();
        stake.expiresAt = prop.expiresAt;
        stake.totalStaked = totalStaked();
        stake.totalSupply = _treasuryFoundSupply();

        _stakedPerDay[stake.createdAt] += stake.amount;
        _stakedPerProp[stake.prop] += stake.amount;
        _mint(stake.staker, stake.id);

        emit StakeCreated(
            stake.id,
            stake.prop,
            stake.staker,
            stake.amount,
            stake.totalStaked,
            stake.totalSupply
        );
    }

    function _endStake(uint stakeId) internal {
        _requireStake(stakeId);

        Stake storage stake = _stakes[stakeId];
        stake.redeemer = _requireOwner(stakeId);

        uint duration = stake.expiresAt - stake.createdAt;
        uint interest = _calculateInterest(stake, duration);

        // TODO: calculate late penalty
        uint penalty = 0;

        if (goodAccounting()) {
            _treasuryTransferFound(stake.redeemer, stake.amount + interest);
        } else {
            _treasuryTransferFound(stake.redeemer, stake.amount);
            _treasuryMintFound(stake.redeemer, interest);
        }
        
        // TODO: make sure the stake cannot be ended the same week it is started, 
        // could cause a problem by over incrementing _stakedPerDay

        _burn(stakeId);

        emit StakeEnded(
            stake.id,
            stake.prop,
            stake.redeemer,
            stake.amount,
            penalty,
            interest
        );
    }

    function _calculateInterest(Stake memory stake, uint duration) internal view returns (uint) {
        uint inflation = inflationRate();
        uint age = duration / 60 / 60 / 24 / 365;  // in years
        uint fraction = stake.totalStaked / stake.totalSupply;
        uint rate = 2 * inflation * fraction + inflation;
        uint bonus = age ** 2 / rate + age / rate;
        return bonus * stake.amount;
    }

    function _requireStake(uint stakeId) internal view {
        require(stakeId <= _stakeCount, "Stake not found");
    }

    function _requireOwner(uint stakeId) internal view returns (address) {
        require(msg.sender == ownerOf(stakeId), "You are not the stake owner");
        return msg.sender;
    }

    constructor() ERC721("FOUND STAKE", "FOUND STAKE") {}
}