// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "../ledger/Ledger.sol";

struct Vote {
    uint id;
    uint coinId;
    uint amount;
    uint castAt;
    bool support;
}

abstract contract Board {
    Ledger private _coin;

    mapping(address => mapping(uint => Vote)) _votes;
    mapping(uint => uint) _totalSupport;
    mapping(uint => uint) _totalAgainst;

    function currentTally(uint id) public view returns (uint) {
        uint support = _totalSupport[id];
        uint against = _totalAgainst[id];

        if (against >= support) {
            return 0;
        }

        return support - against;
    }

    function _requireBalance(address account, uint coinId, uint amount) internal view {
        require(
            _coin.balanceOf(account, coinId) >= amount, 
            "You do not have enough of that coin"
        );
    }

    function _castVote(Vote memory vote) internal {
        address voter = msg.sender;
        _requireBalance(voter, vote.coinId, vote.amount);

        // TODO: check if proposal has ended
        Vote storage v = _votes[voter][vote.id];
        v.id = vote.id;
        v.coinId = vote.coinId;
        v.amount = vote.amount;
        v.castAt = block.timestamp;
        v.support = vote.support;

        // TODO: ensure that we dont allow double counting of votes
        // uint total = _coin.conversionRate(v.coinId, v.amount);
        // if (vote.support) {
        //     _totalSupport[vote.id] += total;
        // } else {
        //     _totalAgainst[vote.id] += total;
        // }
    }
}
