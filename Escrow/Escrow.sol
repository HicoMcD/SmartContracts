// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract Escrow{
  address public payer;
  address payable public payee;
  address public escrowAgent;
  uint public amount;

  bool public fundsReleased = false;
  
  constructor(
    address _payer, 
    address payable _payee, 
    uint _amount) {
    payer = _payer;
    payee = _payee;
    escrowAgent = msg.sender; 
    amount = _amount;
  }

  function deposit() payable public {
    require(msg.sender == payer, "Sender must be the payer");
    require(address(this).balance <= amount, "Amount must be same as Escrow amount");
  }

  function release() public {
    require(address(this).balance == amount, "Can only release funds if full amount is in Escrow contract");
    require(msg.sender == escrowAgent, "Only Escrow Agent can release funds");
    fundsReleased = true;
    payee.transfer(amount);
  }
  
  function balanceOf() view public returns(uint) {
    return address(this).balance;
  }

  function changeAmount(uint _amount) public {
    require(msg.sender == payee, "Only the Payee can change the amount");
    require(fundsReleased == true, "Funds must be released before amount can be changed");
    amount = _amount;
    fundsReleased = false;
  }
}
