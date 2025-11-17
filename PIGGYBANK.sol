// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;


/*
* Auto-Saving Piggy Bank (Self-Growing Wallet)
* Features:
* - Accept ETH deposits
* - Time-lock for 30 days
* - Withdraw only after unlock time
* - Simple interest rewards
* - Emergency withdrawal without interest
*/


contract PiggyBank {
address public owner;
uint256 public lockTime;
uint256 public totalDeposited;
uint256 public interestRate = 5; // 5% simple interest


bool public emergencyTriggered = false;


constructor() {
owner = msg.sender;
lockTime = block.timestamp + 30 days; // automatic 30-day lock
}


// Accept ETH deposits
receive() external payable {
require(!emergencyTriggered, "Emergency activated, no deposits allowed");
totalDeposited += msg.value;
}


// Calculate simple interest
function calculateInterest() public view returns (uint256) {
return (totalDeposited * interestRate) / 100;
}


// Withdraw after lock time + interest
function withdraw() public {
require(msg.sender == owner, "Only owner");
require(block.timestamp >= lockTime, "Funds are still locked");
require(!emergencyTriggered, "Emergency active, no interest withdrawal");


uint256 interest = calculateInterest();
uint256 amount = totalDeposited + interest;
totalDeposited = 0;


payable(owner).transfer(amount);
}


// Emergency withdrawal anytime (no interest)
function emergencyWithdraw() public {
require(msg.sender == owner, "Only owner");
emergencyTriggered = true;


uint256 amount = address(this).balance;
totalDeposited = 0;
payable(owner).transfer(amount);
}


// Time remaining before withdrawal
function remainingLockTime() public view returns (uint256) {
if (block.timestamp >= lockTime) return 0;
return lockTime - block.timestamp;
}
}
