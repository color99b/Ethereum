// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract Fundraising {
  uint public targetAmount;
  address public owner;
  mapping(address => uint) public donations;
  uint raisedAmount;
  uint public finishTime;

  constructor(
    uint _targetAmount,
    uint _weeks,
    uint _days,
    uint _hours,
    uint _minutes,
    uint _seconds
  ) {
    targetAmount = _targetAmount;
    owner = msg.sender;
    raisedAmount = 0;
    finishTime =
      block.timestamp +
      _weeks *
      1 weeks +
      _days *
      1 days +
      _hours *
      1 hours +
      _minutes *
      1 minutes +
      _seconds *
      1 seconds;
  }

  receive() external payable {
    require(block.timestamp < finishTime, "This funding is over");
    donations[msg.sender] += msg.value;
    raisedAmount += msg.value;
  }

  function withdrawDonations() external payable {
    require(msg.sender == owner, "Funds will only be released to the owner");
    require(raisedAmount >= targetAmount, "The funding didn't reach the goal");
    require(block.timestamp > finishTime, "The funding is not over yet");

    payable(owner).transfer(raisedAmount);
  }

  function refund() external payable {
    require(block.timestamp > finishTime, "The funding is not over yet");
    require(raisedAmount < targetAmount, "The funding didn't reach the goal");
    require(donations[msg.sender] > 0, "You didn't donate to this funding");

    uint toRefund = donations[msg.sender];
    donations[msg.sender] = 0;
    payable(msg.sender).transfer(toRefund);
  }

  function cancelFund() external payable {
    require(block.timestamp < finishTime, "The funding is over ");
    require(donations[msg.sender] > 0, "You didn't donate to this funding");

    uint toRefund = donations[msg.sender];
    donations[msg.sender] = 0;
    payable(msg.sender).transfer(toRefund);
  }

  function getDonation() external view returns (uint) {
    return donations[msg.sender];
  }
}
