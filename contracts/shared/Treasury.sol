// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Treasury is Ownable {
    bool private _locked;
    address private _treasurer;  // authorized operator

    event LockTreasury(address provenance);
    event ChangeTreasurer(address indexed from, address indexed to);

    receive() external payable {}

    fallback() external payable {}

    function treasuryBalance() public view returns (uint) {
        return address(this).balance;
    }

    modifier onlyTreasurer() {
        require(
            _treasurer == msg.sender && _treasurer != address(0), 
            "Treasury: caller is not the treasurer"
        );
        _;
    }

    function treasurerAddress() public view returns (address) {
        return _treasurer;
    }

    function transferTokenFromTreasury(
        IERC20 token,
        address to, 
        uint amount
    ) external onlyTreasurer {
        token.transferFrom(address(this), to, amount);
    }

    function transferValueFromTreasury(
        address to, 
        uint amount
    ) external onlyTreasurer {
        require(
            treasuryBalance() >= amount, 
            "Treasury: transfer exceeds treasury balance"
        );

        (bool success, ) = to.call{value:amount}("");
        require(success, "Treasury: transfer failed");
    }

    function changeTreasurer(address to) external onlyOwner {
        require(!_locked, "Treasury: treasury is locked");
        emit ChangeTreasurer(_treasurer, to);
        _treasurer = to;
    }

    function lockTreasury() external onlyOwner {
        _locked = true;
        emit LockTreasury(_treasurer);
    }

    constructor() {
        _treasurer = owner();
    }
}
