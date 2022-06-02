// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// import "@openzeppelin/contracts/access/Ownable.sol"; ONLY returns 1 owner address. Need array for multisig
import "@openzeppelin/contracts/utils/Counters.sol";

contract MultiSigWallet {
    using Counters for Counters.Counter;
    //should be private
    Counters.Counter public _txIndex;

//1.1 
    event Deposit(address indexed sender, uint amount, uint balance);
//2.3
    event SubmitTransaction(
        address indexed owner, 
        uint indexed txIndex,
        address indexed to,
        uint value
        );

//0.1 
    address[] public owners;
    mapping(address => bool) public isOwner;

//2. 
    struct Transaction {
        address to;
        uint value;
        // bytes data; //counters?
        uint txId;
        bool executed;
        uint ownersInAgreement;
    }
    Transaction[] public transactions;
    // mapping(uint => mapping(address => bool)) public isConfirmed;

//modifiers
//2.2
    modifier onlyOwner() {
        require(isOwner[msg.sender], "This is not an Owner address");
        _;
    }

//0. Starting the contract
    constructor(address[] memory _owners, uint _ownersInAgreementRequired) {

        require(_owners.length > 0, "Need to add more than 0 Owners to the MultiSig");

        require(
            _ownersInAgreementRequired > 0 && _ownersInAgreementRequired <= _owners.length,
            "Invalid number of required confirmations"    
        );

        for (uint i = 0; i < _owners.length; i++) {
            address owner = _owners[i];

            require(owner != address(0), "Invalid or Null Owner address");
            //0.1 isOwner mapping
            require(!isOwner[owner], "Owner address not unique");

            isOwner[owner] = true;
            owners.push(owner);
        }

        _ownersInAgreementRequired = _ownersInAgreementRequired;
    }

//1. Wallet requires funds
//fallback end deposit function together
    receive() external payable {
        emit Deposit(msg.sender, msg.value, address(this).balance);
    }

//2.1
    function proposeTransaction(
        address _to,
        uint _value
        // uint _txId
    )
    public onlyOwner {
        require(address(this).balance > 0, "Not enough funds in Wallet to propose transaction");

        uint txIndex = _txIndex.current();

        transactions.push(
            Transaction({
                to: _to,
                value: _value,
                txId: txIndex,
                executed: false,
                ownersInAgreement: 0
            })
        );
        _txIndex.increment();

        emit SubmitTransaction(msg.sender, txIndex, _to, _value);
    }



    function getOwners() public view returns(address[] memory) {
        return owners;
    }

}


/*
["0x5B38Da6a701c568545dCfcB03FcB875f56beddC4", "0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2"]
2

0xdD870fA1b7C4700F2BD7f44238821C26f7392148
*/