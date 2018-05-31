pragma solidity ^0.4.24;

import "./safemath.sol";
import "./erc20interface.sol";
import "./contractReceiver.sol";


contract Proposal is ContractReceiver {
    using SafeMath for uint256;

    event TokenFallback(address _sender,
                       uint256 _value,
                       bytes _extraData);

    address public mainContract;
    /**
    * @dev Throws if called by any account other than the main contract.
    */
    modifier onlyMainContract() {
        require(msg.sender == mainContract);
        _;
    }

    Vote[] public votes;
    uint256 public goal;
    uint256 public progress;
    string public description;

    address public token;
    uint public periodInMinutes;
    uint public votingDeadline;

    // Proposal current status
    enum Status { Voting, Success, Failed }
    Status public status = Status.Voting;

    // Proposal document url
    string public documentUrl;
    string public documentHash;

    // Proposal delivery document url
    string public deliveryDocUrl;
    string public deliveryDocHash;

    // Proposal delivery status
    enum DeliveryStatus { Waiting, Sent, Failed }
    DeliveryStatus public deliveryStatus = DeliveryStatus.Waiting;

    struct Vote {
        address voter;
        uint256 amount;
    }

    /**
     * Add Proposal
     *
     * Propose to send KATIN Token for voting
     *
     * @param _token address of KATIN Coin
     * @param _goal Amount of KATIN Coin goal
     * @param _description Description of proposal
     * @param _periodInMinutes Goal deadline in minutes
     * @param _documentUrl Document url
     * @param _documentHash Document hash
     */
    function Proposal(
        address _mainContract,
        address _token,
        uint256 _goal,
        string _description,
        uint _periodInMinutes,
        string _documentUrl,
        string _documentHash
    )
        public
    {
        mainContract = _mainContract;
        token = _token;
        goal = _goal;
        description = _description;
        periodInMinutes = _periodInMinutes;
        votingDeadline = now + _periodInMinutes * 1 minutes;
        documentUrl = _documentUrl;
        documentHash = _documentHash;
    }

    // Need action: check to only accept KATIN Token
    function tokenFallback(address _sender,
                       uint256 _value,
                       bytes _extraData) public returns (bool) {
        require(status == Status.Voting);
        require(token == msg.sender);
        require(now <= votingDeadline);
        require(goal >= progress.add(_value));

        uint voteID = votes.length++;
        votes[voteID] = Vote({voter: _sender, amount: _value});

        progress = progress.add(_value);

        if (goal == progress) {
            status = Status.Success;
        }

        TokenFallback(_sender, _value, _extraData);
    }

    function verify() public {
        require(status == Status.Voting);

        // Passed deadline
        if (now > votingDeadline) {
            if(progress < goal) {
                status = Status.Failed;
                returnTokens();
            } else {
                status = Status.Success;
            }
        }
    }

    // Return all tokens to participants
    function returnTokens() private {
        ERC20 katinCoin = ERC20(token);
        for (uint i = 0; i <  votes.length; ++i) {
            Vote storage v = votes[i];
            
            
            katinCoin.transfer( v.voter, v.amount);
        }
    }

    function voteBy(address _voter) public view returns (uint256) {
        uint256 amount = 0;
        for (uint i = 0; i <  votes.length; ++i) {
            // Todo: may change to memory
            Vote memory v = votes[i];
            if (v.voter == _voter) {
                amount = amount.add(v.amount);
            }
        }
        return amount;
    }

    /**
     * Update delivery state
     *
     * Main contract update delivery state when sent or failed
     *
     * @param _documentUrl document url for delivery confirmation
     * @param _documentHash document hash with sha3
     * @param _status delivery status
     */
    function updateDelivery(string _documentUrl, string _documentHash, DeliveryStatus _status) public onlyMainContract returns (bool) {
        deliveryDocUrl = _documentUrl;
        deliveryDocHash = _documentHash;
        deliveryStatus = _status;

        return true;
    }

    function voteCount() public view returns (uint256) {
        return votes.length;
    }
}
