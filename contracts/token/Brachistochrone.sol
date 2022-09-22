// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

contract Brachistochrone {
    uint private _chronos;
    uint8[] private _seed = [
        0xff, 0xfe, 0xfc, 
        0xf9, 0xf5, 0xef, 
        0xe8, 0xe1, 0xd8, 
        0xcf, 0xc4, 0xb9, 
        0xae, 0xa2, 0x96,
        0x89, 0x7c, 0x70, 
        0x63, 0x57, 0x4b, 
        0x40, 0x35, 0x2b, 
        0x22, 0x1a, 0x13, 
        0x0c, 0x07, 0x04, 
        0x02, 0x00, 0x00
    ];

    function consume(uint value) public view returns (uint) {
        if (block.timestamp < _chronos) {
            uint day = (_chronos - block.timestamp) / 1 days;

            if (day < _seed.length) {
                uint yesterday = _seed[_seed.length - day];
                return yesterday * value / 0xff + value;
            }

            return 2 * value;
        }

        return value;
    }

    constructor(uint ophism_) {
        _chronos = ophism_;
    }
}