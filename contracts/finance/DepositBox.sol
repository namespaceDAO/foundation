// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

contract DepositBox {
    event PayeeAdded(address account, uint shares);
    event PayeeRemoved(address account, uint shares);
    event PaymentReleased(address to, uint amount);
    event PaymentReceived(address from, uint amount);

    uint private _totalShares;
    uint private _totalReleased;
    address[] private _payees;

    mapping(address => uint) private _shares;
    mapping(address => uint) private _released;

    fallback() external payable {}
    receive() external payable {
        emit PaymentReceived(msg.sender, msg.value);
    }

    function currentBalance() public view returns (uint) {
        return address(this).balance;
    } 

    function _transferValue(address to, uint amount) internal {
        require(
            address(this).balance >= amount, 
            "Treasury transfer exceeds balance"
        );
        (bool success, ) = to.call{value:amount}("");
        require(success, "Treasury transfer failed");
    }

    function totalShares() public view returns (uint) {
        return _totalShares;
    }

    function totalReleased() public view returns (uint) {
        return _totalReleased;
    }

    function shares(address account) public view returns (uint) {
        return _shares[account];
    }

    function released(address account) public view returns (uint) {
        return _released[account];
    }

    function payee(uint index) public view returns (address) {
        return _payees[index];
    }

    function releasable(address account) public view returns (uint) {
        uint totalReceived = address(this).balance + totalReleased();
        return _pendingPayment(account, totalReceived, released(account));
    }
    
    function release(address payable account) public virtual {
        require(_shares[account] > 0, "PaymentSplitter: account has no shares");

        uint payment = releasable(account);

        require(payment != 0, "PaymentSplitter: account is not due payment");

        _released[account] += payment;
        _totalReleased += payment;

        _transferValue(account, payment);
        emit PaymentReleased(account, payment);
    }

    function _pendingPayment(
        address account,
        uint totalReceived,
        uint alreadyReleased
    ) private view returns (uint) {
        return (totalReceived * _shares[account]) / _totalShares - alreadyReleased;
    }

    function _addPayee(address account, uint shares_) private {
        require(account != address(0), "PaymentSplitter: account is the zero address");
        require(shares_ > 0, "PaymentSplitter: shares are 0");
        require(_shares[account] == 0, "PaymentSplitter: account already has shares");

        _payees.push(account);
        _shares[account] = shares_;
        _totalShares = _totalShares + shares_;
        emit PayeeAdded(account, shares_);
    }
}