// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import "./NounData.sol";
import "./NounBank.sol";
import "./NounTime.sol";
import "./shared.sol";

contract NounGame is NounTime {
    NounBank private _bank;

    event Mint(
        uint coinId,
        address to,
        uint found,
        uint coins
    );

    event Vote(
        uint coinId,
        uint nounId,
        uint found,
        uint coins
    );

    event Claim(
        uint coinId,
        uint coins
    );

    function bank() external view returns (NounBank) {
        return _bank;
    }

    function mint(address from, address to, uint coinId, uint amount) external {
        _collectMint(from, coinId, amount);

        uint minted = _bank.convertCoin(coinId, amount);
        _bank.mint(to, coinId, minted);

        emit Mint(coinId, to, amount, minted);
    }

    function vote(address payee, uint nounId, uint amount) external {
        uint coinId = _collectVote(payee, nounId, amount);
        uint bonus = _bank.difficulty();
        uint coins = bonus * amount;
        
        _bank.mint(payee, coinId, coins);
        emit Vote(coinId, nounId, amount, coins);
    }

    function claim(uint coinId, uint amount) external {
        address creator = _addClaimValue(coinId, amount);
        _bank.mint(creator, coinId, amount);
        emit Claim(coinId, amount);
    }

    constructor(ERC20 coin_, string memory baseURI_) NounTime(coin_) {
        _bank = new NounBank(NounBase(this), baseURI_);
    }
}
