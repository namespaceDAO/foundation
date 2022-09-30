// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import { Strings } from '@openzeppelin/contracts/utils/Strings.sol';

// TODO: fix comment
// Capitalism is an NFT that can be minted by staking an ERC20.
// When you start your stake your ERC20 is locked in the Capitalism contract.
// When you end your stake your ERC20 is transfered back to your address.
// Each stake has an expiration date and Noun it was staked on.
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
}

contract Capitalism is ERC721 {
    using Strings for uint;
    address private _admin;
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

    modifier onlyAdmin() {
        require(msg.sender == _admin, "Caller is not the admin");
        _;
    }

    function startStake(
        StakeParams memory params
    ) external onlyAdmin returns (
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

    function endStake(
        address owner,
        address payee, 
        uint id
    ) external onlyAdmin returns (
        Stake memory
    ) {
        require(owner == ownerOf(id), "You are not the stake owner");
        Stake storage stake = _stakes[id];

        require(stake.endedAt == 0, "Stake already ended");
        stake.endedAt = block.timestamp;
        stake.redeemer = owner;

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

    function _requireOwner(uint founder, uint stakeId) internal view returns (address) {
        return msg.sender;
    }

    function dataURI(uint stakeId) public view returns (string memory) {
        return string(
            abi.encodePacked(
                'data:application/json;base64,',
                _dataJSON(stakeId)
                // Base64.encode(_stakeJSON(stake))
            )
        );
    }

    function dataJSON(uint stakeId) public view returns (string memory) {
        return string(_dataJSON(stakeId));
    }

    function tokenURI(uint stakeId) public view override returns (string memory) {
        return dataURI(stakeId);
    }
    
    function _dataJSON(uint stakeId) internal view returns (bytes memory) {
        _requireStake(stakeId);
        Stake memory stake = _stakes[stakeId];
        return abi.encodePacked(
            '{',
                '"id":"', stake.id.toString(), '",',
                '"idea":"', stake.idea.toString(), '",',
                '"amount":"', stake.amount.toString(), '",',
                '"expiresAt":"', stake.expiresAt.toString(), '",',
                '"startedAt":"', stake.startedAt.toString(), '",',
                '"endedAt":"', stake.endedAt.toString(), '"',
            '}'
        );
    }

    constructor(
        address admin_,
        string memory name_,
        string memory symbol_
    ) ERC721(name_, symbol_) {
        _admin = admin_;
    }
}