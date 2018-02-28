pragma solidity ^0.4.18;


/**
 * Math operations with safety checks
 */
library SafeMath {
  function mul(uint256 a, uint256 b) pure internal returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) pure internal returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) pure internal returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) pure internal returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }

  function max64(uint64 a, uint64 b) pure internal returns (uint64) {
    return a >= b ? a : b;
  }

  function min64(uint64 a, uint64 b) pure internal returns (uint64) {
    return a < b ? a : b;
  }

  function max256(uint256 a, uint256 b) pure internal returns (uint256) {
    return a >= b ? a : b;
  }

  function min256(uint256 a, uint256 b) pure internal returns (uint256) {
    return a < b ? a : b;
  }
}


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() public {
    owner = msg.sender;
  }


  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
      require(msg.sender == owner);
    _;
  }


  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    if (newOwner != address(0)) {
      owner = newOwner;
    }
  }

}

contract Proposal {
    // Proposal current status
    enum Status { Voting, Success, Failed }
    Status public status;

    // Proposal delivery status
    enum DeliveryStatus { Waiting, Sent, Failed }
    DeliveryStatus public deliveryStatus;

    function updateDelivery(string _documentUrl, string _documentHash, DeliveryStatus _status) public returns (bool);
}

contract Main is Ownable {
    using SafeMath for uint256;

    event EtherReceive(address _sender,
                        uint256 _value);

    
    address[] public proposals;

    /**
     * Ether receivable
     */
	function() payable public {
        EtherReceive(msg.sender, msg.value);
    }

    /**
        @dev list a pre-created proposal
        throws on any error rather then return a false flag to minimize user errors

        @param _proposal proposal address

        @return true if there's a compatible proposal, false if it wasn't
    */
    function acceptProposal(address _proposal) public onlyOwner returns (bool) {
        // TODO: Check if correct proposal
        proposals.push( _proposal );
        return true;
    }

    function updateProposalDeliverySuccess(uint256 _index, string _documentUrl, string _documentHash) public onlyOwner returns (bool) {
        Proposal proposal = Proposal(proposals[_index]);
        require(Proposal.Status.Success == proposal.status());

        return proposal.updateDelivery(_documentUrl, _documentHash, Proposal.DeliveryStatus.Sent);
    }
}
