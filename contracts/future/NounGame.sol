// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import "./NounCard.sol";
import "./NounFund.sol";

/*

contract A has cards staked on it, 
if has stake has 1% of coin supply address can withdraw funds.

if withdrawing address is a game, you should be able 
to stake on that game and the game above

for example

          NAMESPACE
          /        \ 
        WORLD A    WORLD B
      /       \
   CITY 1    CITY 2

staking on city 2 should stake on world A and up the tree

*/

interface Descriptor {
    function tokenURI(uint nounId) external view returns (string memory);
    function dataURI(uint nounId) external view returns (string memory);
}

struct WorldParams {
    uint home;
    string name;
    string description;
}

struct World {
    uint id;
    string name;
    string description;
}

contract NounGame {
    NounCard private _card;
    uint private _worldCount;
    uint private _totalShares;

    mapping(uint => World) private _worlds;
    mapping(uint => uint) private _shares;

    function getShares(uint worldId) external view returns (uint) {
        return _shares[worldId];
    }

    function totalShares() external view returns (uint) {
        return _totalShares;
    }

    function createWorld(WorldParams memory params) external {
        World storage world = _worlds[++_worldCount];
        world.id = _worldCount;
        world.name = params.name;
        world.description = params.description;
    }

    function playCard(uint worldId, uint cardId) external {
        Card memory card = _card.getCard(cardId);
        _shares[worldId] += card.power;
        // TODO: transfer card to this address

    }
}
