// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/access/Ownable.sol";

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

    function treasuryValueBalance() public view returns (uint) {
        return address(this).balance;
    }

    function isTreasurer(address treasurer) public view returns (bool) {
        return _treasurers[treasurer];
    }

    function setTreasurer(address treasurer, bool active) external onlyOwner {
        _treasurers[treasurer] = active;
        emit SetTreasurer(treasurer, active);
    }

    function transferValue(address to, uint amount) external onlyTreasurer {
       _transferValue(to, amount);
    }

    function _transferValue(address to, uint amount) internal {
        require(
            treasuryValueBalance() >= amount, 
            "Treasury: transfer exceeds treasury balance"
        );

        (bool success, ) = to.call{value:amount}("");
        require(success, "Treasury: transfer failed");
    }
}
