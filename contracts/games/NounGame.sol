// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "../nouns/NounData.sol";
import "../nouns/NounMint.sol";
import "../token/Found.sol";
import "./NounCard.sol";

  /*$$$$$   /$$$$$$  /$$      /$$ /$$$$$$$$  /$$$$$$ 
 /$$__  $$ /$$__  $$| $$$    /$$$| $$_____/ /$$__  $$
| $$  \__/| $$  \ $$| $$$$  /$$$$| $$      | $$  \__/
| $$ /$$$$| $$$$$$$$| $$ $$/$$ $$| $$$$$   |  $$$$$$ 
| $$|_  $$| $$__  $$| $$  $$$| $$| $$__/    \____  $$
| $$  \ $$| $$  | $$| $$\  $ | $$| $$       /$$  \ $$
|  $$$$$$/| $$  | $$| $$ \/  | $$| $$$$$$$$|  $$$$$$/
 \______/ |__/  |__/|__/     |__/|________/ \_____*/ 

contract NounGame is ERC721 {
    function playCard(uint stateId, uint cardId, uint taxRate) external {
        // Card memory card = _card.getCard(cardId);
        // _requireState(stateId);

        // _totalShares += card.power;
        // _shares[stateId] += card.power;

        // TODO: update tax rate
        // TODO: transfer card to this address
    }

    function takeCard(uint stateId, uint cardId) external {
        // Card memory card = _card.getCard(cardId);
        // _requireState(stateId);
    
        // _totalShares += card.power;
        // _shares[stateId] -= card.power;

        // TODO: update tax rate
        // TODO: transfer card to from address
    }

    constructor() ERC721("NOUN GAME", "NOUN GAME") {}
}