// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "../nouns/NounBank.sol";
import "../nouns/shared.sol";

struct Card {
    uint id;
    uint coinId;
    uint nounId;
    uint amount;
}

contract NounCard is Nounish, ERC721 {
    NounBank private _bank;
    Nounish private _base;

    uint private _cardCount;
    
    mapping(uint => Card) private _cards;

    event CardForged(
        uint id,
        uint coinId,
        uint amount
    );

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

    constructor(NounBank bank_, Nounish base_) 
    ERC721("FORGED NOUN", "FORGED NOUN") {
        _bank = bank_;
        _base = base_;
    }
}