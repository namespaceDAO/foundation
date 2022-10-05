// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import "./NounData.sol";
import "./NounBank.sol";
import "./NounNote.sol";
import "./shared.sol";

contract NounGame is NounNote {
    IERC20 private _cash; 
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
        uint nounId,
        uint coins
    );

    function bank() external view returns (NounBank) {
        return _bank;
    }

    // function stake(
    //     address payer,
    //     address minter,
    //     uint found
    // ) internal {
    //     _startStake();
    // }

    // function burn(
    //     address payer,
    // ) internal {
    //     _endStake()
    // }

    function mint(
        address payer, 
        address minter, 
        uint coinId, 
        uint found
    ) external {
        uint nounId = _collectMint(coinId, found);
        uint minted = _bank.convertCoin(coinId, found);

        _cash.transferFrom(payer, address(this), found);
        _bank.mint(minter, coinId, minted);

        emit Mint(
            payer, 
            minter, 
            coinId, 
            nounId,
            found, 
            minted
        );
    }

    function vote(
        address payer, 
        address minter, 
        uint nounId, 
        uint found
    ) external {
        uint minted = found * _bank.difficulty();
        uint coinId = _collectVote(nounId, minted);
        
        _cash.transferFrom(payer, address(this), found);
        _bank.mint(minter, coinId, minted);

        emit Vote(
            payer,
            minter, 
            coinId,
            nounId, 
            found,
            minted
        );
    }

    function claim(
        address minter, 
        uint coinId, 
        uint amount
    ) external {
        Noun memory noun = coinToNoun(coinId);
        _bank.mint(minter, coinId, amount);
        
        emit Claim(
            noun.creator,
            minter,
            coinId, 
            noun.id,
            amount
        );
    }

    constructor(
        IERC20 cash_, 
        NounData data_,
        string memory baseURI_
    ) NounNote(cash_, data_) {
        NounBased _base = NounBased(address(this));
        _bank = new NounBank(data_, _base, baseURI_);
    }
}
