// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./BallotBox.sol";
import "./PublicForum.sol";
import "../../Found.sol";

// What being has four legs, then two, and then three?
contract GovernmentV1 is Ownable, Pausable, BallotBox, PublicForum {
    Found private _found;

    function _meetsQuorum(uint prop, bool start) internal view returns (bool) {
        uint startCash; uint endCash;
        (startCash, endCash) = _getCash(prop);
        uint ask = start ? startCash : endCash;
        uint bid = currentTally(prop);
        return bid > ask;
    }

    function _isStartable(uint prop) internal view returns (bool) {
        return _meetsQuorum(prop, false);
    }

    function _isCompleted(uint prop) internal view returns (bool) {
        return _meetsQuorum(prop, true);
    }

    function createProp(PropArgs memory prop) external whenNotPaused {
        _createProp(prop);
    }

    function startProp(uint id) external {
        require(_isStartable(id), "Government: prop cannot be started");
        _startProp(id);
    }

    function completeProp(uint id) external {
        bool completed = _isCompleted(id);
        _completeProp(id, completed);
    }
    
    function castVote(Vote memory vote) external {
        return _castVote(vote);
    }

    function castManyVotes(Vote[] memory votes) external {
        for (uint i = 0; i < votes.length; i += 1) {
            _castVote(votes[i]);
        }
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    constructor(Found found_) {
        _found = found_;
    }
}
