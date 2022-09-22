// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

contract Brachistochrone {
    uint private _chronos;
    uint8[] private _seed = [
        0xff, 0xd6, 0xc0, 
        0xae, 0x9f, 0x91, 
        0x85, 0x79, 0x6f, 
        0x66, 0x5d, 0x55, 
        0x4d, 0x46, 0x3f, 
        0x39, 0x33, 0x2e, 
        0x28, 0x24, 0x1f, 
        0x1b, 0x18, 0x14, 
        0x11, 0x0e, 0x0b, 
        0x09, 0x07, 0x05,
        0x04, 0x02, 0x01
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