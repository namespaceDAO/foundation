// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "../../money/Ledger.sol";
import "../NounGame.sol";

struct Card {
    uint id;
    uint coinId;
    uint nounId;
    uint power;
}

contract NounCard is ERC721 {
    NounGame private _game;
    Ledger private _ledger;

    uint private _totalCards;
    
    mapping(uint => Card) private _cards;

    function getCard(uint id) external view returns (Card memory) {
        require(id <= _totalCards, "Noun card not found");
        return _cards[id];
    }

    function mint(uint to, uint coinId, uint amount) external {
        uint nounId = _game.coinToNoun(coinId);
        uint power = _game.convertValue(coinId, amount);

        Card storage card = _cards[++_totalCards];
        card.id = _totalCards;
        card.nounId = nounId;
        card.coinId = coinId;
        card.power = power;

        // TODO: burn coins
        _ledger.safeTransferFrom(
            msg.sender, 
            address(this), 
            coinId, 
            amount, 
            new bytes(0)
        );

        _mint(msg.sender, card.id);
    }

    constructor(NounGame game_) ERC721("NOUN CARD", "NOUN CARD") {
        _game = game_;
    }
}
