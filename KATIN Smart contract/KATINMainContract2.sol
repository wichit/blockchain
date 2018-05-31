pragma solidity ^0.4.24;
import "./safemath.sol";
import "./ownable.sol";
import "./erc20interface.sol";
import "./contractReceiver.sol";
import "./KATINProposal.sol";

contract Main is Ownable {
    using SafeMath for uint256;

    event EtherReceive(address _sender,
                        uint256 _value);

    
    // list of proposals, including ongoing, success and failed proposals
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

    /**
        @dev Mark a proposal as delivered
        throws on any error rather then return a false flag to minimize user errors

        @param _index index of proposal
        @param _documentUrl document that prove of delivered
        @param _documentHash sha3 hash of _documentUrl

        @return true if success, false if it wasn't
    */
    function updateProposalDeliverySuccess(uint256 _index, string _documentUrl, string _documentHash) public onlyOwner returns (bool) {
        Proposal proposal = Proposal(proposals[_index]);
        require(Proposal.Status.Success == proposal.status());

        return proposal.updateDelivery(_documentUrl, _documentHash, Proposal.DeliveryStatus.Sent);
    }

    /**
        @dev Mark a proposal as failed to deliver
        throws on any error rather then return a false flag to minimize user errors

        @param _index index of proposal
        @param _documentUrl document that prove of failed to deliver
        @param _documentHash sha3 hash of _documentUrl

        @return true if success, false if it wasn't
    */
    function updateProposalDeliveryFailed(uint256 _index, string _documentUrl, string _documentHash) public onlyOwner returns (bool) {
        Proposal proposal = Proposal(proposals[_index]);
        require(Proposal.Status.Success == proposal.status());

        return proposal.updateDelivery(_documentUrl, _documentHash, Proposal.DeliveryStatus.Failed);
    }

    function proposalCount() public view returns (uint256) {
        return proposals.length;
    }

    function newProposal(
        address _mainContract,
        address _token,
        uint256 _goal,
        string _description,
        uint _periodInMinutes,
        string _documentUrl,
        string _documentHash
    )
        public onlyOwner returns (bool)
    {
        address newProposalAddr = address(new Proposal(_mainContract, _token, _goal, _description, _periodInMinutes, _documentUrl, _documentHash));
        acceptProposal(newProposalAddr);
        return true;
    }
}
