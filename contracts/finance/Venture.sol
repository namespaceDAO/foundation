// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./Capitalism.sol";
import "./Governance.sol";
import "./Treasury.sol";

// Venture splits ETH among capitalist stakers.
// Ending a stake transfers ETH to an address.
// Your share is determined by when you stake.
// Longer pays better. Shorter pays sooner.
contract Venture is Treasury {
    Capitalism private _capitalism;
    Governance private _governance;

    uint amplitude = 10;
    uint epochDuration = 28 days;
    uint private _totalShares = 0;
    
    mapping(uint => uint) private _epochs;
    mapping(uint => uint) private _shares;

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

    function startStake(StakeParams memory params) external {
        Stake memory stake = _capitalism.startStake(params);

        uint epoch = currentEpoch();
        uint count = getShares(epoch, params.amount);

        _epochs[epoch] += params.amount;
        _shares[stake.id] = count;
        _totalShares += count;
    }

    function endStake(address payee, uint id) external {
        Stake memory stake = _capitalism.endStake(payee, id);
        _payStake(payee, stake);
    }

    function _payStake(address payee, Stake memory stake) internal {
        uint balance = currentBalance();
        uint shares = _shares[stake.id];
        uint supply = totalShares();
        uint value = balance * shares / supply;

        _totalShares -= shares;

        if (value > 0) {
            _transferValue(payee, value);
        }
    }

    function currentEpoch() public view returns (uint) {
        return block.timestamp / epochDuration;
    }

    function capitalism() public view returns (Capitalism) {
        return _capitalism;
    }

    function governance() public view returns (Governance) {
        return _governance;
    }

    function totalShares() public view returns (uint) {
        return _totalShares;
    }

    function _addValue(uint value) internal {
        _epochs[currentEpoch()] += value;
    }

    constructor(
        string memory name_,
        string memory symbol_,
        ERC20 coin_
    ) {
        _capitalism = new Capitalism(
            name_,
            symbol_,
            coin_,
            address(this)
        );
    }
}
