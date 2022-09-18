// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/access/Ownable.sol";

// TODO: setTreasurer to activateTreasurer

contract Treasury is Ownable {
    mapping(address => bool) private _treasurers;  // authorized operators
    event SetTreasurer(address indexed treasurer, bool indexed active);

    receive() external payable {}
    fallback() external payable {}

    modifier onlyTreasurer() {
        require(
            _treasurers[msg.sender] && msg.sender != address(0), 
            "Treasury: caller is not the treasurer"
        );
        _;
    }

    function valueBalance() public view returns (uint) {
        return address(this).balance;
    }

    function isTreasurer(address treasurer) public view returns (bool) {
        return _treasurers[treasurer];
    }

    function setTreasurer(address treasurer, bool active) external onlyOwner {
        _treasurers[treasurer] = active;
        emit SetTreasurer(treasurer, active);
    }

    function pullValue(address to, uint amount) external onlyTreasurer {
       _pullValue(to, amount);
    }

    function _pullValue(address to, uint amount) internal {
        require(
            valueBalance() >= amount, 
            "Treasury: transfer exceeds treasury balance"
        );

        (bool success, ) = to.call{value:amount}("");
        require(success, "Treasury: transfer failed");
    }
}
