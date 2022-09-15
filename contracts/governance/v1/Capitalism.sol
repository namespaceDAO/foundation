// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./PublicForum.sol";

struct StakeParams {
    uint prop;
    uint amount;
    string reason;
}

struct Stake {
    uint id;
    uint prop;
    address staker;
    address redeemer;
    string reason;
    uint amount;
    uint createdAt;
    uint expiresAt;
    uint completedAt;
    uint totalStaked;
    uint totalSupply;
    uint penalty;
    uint interest;
}

abstract contract Capitalism is PublicForum, ERC721 {
    uint private _stakeCount;
    uint private _stakeTotal;
    string private _tokenURI;

    mapping(uint => Stake) private _stakes;
    mapping(uint => uint) private _stakedOnProp;
    mapping(uint => uint) private _stakedPerDay;

    event StakeStarted(
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

    function setTokenURI(string memory tokenURI_) external onlyOwner {
        _tokenURI = tokenURI_;
    }

    function _baseURI() internal view override returns (string memory) {
        return _tokenURI;
    }

    function stakeCount() public view returns (uint) {
        return _stakeCount;
    }

    function totalStaked() public view returns (uint) {
        return _stakeTotal;
    }

    function stakedOnProp(uint propId) public view returns (uint) {
        return _stakedOnProp[propId];
    }

    function stakedPerDay(uint day) public view returns (uint) {
        return _stakedPerDay[day];
    }

    function getStake(uint stakeId) public view returns (Stake memory) {
        _requireStake(stakeId);
        return _stakes[stakeId];
    }

    function _startStake(StakeParams memory params) internal {
        require(
            params.amount > 0, 
            "Must stake some FOUND"
        );

        Prop memory prop = getProp(params.prop);
        _treasuryDepositFound(msg.sender, params.amount);

        require(
            prop.expiresAt > block.timestamp, 
            "Prop has expired"
        );

        Stake storage stake = _stakes[++_stakeCount];
        stake.id = _stakeCount;
        stake.prop = params.prop;
        stake.staker = msg.sender;
        stake.reason = params.reason;
        stake.amount = params.amount;
        stake.createdAt = block.timestamp;
        stake.expiresAt = prop.expiresAt;
        stake.totalStaked = totalStaked();
        stake.totalSupply = _totalFoundSupply();

        _stakedPerDay[currentDay()] += stake.amount;
        _stakedOnProp[stake.prop] += stake.amount;
        _mint(stake.staker, stake.id);

        emit StakeStarted(
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

        require(
            stake.completedAt == 0,
            "Stake has already been completed"
        );

        require(
            block.timestamp >= stake.createdAt + minimumDuration(),
            "Stake is too early"
        );

        stake.completedAt = block.timestamp;
        stake.redeemer = _requireOwner(stakeId);
        (stake.penalty, stake.interest) = _payStake(stake);

        _burn(stakeId);

        emit StakeEnded(
            stake.id,
            stake.prop,
            stake.redeemer,
            stake.amount,
            stake.penalty,
            stake.interest
        );
    }

    function _payStake(Stake memory stake) internal returns (uint, uint) {
        uint penalty = _calculatePenalty(stake);
        uint duration = _calculateDuration(stake);
        uint interest = _calculateInterest(stake, duration);

        if (interest > penalty) {
            if (goodAccounting()) {
                _treasuryTransferFound(stake.redeemer, stake.amount + interest - penalty);
            } else {
                _treasuryTransferFound(stake.redeemer, stake.amount);
                _treasuryMintFound(stake.redeemer, interest - penalty);
            }
        } else if (stake.amount > penalty) {
            _treasuryTransferFound(stake.redeemer, stake.amount - penalty);
        }

        return (penalty, interest);
    }

    function _calculateDuration(Stake memory stake) internal view returns (uint) {
        if (stake.expiresAt > block.timestamp) {
            return block.timestamp - stake.createdAt;
        } else {
            return stake.expiresAt - stake.createdAt;
        }
    }

    function _calculateInterest(Stake memory stake, uint time) internal view returns (uint) {
        uint inflation = inflationRate();

        uint age = time / 60 / 60 / 24 / 365; // in years
        uint fraction = stake.totalStaked / stake.totalSupply;
        uint rate = 2 * inflation * fraction + inflation;
        uint bonus = age ** 2 / rate + age / rate;
        return bonus * stake.amount;
    }

    function _calculatePenalty(Stake memory stake) internal view returns (uint) {
        if (stake.expiresAt > block.timestamp) {
            uint early = stake.expiresAt - block.timestamp;
            return _calculateInterest(stake, early);
        } else {
            uint extra = block.timestamp - stake.expiresAt;
            uint limit = penaltyDuration();

            if (extra > limit) {
                return _calculateInterest(stake, extra - limit);
            }
        }

        return 0;
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
