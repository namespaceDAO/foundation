// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./NounCard.sol";

contract NounGame is Pausable, Ownable {
    IERC20 private _cash;
    NounCard private _card;

    uint private _totalShares;
    uint private _allowedCoins;

    mapping(uint => bool) private _coins;
    mapping(address => uint) private _shares;
    mapping(uint => address) private _stakes;

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
        _updatePlay(payee, card);
    }

    function _requirePlayableCard(Card memory card) internal view {
        require(
            _allowedCoins == 0 || _coins[card.coinId], 
            "Card is not approved"
        );
    }

    function _updatePlay(address payee, Card memory card) internal {
        address prev = _stakes[card.id];

        if (prev != address(0)) {
            _shares[prev] -= card.power;
        } else {
            _totalShares += card.power;
        }

        _stakes[card.id] = payee;
        _shares[payee] += card.power;
    }
}
