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
                                                     
struct State {
    uint id;
    uint noun;
    string name;
    address payee;
}

contract NounFarm is ERC721 {
    constructor() ERC721("NOUN WORKER", "NOUN WORKER") {}
}

contract NounGame is ERC721 {
    Found private _found;
    NounBase private _base;
    NounData private _data;
    NounCard private _card;

    uint private _taxRate;
    uint private _stateCount;
    uint private _totalShares;

    mapping(uint => uint) private _shares;
    mapping(uint => State) private _states;

    struct StateParams {
        uint id;
        uint noun;
        string name;
        address payee;
    }

    event StateCreated(
        uint id,
        uint noun,
        string name,
        address payee
    );

    function getState(uint stateId) external returns (State memory) {
        return _requireState(stateId);
    }

    function create(StateParams memory params) external {
        _data.getNoun(params.noun);
        State storage state = _states[++_stateCount];

        state.id = _stateCount;
        state.noun = params.noun;
        state.name = params.name;
        state.payee = params.payee;

        emit StateCreated(state.id, state.noun, state.name, state.payee);
    }

    function release(uint stateId, uint amount) external {
        State memory state = _requireState(stateId);

        require(
            _shares[stateId] > _totalShares / _base.currentCoin(),
            "State needs more power to get paid"
        );

        // TODO: check shares
        // TODO: increment counts
        // TODO: burn and transfer ETH if requested

        _found.transferFrom(
            address(this), 
            state.payee, 
            amount
        );
    }

    function playCard(uint stateId, uint cardId, uint taxRate) external {
        Card memory card = _card.getCard(cardId);
        _requireState(stateId);

        _updateTaxRate(card.power, taxRate);
        _totalShares += card.power;
        _shares[stateId] += card.power;

        // TODO: transfer card to this address
    }

    function _updateTaxRate(uint power, uint tax) internal {
        require(tax < 5000, "Too damn high");
        _taxRate = (_taxRate * _totalShares + tax * power) / (_totalShares + power);
    }

    function _requireState(uint stateId) internal view returns (State memory) {
        require(stateId <= _stateCount, "Stake not found");
        return _states[stateId];
    }

    constructor() ERC721("DECLARATION OF STATE", "DECLARATION OF STATE") {}
}
