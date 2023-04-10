// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17.0;

contract Lottery {
    struct Ticket {
        address payable holder;
        bool alreadyPurchased;
    }

    address public owner;
    address[] public players;
    mapping (address => Ticket) public tickets;

    uint private nonce;
    uint public totalTicketSupply;
    uint public unsoldTickets;
    uint public ticketPrice = 1 ether;

    event TicketPurchased(address indexed buyer, uint blockNumber);
    event LotteryWon(address indexed winner, uint blockNumber);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the contract owner can call this function.");
        _;
    }

    constructor(uint initialTicketSupply) {
        owner = msg.sender;
        totalTicketSupply = initialTicketSupply;
        unsoldTickets = totalTicketSupply;
    }

    function buyTicket() public payable {
        require(unsoldTickets > 0, "Tickets are sold out.");
        require(tickets[msg.sender].alreadyPurchased == false, "Only one ticket per address can be purchased.");
        require(msg.value == ticketPrice, "Either not enough or too much Ether was sent.");
        
        Ticket memory newTicket;
        newTicket.holder = payable(msg.sender);
        newTicket.alreadyPurchased = true;
        
        tickets[msg.sender] = newTicket;
        players.push(newTicket.holder);
        unsoldTickets--;

        emit TicketPurchased(msg.sender, block.number);
    }

    function drawWinner() public onlyOwner returns (address) {
        require(unsoldTickets < (totalTicketSupply/2), "Not enough tickets have been sold.");
        uint winningTicket = uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, nonce))) % (totalTicketSupply - unsoldTickets);
        nonce++;
        address payable winner = payable(players[winningTicket]);
        winner.transfer(address(this).balance);
        emit LotteryWon(winner, block.number);
        return winner;
    }
}