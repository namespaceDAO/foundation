// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import "./NounData.sol";
import "./NounBank.sol";
import "./NounTime.sol";
import "./shared.sol";

contract NounGame is NounTime {
    NounBank private _bank;

    event Mint(
        address payer,
        address minter,
        uint coinId,
        uint nounId,
        uint found,
        uint coins
    );

    event Vote(
        address payer,
        address minter,
        uint coinId,
        uint nounId,
        uint found,
        uint coins
    );

    event Claim(
        address creator,
        address minter,
        uint coinId,
        uint coins
    );

    function bank() external view returns (NounBank) {
        return _bank;
    }

    function mint(
        address payer, 
        address minter, 
        uint coinId, 
        uint amount
    ) external {
        uint nounId = _collectMint(payer, coinId, amount);
        uint minted = _bank.convertCoin(coinId, amount);

        _bank.mint(minter, coinId, minted);

        emit Mint(
            payer, 
            minter, 
            coinId, 
            nounId,
            amount, 
            minted
        );
    }

    function vote(
        address payer, 
        address minter, 
        uint nounId, 
        uint amount
    ) external {
        uint coinId = _collectVote(payer, nounId, amount);
        uint bonus = _bank.difficulty();
        uint coins = bonus * amount;
        
        _bank.mint(minter, coinId, coins);

        emit Vote(
            payer, 
            minter, 
            coinId, 
            nounId, 
            amount, 
            coins
        );
    }

    function claim(
        address minter, 
        uint coinId, 
        uint amount
    ) external {
        address creator = _addClaimValue(coinId, amount);
        
        _bank.mint(minter, coinId, amount);
        
        emit Claim(
            creator,
            minter,
            coinId, 
            // TODO: nounID
            amount
        );
    }

    constructor(
        ERC20 coin_, 
        string memory baseURI_
    ) NounTime(coin_) {
        _bank = new NounBank(
            NounBase(this), 
            baseURI_
        );
    }
}
