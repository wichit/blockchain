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
 * ERC223 token by Dexaran
 *
 * https://github.com/Dexaran/ERC223-token-standard
 */


contract ERC20 {
    function totalSupply()  public constant returns (uint256 supply);
    function balanceOf( address who )  public constant returns (uint256 value);
    function allowance( address owner, address spender )  public constant returns (uint256 _allowance);

    function transfer( address to, uint256 value)  public returns (bool ok);
    function transferFrom( address from, address to, uint256 value)  public returns (bool ok);
    function approve( address spender, uint256 value )  public returns (bool ok);

    event Transfer( address indexed from, address indexed to, uint256 value);
    event Approval( address indexed owner, address indexed spender, uint256 value);
}
 
 contract ContractReceiver {
     function tokenFallback(address _sender,
                       uint256 _value,
                       bytes _extraData) public returns (bool);
 }
 

contract Proposal is ContractReceiver {
    using SafeMath for uint256;

    event TokenFallback(address _sender,
                       uint256 _value,
                       bytes _extraData);

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
        address _token,
        uint256 _goal,
        string _description,
        uint _periodInMinutes,
        string _documentUrl,
        string _documentHash
    )
        public
    {
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
            Vote storage v = votes[i];
            if (v.voter == _voter) {
                amount = amount.add(v.amount);
            }
        }
        return amount;
    }
}
