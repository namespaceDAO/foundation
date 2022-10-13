// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "../nouns/NounMint.sol";

  /*$$$$$   /$$$$$$  /$$$$$$$  /$$$$$$$ 
 /$$__  $$ /$$__  $$| $$__  $$| $$__  $$
| $$  \__/| $$  \ $$| $$  \ $$| $$  \ $$
| $$      | $$$$$$$$| $$$$$$$/| $$  | $$
| $$      | $$__  $$| $$__  $$| $$  | $$
| $$    $$| $$  | $$| $$  \ $$| $$  | $$
|  $$$$$$/| $$  | $$| $$  | $$| $$$$$$$/
 \______/ |__/  |__/|__/  |__/|______*/   

struct Card {
    uint id;
    uint coinId;
    uint nounId;
    uint amount;
    uint power;
}

contract NounCard is ERC721 {
    NounMint private _bank;
    NounBase private _base;

    uint private _cardCount;
    
    mapping(uint => Card) private _cards;

    event CardForged(
        uint id,
        uint coinId,
        uint amount
    );

    function getCard(uint cardId) external view returns (Card memory) {
        return _requireCard(cardId);
    }

    function _requireCard(uint cardId) internal view returns (Card memory) {
        require(cardId <= _cardCount, "Card not found");
        return _cards[cardId];
    }

    function coinToNoun(uint coinId) external view returns (uint nounId) {
        return _base.coinToNoun(coinId);
    }

    function forge(uint coinId, uint amount) external {
        uint nounId = _base.coinToNoun(coinId);
        Card storage card = _cards[++_cardCount];

        card.id = _cardCount;
        card.coinId = coinId;
        card.nounId = nounId;
        card.amount = amount;
        card.power = _bank.convertCoin(coinId, amount);

        _bank.safeTransferFrom(
            msg.sender, 
            address(this), 
            coinId, 
            amount,
            new bytes(0)
        );

        _mint(msg.sender, card.id);

        emit CardForged(card.id, card.coinId, card.amount);
    }

    constructor(NounMint bank_, NounBase base_) 
    ERC721("NOUN CARD", "NOUN CARD") {
        _bank = bank_;
        _base = base_;
    }
}