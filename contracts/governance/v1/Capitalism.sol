// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./PublicForum.sol";

struct StakeProps {
    uint prop;
    uint amount;
}

struct Stake {
    uint id;
    uint prop;
    uint week;
    uint amount;
    address creator;
    uint totalStaked;
    uint totalSupply;
}

abstract contract Capitalism is PublicForum, ERC721 {
    uint private _stakeCount;
    uint private _stakeTotal;

    mapping (uint => Stake) private _stakes;
    mapping (uint => uint) private _stakedOnGoal;
    mapping (uint => uint) private _stakedPerWeek;

    event StakeCreated(uint indexed id, uint indexed prop, uint amount);

    function totalStaked() public view returns (uint) {
        return _stakeTotal;
    }

    function totalStakedByGoal(uint bitId) public view returns (uint) {
        return _stakedOnGoal[bitId];
    }

    function totalStakedByWeek(uint week) public view returns (uint) {
        return _stakedPerWeek[week];
    }

    // stake FOUND on any goal. successful goals pay interest.
    // start stake mints an NFT that is used to redeem the FOUND. 
    function _startStake(StakeProps memory props) internal {
        require(props.amount > 0, "Must stake some FOUND");
        uint week = currentWeek();

        // TODO: ensure that this prop was started last week
        _depositTreasuryFound(msg.sender, props.amount);
        
        Stake storage stake = _stakes[_stakeCount++];
        stake.id = _stakeCount;
        stake.prop = props.prop;
        stake.week = week;
        stake.creator = msg.sender;
        stake.amount = props.amount;
        stake.totalStaked = totalStaked();
        stake.totalSupply = _totalFoundSupply();

        _stakedPerWeek[week] += stake.amount;
        _stakedOnGoal[stake.prop] += stake.amount;
        _mint(msg.sender, stake.id);

        emit StakeCreated(stake.id, stake.prop, stake.amount);
    }

    // end stake burns the NFT and returns you the FOUND from the treasury.
    // you are paid intreset proportional net duration of the stake's goals.
    // stakes that do not have a net positive duration remain in the treasury.
    function _endStake(uint stakeId) internal {
        // TODO: make sure the prop is complete
        // TODO: make sure the stake cannot be ended the same week it is started, 
        // could cause a problem by over incrementing _stakedPerWeek

        address owner = ownerOf(stakeId);
        require(msg.sender == owner, "You are not the stake owner");

        _burn(stakeId);
        _payStake(owner, stakeId);
    }

    // Start Stake 
    // - choose N projects to stake on
    // - choose X amount of FOUND to stake

    // End Stake
    // - for every project that has been completed,
    // - add the duration to the time served

    function _calculateInterest(Stake memory stake) internal view returns (uint) {
        uint duration = propDuration(stake.prop);
        uint age = duration / 60 / 60 / 24 / 365;  // in years

        uint fraction = stake.totalStaked / stake.totalSupply;
        uint inflation = inflationRate();
        uint bonus = 2 * inflation * fraction + inflation;

        uint rate = age ** 2 / bonus + age / bonus;
        return stake.amount * rate;
    }

    function _payStake(address payee, uint stakeId) internal {
        Stake storage stake = _stakes[stakeId];
        uint interest = _calculateInterest(stake);

        // TODO: late penalty
        _transferFound(payee, stake.amount);
        _mintTreasuryFound(payee, interest);
    }

    constructor() ERC721("FOUND STAKE", "FOUND STAKE") {}
}