// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./Capitalism.sol";
import "./Governance.sol";

// Adventure splits an ERC20 among stakers.
// Ending a stake transfers the ERC20 to an address.
// Your share is determined by when and how long you stake.
contract Adventure {
    Capitalism private _capitalism;
    Governance private _governance;
    ERC20 private _token;

    uint sharestrength = 10;
    uint epochDuration = 1 days;
    uint private _totalShares = 0;
    
    mapping(uint => uint) private _epochs;
    mapping(uint => uint) private _shares;

    receive() external payable {}
    fallback() external payable {}

    function capitalism() public view returns (Capitalism) {
        return _capitalism;
    }

    function governance() public view returns (Governance) {
        return _governance;
    }

    function startStake(StakeParams memory params) external {
        _token.transferFrom(params.founder, address(this), params.amount);
        Stake memory stake = _capitalism.startStake(params);
        _setupStake(stake.id, params.amount);
    }

    function endStake(address payee, uint id) external {
        Stake memory stake = _capitalism.endStake(msg.sender, payee, id);
        _token.transferFrom(address(this), msg.sender, stake.amount);
        _transferStakeValue(stake.id, payee);
    }

    function currentStakeValue(uint stakeId) public view returns (uint) {
        return _token.balanceOf(address(this)) * _shares[stakeId] / _totalShares;
    }

    function getShares(uint epoch, uint amount) public view returns (uint) {
        uint last = _epochs[epoch - 1];

        if (last == 0) {
            return amount;
        }

        if (last > amount * sharestrength) {
            return amount / sharestrength;
        }

        if (last < amount / sharestrength) {
            return amount * sharestrength;
        }

        return amount * amount / last;
    }

    function stakeShares(uint stakeId) public view returns (uint) {
        return _shares[stakeId];
    }

    function currentEpoch() public view returns (uint) {
        return block.timestamp / epochDuration;
    }

    function totalShares() public view returns (uint) {
        return _totalShares;
    }

    function _setupStake(uint stakeId, uint amount) internal {
        uint epoch = currentEpoch();
        uint shares = getShares(epoch, amount);

        _shares[stakeId] = shares;
        _totalShares += shares;
    }

    function _transferStakeValue(uint stakeId, address payee) internal {
        uint value = currentStakeValue(stakeId);
        _totalShares -= _shares[stakeId];
        
        if (value > 0) {
            _token.transferFrom(address(this), payee, value);
        }
    }

    function _transferValue(address to, uint amount) internal {
        bool capped = address(this).balance >= amount;
        require(capped, "Transfer exceeds balance");
        (bool success, ) = to.call{value:amount}("");
        require(success, "Treasury transfer failed");
    }

    function _addValue(uint value) internal {
        uint epoch = currentEpoch();
        _epochs[epoch] += value;
    }

    constructor(string memory name_, string memory symbol_, ERC20 coin_) {
        _token = coin_;
        _token.approve(address(this), type(uint).max);
        _capitalism = new Capitalism(address(this), name_, symbol_);
    }
}
