// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./NounCard.sol";

struct Play {
    uint cardId;
    address payee;
    address payer;
}

contract NounGame is Pausable, Ownable {
    IERC20 private _cash;
    NounCard private _card;

    uint private _totalShares;
    uint private _allowedCoins;

    mapping(address => uint) private _shares;
    mapping(uint => bool) private _coins;
    mapping(uint => Play) private _plays;

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }
    
    function claim(address payee, uint amount) external {
        // TODO: claim according to the number of shares
        _cash.transferFrom(address(this), payee, amount);
    }

    function move(address payee, uint cardId) external whenNotPaused {
        require(
            msg.sender == _card.ownerOf(cardId), 
            "Caller is not the correct player"
        );

        Card memory card = _card.getCard(cardId);

        _requirePlayableCard(card);
        _updatePlay(msg.sender, payee, card);
    
        _card.transferFrom(msg.sender, address(this), cardId);
    }

    function take(uint cardId) external whenNotPaused {
        Play storage play = _plays[cardId];
        Card memory card = _card.getCard(cardId);

        require(
            play.payer == msg.sender, 
            "Caller is not a player"
        );

        _updatePlay(msg.sender, address(0), card);

        _card.transferFrom(
            address(this),
            play.payer,
            cardId
        );
    }

    function _requirePlayableCard(Card memory card) internal view {
        require(
            _allowedCoins == 0 || _coins[card.coinId], 
            "Card is not approved"
        );
    }

    function _updatePlay(address payer, address payee, Card memory card) internal {
        Play storage play = _plays[card.id];

        if (play.payer != address(0)) {
            _shares[play.payee] -= card.power;
        } else {
            _totalShares += card.power;
        }

        if (payee != address(0)) {
            _shares[payee] += card.power;
        }

        play.cardId = card.id;
        play.payer = payer;
        play.payee = payee;
    }
}
