// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "../NounGame.sol";
import "../NounBank.sol";

struct Card {
    uint id;
    uint coinId;
    uint nounId;
    uint power;
}

contract NounCard is ERC721 {
    NounGame private _game;
    NounBank private _bank;

    uint private _totalCards;
    
    mapping(uint => Card) private _cards;

    function getCard(uint id) external view returns (Card memory) {
        require(id <= _totalCards, "Noun card not found");
        return _cards[id];
    }

    function mint(address to, address from, uint coinId, uint amount) external {
        Noun memory noun = _game.coinToNoun(coinId);
        uint power = _bank.convertCoin(coinId, amount);

        Card storage card = _cards[++_totalCards];
        card.id = _totalCards;
        card.nounId = noun.id;
        card.coinId = coinId;
        card.power = power;

        _bank.safeTransferFrom(
            from, 
            address(this), 
            coinId, 
            amount, 
            new bytes(0)
        );

        _mint(to, card.id);
    }

    constructor(NounGame game_) ERC721("NOUN CARD", "NOUN CARD") {
        _game = game_;
    }
}
