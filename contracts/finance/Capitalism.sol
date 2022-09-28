// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

// Capitalism is an NFT that can be minted by staking an ERC20.
// When you start your stake your ERC20 is locked in the Capitalism contract.
// When you end your stake your ERC20 is transfered back to your address.
// Each stake has an expiration date and Noun it was staked on.
// TODO: the art for the stake is stored on chain in the 

struct StakeParams {
    address founder;
    address owner;
    uint idea;
    uint amount; 
    uint expiryTime;
}

struct Stake {
    uint id;
    uint idea;
    uint amount;
    uint expiryTime;
    uint startTime;
    uint endTime;
    address founder;
    address redeemer;
}

abstract contract CapitalismDescriptor {
    function dataURI(Stake memory stake) virtual public view returns (string memory);
    function tokenURI(Stake memory stake) virtual public view returns (string memory);
}

contract Capitalism is ERC721 {
    CapitalismDescriptor private _desc;
    ERC20 private _coin;
    address private _admin;
    uint private _stakeCount;
    uint private _minimumDuration = 1 days;

    mapping(uint => Stake) private _stakes;
    
    event StakeStarted(
        uint id,
        uint idea,
        uint amount,
        uint expiryTime,
        uint startTime
    );

    event StakeEnded(
        uint id,
        uint idea,
        uint amount,
        uint endTime
    );

    modifier onlyAdmin() {
        require(msg.sender == _admin, "Caller is not the admin");
        _;
    }

    function dataURI(uint stakeId) public view returns (string memory) {
        return _desc.tokenURI(getStake(stakeId));
    }

    function tokenURI(uint stakeId) public view override returns (string memory) {
        return _desc.tokenURI(getStake(stakeId));
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
            params.expiryTime > block.timestamp  + _minimumDuration, 
            "Must expire further in the future"
        );

        _coin.transferFrom(
            params.founder,
            address(this),
            params.amount
        );

        Stake storage stake = _stakes[++_stakeCount];
        stake.id = _stakeCount;
        stake.idea = params.idea;
        stake.amount = params.amount;
        stake.expiryTime = params.expiryTime;
        stake.startTime = block.timestamp;
        stake.founder = params.founder;

        _mint(params.owner, _stakeCount);

        emit StakeStarted(
            stake.id, 
            stake.idea,
            stake.amount,
            stake.expiryTime,
            stake.startTime
        );

        return stake;
    }

    function endStake(address payee, uint id) external onlyAdmin returns (Stake memory) {
        address owner = _requireOwner(id);
        Stake storage stake = _stakes[id];

        require(stake.endTime == 0, "Stake already ended");
        stake.endTime = block.timestamp;
        stake.redeemer = owner;

        _burn(id);
        _coin.transferFrom(
            address(this), 
            payee, 
            stake.amount
        );

        emit StakeEnded(id, stake.idea, stake.amount, stake.endTime);

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
        address admin_,
        string memory name_,
        string memory symbol_,
        CapitalismDescriptor desc_,
        ERC20 coin_
    ) ERC721(name_, symbol_) {
        _admin = admin_;
        _coin = coin_;
        _desc = desc_;
    }
}