// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "../../token/Found.sol";
import "./PublicForum.sol";

struct StakeProps {
    uint prop;
    uint amount;
}

struct Stake {
    uint id;
    uint prop;
    uint amount;
    address creator;
    uint totalStaked;
    uint totalSupply;
}

contract Capitialism is PublicForum, ERC721 {
    Found private _found;
    uint private _stakeCount;
    uint private _stakeTotal;
    uint private _inflationRate = 20;

    mapping (uint => Stake) private _stakes;
    mapping (uint => uint) private _stakedOnGoal;

    event StakeCreated(uint indexed id, uint indexed prop, uint amount);

    // stake FOUND on any goal. successful goals pay interest.
    // start stake mints an NFT that is used to redeem the FOUND. 
    function startStake(StakeProps memory props) external returns (uint id) {
        require(props.amount > 0, "Must stake some FOUND");

        _found.transferFoundToTreasury(msg.sender, props.amount);
        
        Stake storage stake = _stakes[_stakeCount++];
        stake.id = id;
        stake.prop = props.prop;
        stake.creator = msg.sender;
        stake.amount = props.amount;
        stake.totalSupply = _found.totalSupply();
        stake.totalStaked = totalStaked();

        _stakedOnGoal[stake.prop] += stake.amount;
        _mint(msg.sender, stake.id);

        emit StakeCreated(stake.id, stake.prop, stake.amount);
        return _stakeCount;
    }

    // end stake burns the NFT and returns you the FOUND from the treasury.
    // you are paid intreset proportional net duration of the stake's goals.
    // stakes that do not have a net positive duration remain in the treasury.
    function endStake(uint stakeId) external {
        Stake storage stake = _stakes[stakeId];
        
        address owner = ownerOf(stakeId);
        require(msg.sender == owner, "You are not the stake owner");

        _burn(stakeId);
        _stakedOnGoal[stake.prop] -= stake.amount;

        _payStake(owner, stake);
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
        uint bonus = 2 * _inflationRate * fraction + _inflationRate;

        uint rate = age ** 2 / bonus + age / bonus;
        return stake.amount * rate;
    }

    function _payStake(address payee, Stake memory stake) internal returns (uint) {
        uint interest = _calculateInterest(stake);
        _found.transferFoundFromTreasury(payee, stake.amount + interest);
        return interest;
    }

    function totalStaked() public view returns (uint) {
        return _stakeTotal;
    }

    function totalStaked(uint bitId) public view returns (uint) {
        return _stakedOnGoal[bitId];
    }

    function _setRate(uint rate) internal {
        _inflationRate = rate;
    }
    
    function _isStartable(uint id) override internal view returns (bool) {
        return totalStaked(id) > _proposalAsk(id);
    }

    constructor(Found found_) ERC721("FOUND STAKE", "FOUND STAKE") {
        _found = found_;
    }
}