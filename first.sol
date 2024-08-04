// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract LaborManagement {
    // Owner of the contract
    address public owner;

    // Struct to represent a laborer
    struct Laborer {
        string name;
        uint256 id;
        uint256 totalEarnings;
        uint256 pendingPayments;
        bool registered;
    }

    // Mapping from laborer ID to Laborer struct
    mapping(uint256 => Laborer) public laborers;

    // Events to log activities
    event LaborerRegistered(uint256 id, string name);
    event PaymentMade(uint256 id, uint256 amount);
    event PaymentClaimed(uint256 id, uint256 amount);

    // Modifier to restrict access to owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    // Function to register a new laborer
    function registerLaborer(uint256 _id, string memory _name) public onlyOwner {
        require(!laborers[_id].registered, "Laborer already registered");
        
        laborers[_id] = Laborer({
            name: _name,
            id: _id,
            totalEarnings: 0,
            pendingPayments: 0,
            registered: true
        });

        emit LaborerRegistered(_id, _name);
    }

    // Function to make a payment to a laborer
    function makePayment(uint256 _id, uint256 _amount) public payable onlyOwner {
        require(laborers[_id].registered, "Laborer not registered");
        require(msg.value == _amount, "Incorrect payment amount");

        laborers[_id].pendingPayments += _amount;

        emit PaymentMade(_id, _amount);
    }

    // Function for a laborer to claim their pending payment
    function claimPayment(uint256 _id) public {
        require(laborers[_id].registered, "Laborer not registered");
        require(laborers[_id].pendingPayments > 0, "No pending payments");

        uint256 payment = laborers[_id].pendingPayments;
        laborers[_id].pendingPayments = 0;
        laborers[_id].totalEarnings += payment;

        payable(msg.sender).transfer(payment);

        emit PaymentClaimed(_id, payment);
    }

    // Function to get laborer details
    function getLaborerDetails(uint256 _id) public view returns (string memory, uint256, uint256, uint256) {
        require(laborers[_id].registered, "Laborer not registered");

        Laborer memory laborer = laborers[_id];
        return (laborer.name, laborer.id, laborer.totalEarnings, laborer.pendingPayments);
    }
}
