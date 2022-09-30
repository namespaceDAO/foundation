// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "../banking/Ledger.sol";
import "../nouns/NounBase.sol";

struct Body {
    uint id;
    uint coinId;
    uint amount;
}

contract Nounder is ERC721 {
    Ledger private _ledger;
    uint private _totalCount;
    mapping(uint => Body) private _bodies;

    function getBody(uint id) external view returns (Body memory) {
        require(id <= _totalCount, "Nounder not found");
        return _bodies[id];
    }

    function forge(uint coinId, uint amount) external {
        require(amount > 0, "Forge more than 0");

        Body storage body = _bodies[++_totalCount];
        body.id = _totalCount;
        body.coinId = coinId;
        body.amount = amount;

        bytes memory data;
        address nouner = msg.sender;
        // TODO: burn coins
        _ledger.safeTransferFrom(nouner, address(this), coinId, amount, data);

        _mint(nouner, body.id);
    }

    constructor(NounBase base_) 
    ERC721("NOUNDER", "NOUNDER") {

    }
}
