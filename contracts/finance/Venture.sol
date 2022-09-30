// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./Capitalism.sol";
import "./Governance.sol";
import "./Treasury.sol";

// Venture splits ETH among capitalist stakers.
// Ending a stake transfers ETH to an address.
// Your share is determined by when you stake.
contract Venture is Treasury {
    Capitalism private _capitalism;
    Governance private _governance;
    ERC20 private _coin;

    uint amplitude = 10;
    uint epochDuration = 1 days;
    uint private _totalShares = 0;
    
    mapping(uint => uint) private _epochs;
    mapping(uint => uint) private _shares;

    function startStake(StakeParams memory params) external {
        _coin.transferFrom(
            params.founder,
            address(this),
            params.amount
        );

        Stake memory stake = _capitalism.startStake(params);
        
        _setupStake(stake.id, params.amount);
    }

    function endStake(address payee, uint id) external {
        Stake memory stake = _capitalism.endStake(msg.sender, payee, id);
        
        _coin.transfer(msg.sender, stake.amount);

        _payStakeValue(stake.id, payee);
    }

    function getShares(uint epoch, uint amount) public view returns (uint) {
        uint last = _epochs[epoch - 1];

        if (last == 0) {
            return amount;
        }

        if (last > amount * amplitude) {
            return amount / amplitude;
        }

        if (last < amount / amplitude) {
            return amount * amplitude;
        }

        return amount * amount / last;
    }

    function stakeShares(uint stakeId) public view returns (uint) {
        return _shares[stakeId];
    }

    function currentStakeValue(uint stakeId) public view returns (uint) {
        return currentBalance() * stakeShares(stakeId) / totalShares();
    }

    function currentEpoch() public view returns (uint) {
        return block.timestamp / epochDuration;
    }

    function totalShares() public view returns (uint) {
        return _totalShares;
    }

    function capitalism() public view returns (Capitalism) {
        return _capitalism;
    }

    function governance() public view returns (Governance) {
        return _governance;
    }

    function _setupStake(uint stakeId, uint amount) internal {
        uint epoch = currentEpoch();
        uint shares = getShares(epoch, amount);

        _shares[stakeId] = shares;
        _totalShares += shares;
    }

    function _payStakeValue(uint stakeId, address payee) internal {
        uint value = currentStakeValue(stakeId);
        _totalShares -= stakeShares(stakeId);
        if (value > 0) _transferValue(payee, value);
    }

    function _addValue(uint value) internal {
        uint epoch = currentEpoch();
        _epochs[epoch] += value;
    }

    constructor(
        string memory name_, 
        string memory symbol_,
        TreasuryNote note_, 
        ERC20 coin_
    ) {
        _coin = coin_;
        _capitalism = new Capitalism(
            address(this), 
            name_, 
            symbol_, 
            note_
        );
    }
}
