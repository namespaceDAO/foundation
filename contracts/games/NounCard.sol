// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "../nouns/NounToken.sol";
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
    uint coin;
    uint noun;
    uint amount;
    uint power;
}

contract NounCard is NounToken {
    NounMint private _bank;
    NounBase private _base;

    uint private _cardCount;
    
    mapping(uint => Card) private _cards;

    event CardForged(
        uint id,
        uint coin,
        uint noun,
        uint power
    );
    
    function bank() external view returns (NounMint) {
        return _bank;
    }
    
    function base() external view returns (NounBase) {
        return _base;
    }
    
    function cardCount() external view returns (uint) {
        return _cardCount;
    }

    function getCard(uint cardId) external view returns (Card memory) {
        return _requireCard(cardId);
    }

    function forge(uint coin, uint amount) external {
        uint noun = _base.coinToNoun(coin);
        Card storage card = _cards[++_cardCount];

        card.id = _cardCount;
        card.coin = coin;
        card.noun = noun;
        card.amount = amount;
        card.power = _bank.convertCoin(coin, amount);

        _bank.safeTransferFrom(
            msg.sender, 
            address(this), 
            coin, 
            amount,
            new bytes(0)
        );

        _mint(msg.sender, card.id);

        emit CardForged(card.id, card.coin, card.noun, card.power);
    }

    function _encodeData(uint tokenId) override internal view returns (bytes memory) {
        Card memory card = _requireCard(tokenId);

        return abi.encodePacked();
    }

    function _tokenToNoun(uint tokenId) override internal view returns (uint) {
        return _requireCard(tokenId).noun;
    }

    function _requireCard(uint cardId) internal view returns (Card memory) {
        require(cardId <= _cardCount, "Card not found");
        return _cards[cardId];
    }

    constructor(NounData data_, NounMint bank_, NounBase base_) 
    NounToken("NOUN CARD", "NOUN CARD", data_) {
        _bank = bank_;
        _base = base_;
    }
}