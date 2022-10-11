// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

abstract contract Token is Ownable, ERC20 {
    uint private _claim;
    address private _origin;

    event Claim(address indexed to, uint found);

    modifier onlyOrigin() {
        require(
            msg.sender == _origin, 
            "Caller is not the origin"
        );
        _;
    }

    function claimed() external view returns (uint) {
        return _claim;
    }

    function origin() external view returns (address) {
        return _origin;
    }

    function setOrigin(address origin_) external onlyOwner {
        _origin = origin_;
    }

    function claim(address to, uint amount) external onlyOrigin {
        uint totalMinted = totalSupply() - _claim;
        bool claimable = totalMinted / 10 >= amount + _claim;
        require(claimable, "Claim too large");

        _claim += amount;
        _mint(to, amount);

        emit Claim(to, amount);
    }
}