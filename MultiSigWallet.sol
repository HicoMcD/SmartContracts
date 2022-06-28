// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

// ToDo: OZ integration

contract MultiSigWallet {
// Events
    event Deposit(address indexed sender, uint amount, uint balance);
    event SubmitTransaction(
        address indexed owner, 
        uint indexed txIndex, 
        address indexed to,
        uint value,
        bytes data
        );
    event ConfirmTransaction(address indexed owner, uint indexed txIndex);
    event RevokeConfirmation(address indexed owner, uint indexed txIndex);
    event ExecuteTransaction(address indexed owner, uint indexed txIndex);

// Variables
    address[] public owners;
    mapping(address => bool) public isOwner;
    uint public numConfirmationsRequired;

    struct Transaction {
        address to;
        uint value;
        bytes data;
        bool executed;
        uint numConfirmations;
    }
// Transaction struc array
    Transaction[] public transactions;
    // mapping from tx index => owner => bool
    mapping(uint => mapping(address => bool)) public isConfirmed;

// (openzeppelin = only 1 owner)
    modifier onlyOwner() {
        require(isOwner[msg.sender], "Not Owner");
        _;
    }

    modifier txExists(uint _txIndex) {
        require(_txIndex < transactions.length, "tx Does not exist");
        _;
    }

    modifier notExecuted(uint _txIndex) {
        require(!transactions[_txIndex].executed, "tx Already executed");
        _;
    }

    modifier notConfirmed(uint _txIndex) {
        require(!isConfirmed[_txIndex][msg.sender], "tx Is already confirmed");
        _;
    }

// Initiate contract
    constructor(address[] memory _owners, uint _numConfirmationsRequired) {

        require(_owners.length > 0, "Owners Required");
        require(_numConfirmationsRequired > 0 &&
         _numConfirmationsRequired <= _owners.length, 
         "Invalid number of required confirmations"
         );

         for (uint i = 0; i < _owners.length; i++) {
             address owner = _owners[i];

             require(owner != address(0), "Invalid Owner Address");
             require(!isOwner[owner], "Owner not unique");

             isOwner[owner] = true;
             owners.push(owner);
         }

         numConfirmationsRequired = _numConfirmationsRequired;
    }

// Fallback
    receive() external payable{
        emit Deposit(msg.sender, msg.value, address(this).balance);
    }

// Submit Transaction for confirmation to owners of MSW
    function submitTransaction(
        //openzepplin counters
        //require(not enough funds in wallet)
        address _to,
        uint _value,
        bytes memory _data
        ) 
        public onlyOwner {
        uint txIndex = transactions.length;

        transactions.push(
            Transaction({
                to: _to,
                value: _value,
                data: _data,
                executed: false,
                numConfirmations: 0
            })
        );
        
        emit SubmitTransaction(msg.sender, txIndex, _to, _value, _data);
    }

// MultiSig owners to confirm transaction
    function confirmTransaction(uint _txIndex)
        public
        onlyOwner
        txExists(_txIndex) 
        notExecuted(_txIndex)
        notConfirmed(_txIndex)
        {
            Transaction storage transaction = transactions[_txIndex];
            transaction.numConfirmations += 1;
            isConfirmed[_txIndex][msg.sender] = true;

            emit ConfirmTransaction(msg.sender, _txIndex);
        }

// MultiSig owners to execute if enough confirmations received
    function executeTransaction(uint _txIndex)
        public
        onlyOwner
        txExists(_txIndex)
        notExecuted(_txIndex) 
        {
            Transaction storage transaction = transactions[_txIndex];

            require(
                transaction.numConfirmations >= numConfirmationsRequired,
                "Cannot execute transaction || Not enough confirmations"
            );

            transaction.executed = true;

            (bool success, ) = transaction.to.call{value: transaction.value} (
                transaction.data
            );
            require(success, "tx Failed || No funds in wallet");

            emit ExecuteTransaction(msg.sender, _txIndex);
        }

// MultiSig owners can revoke confirmation
    function revokeConfirmation(uint _txIndex) 
        public
        onlyOwner
        txExists(_txIndex)
        notExecuted(_txIndex)  {
        Transaction storage transaction = transactions[_txIndex];

        require(isConfirmed[_txIndex][msg.sender], "tx Not Confirmed yet");

        transaction.numConfirmations -= 1;
        isConfirmed[_txIndex][msg.sender] = false;

        emit RevokeConfirmation(msg.sender, _txIndex);
    }

// Get array of MSW Owners
    function getOwners() public view returns(address[] memory) {
        return owners;
    }

// Get amount of transactions submitted
    function getTransactionCount() public view returns (uint) {
        return transactions.length;
    }

// Get transaction at specific txIndex
    function getTransaction(uint _txIndex) public view returns(
                                                        address to,
                                                        uint value,
                                                        bytes memory data,
                                                        bool executed,
                                                        uint numConfirmations
                                                        ) {
        Transaction storage transaction = transactions[_txIndex];

        return(
            transaction.to,
            transaction.value,
            transaction.data,
            transaction.executed,
            transaction.numConfirmations
        );
    }

}

/*
Remix Testing
["0x5B38Da6a701c568545dCfcB03FcB875f56beddC4", "0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2"]
2

0xdD870fA1b7C4700F2BD7f44238821C26f7392148
*/