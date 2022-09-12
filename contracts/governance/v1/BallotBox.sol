// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import "../../token/Found.sol";

struct Vote {
    uint id;
    uint amount;
    uint castAt;
    bool support;
}

abstract contract BallotBox {
    Found private _found;

    mapping(address => mapping(uint => Vote)) _votes;
    mapping(uint => uint) _totalSupport;
    mapping(uint => uint) _totalAgainst;
    
    function castVote(Vote memory vote) external {
        return _castVote(vote);
    }

    function castManyVotes(Vote[] memory votes) external {
        for (uint i = 0; i < votes.length; i += 1) {
            _castVote(votes[i]);
        }
    }

    function _meetsQuorum(uint id) public view returns (bool) {
        uint support = _totalSupport[id];
        uint against = _totalAgainst[id];
        return support >= against;
    }

    function _requireBalance(address account, uint amount) internal view {
        require(
            _found.balanceOf(account) >= amount, 
            "You do not have enough FOUND"
        );
    }

    function _castVote(Vote memory vote) internal {
        address voter = msg.sender;
        _requireBalance(voter, vote.amount);

        // TODO: check if proposal has ended
        Vote storage v = _votes[voter][vote.id];
        v.id = vote.id;
        v.amount = vote.amount;
        v.castAt = block.timestamp;
        v.support = vote.support;

        // TODO: ensure that we dont allow double counting of votes
        // uint total = _treasury.conversionRate(v.coinId, v.amount);
        // if (vote.support) {
        //     _totalSupport[vote.id] += total;
        // } else {
        //     _totalAgainst[vote.id] += total;
        // }
    }
}
