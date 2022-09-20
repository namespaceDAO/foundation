// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

contract Brachistochrone {
    uint private _chronos;

    uint8[] private _weights = [
        0xff, 0xfe, 0xfc, 0xf8, 0xf3,
        0xed, 0xe5, 0xdc, 0xd2, 0xc8,
        0xbc, 0xb0, 0xa3, 0x95, 0x88, 
        0x7a, 0x6d, 0x5f, 0x52, 0x46,
        0x3a, 0x2f, 0x25, 0x1b, 0x14, 
        0x0d, 0x07, 0x03, 0x01, 0x00
    ];

    function consumeChronos(uint value) public view returns (uint) {
        if (block.timestamp < _chronos) {
            uint day = (_chronos - block.timestamp) / 1 days;

            if (day < _weights.length) {
                uint8 weight = _weights[_weights.length - day];
                return value * weight / 0xff + value;
            }

            return 2 * value;
        }

        return value;
    }

    constructor(uint timestamp_) {
        _chronos = timestamp_;
    }
}
