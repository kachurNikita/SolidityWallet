// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;
pragma experimental ABIEncoderV2;


contract Wallet {
    address[] public approvers; // array of approved addresses
    uint public quorum; //  the number of approval in order if we need approve transactions

    struct Transfer {
        uint id; // transfer number
        uint amount; // amount ether to send
        address payable to; // address for who we send this ether 
        uint approvals; // who approved this transfer
        bool sent; // is this transaction was executed?
    }

    Transfer[] public transfers; // array oftransfers

    constructor (address[] memory _approvers, uint _quorum) {
        approvers = _approvers;
        quorum = _quorum;
        // when the contract has deployed, we set a values to the our arr and variable
    }

    function getApprovals() external view returns(address[] memory) {
        return approvers;
        // this function returns all approvals array
    }

    function getTransfers() external view returns (Transfer[] memory) {
        return transfers;
        // this function get all transfers;
    }

    mapping(address => mapping(uint => bool)) approvals;



    function createTransfer(uint amount, address payable to) external OnlyApproval() {
        transfers.push(Transfer(
            transfers.length,
            amount,
            to,
            0,
            false
        ));
        // with this function we create a new Transfer!
    }

    function approveTransfer(uint id) external  OnlyApproval() {
        require(transfers[id].sent == false, 'Transfer has been already sent');
        require(approvals[msg.sender][id] == false, 'Cannot approve the tranfer twice');
        approvals[msg.sender][id] == true;
        transfers[id].approvals++;
        if(transfers[id].approvals >= quorum) {
            transfers[id].sent = true;
            address payable to = transfers[id].to;
            uint amount = transfers[id].amount;
            to.transfer(amount);
        }
        // with this function we are prevent cases when somebody can transfer more than 1 time and else....
    }

    //Receive function - allows to us get ether to our wallet (smart-contract)
    receive() external payable {
    }

    modifier OnlyApproval () {
       bool allowed = false;
        for(uint i = 0; i < approvers.length; i++) {
            if(approvers[i] == msg.sender) {
                allowed = true;
            }
            require(allowed == true, 'Nope');
        }

        _;
    }

}