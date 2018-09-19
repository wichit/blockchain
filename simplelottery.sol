pragma solidity ^0.4.0;
contract SimpleLottery {
    uint public constant TICKET_PRICE = 1e16; // 0.01 ether
    
    address[] public tickets;
    address public winner;
    uint public ticketingCloses;
    
    function SimpleLottery (uint duration) public {
        ticketingCloses = now + duration;
    }
    
    function buy () public payable {
        require(msg.value == TICKET_PRICE);
        require(now < ticketingCloses);
        
        tickets.push(msg.sender);
    }
    
    function drawWinner () public {
        require(now > ticketingCloses + 3 minutes);
        require(winner == address(0));
        
        bytes32 rand = keccak256(block.blockhash(block.number-1));
        
        winner = tickets[uint(rand) % tickets.length];
    }
    
    function withdraw () public {
        require(msg.sender == winner);
        msg.sender.transfer(this.balance);
    }
    
    function () payable public {
        buy();
    }
}
