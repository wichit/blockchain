pragma solidity ^0.4.24;

import "./safemath.sol";
import "./ownable.sol";
import "./contractReceiver.sol";

// TODO: Follow https://github.com/Dexaran/ERC223-token-standard/tree/master/token/ERC223

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20Basic {
//   uint256 public totalSupply;
//   function balanceOf(address who) constant public returns (uint256);
//   function transfer(address to, uint256 value) public returns (bool success);
    event Transfer(address indexed _from, address indexed _to, uint256 indexed _value, bytes _data);

}


/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
    //using SafeMath for uint256;

    mapping(address => uint256) balances;

    /**
    * @dev Fix for the ERC20 short address attack.
    */
    modifier onlyPayloadSize(uint256 size) {
        require(msg.data.length >= size + 4);
        _;
    }

    // validates an address - currently only checks that it isn't null
    modifier validAddress(address _address) {
        require(_address != 0x0);
        _;
    }

    /**
    * @dev transfer token for a specified address
    * @param _to The address to transfer to.
    * @param _value The amount to be transferred.
    */
    //   function transfer(address _to, uint256 _value) public onlyPayloadSize(2 * 32) returns (bool success) {
    //     balances[msg.sender] = balances[msg.sender].sub(_value);
    //     balances[_to] = balances[_to].add(_value);
    //     Transfer(msg.sender, _to, _value);
    //   }

    /**
    * @dev Gets the balance of the specified address.
    * @param _owner The address to query the the balance of.
    * @return An uint representing the amount owned by the passed address.
    */
    //   function balanceOf(address who) constant public returns (uint256 balance) {
    //     return balances[who];
    //   }

}


/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
//   function allowance(address owner, address spender) public constant returns (uint256);
    function transferFrom(address from, address to, uint256 value) public returns (bool success);
    function approve(address spender, uint256 value) public returns (bool success);
  
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}


/**
 * @title Standard ERC20 token
 *
 * @dev Implemantation of the basic standart token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is BasicToken, ERC20 {
    using SafeMath for uint256;

    mapping (address => mapping (address => uint256)) public allowance;

    /**
        @dev an account/contract attempts to get the coins
        throws on any error rather then return a false flag to minimize user errors

        @param _from    source address
        @param _to      target address
        @param _value   transfer amount

        @return true if the transfer was successful, false if it wasn't
    */
    function transferFrom(address _from, address _to, uint256 _value)
        public
        onlyPayloadSize(3 * 32)
        validAddress(_from)
        validAddress(_to)
        returns (bool success)
    {
        allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_value);
        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        bytes memory empty;
        emit Transfer(_from, _to, _value, empty);
        return true;
    }
  
    /**
        @dev allow another account/contract to spend some tokens on your behalf
        throws on any error rather then return a false flag to minimize user errors

        also, to minimize the risk of the approve/transferFrom attack vector
        (see https://docs.google.com/document/d/1YLPtQxZu1UAvO9cZ1O2RPXBbT0mooh4DYKjA_jp-RLM/), approve has to be called twice
        in 2 separate transactions - once to change the allowance to 0 and secondly to change it to the new allowance value

        @param _spender approved address
        @param _value   allowance amount

        @return true if the approval was successful, false if it wasn't
    */
    function approve(address _spender, uint256 _value)
        public
        validAddress(_spender)
        returns (bool success)
    {
        // if the allowance isn't 0, it can only be updated to 0 to prevent an allowance change immediately after withdrawal
        require(_value == 0 || allowance[msg.sender][_spender] == 0);

        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
}

contract MintableToken is StandardToken, Ownable {
    event Mint(address indexed to, uint256 value);
    event MintFinished();

    bool public mintingFinished = false;
    uint256 public totalSupply = 0;


    modifier canMint() {
        require(!mintingFinished);
        _;
    }

    /**
    * @dev Function to mint tokens
    * @param _to The address that will recieve the minted tokens.
    * @param _amount The amount of tokens to mint.
    * @return A boolean that indicates if the operation was successful.
    */
    function mint(address _to, uint256 _amount) public onlyOwner canMint returns (bool) {
        totalSupply = totalSupply.add(_amount);
        balances[_to] = balances[_to].add(_amount);
        emit Mint(_to, _amount);
        return true;
    }

    /**
    * @dev Function to stop minting new tokens.
    * @return True if the operation was successful.
    */
    function finishMinting() public onlyOwner returns (bool) {
        mintingFinished = true;
        emit MintFinished();
        return true;
    }
}

contract KmMintableToken is MintableToken {
    using SafeMath for uint256;
    uint256 kmrate = 10 ** 18;
    /**
    * @dev Function to mint tokens
    * @param _to The address that will recieve the minted tokens.
    * @param _km The amount of kilometers to mint.
    * @return A boolean that indicates if the operation was successful.
    */
    function mintKm(address _to, uint256 _km) public onlyOwner canMint returns (bool) {
        uint256 _amount = _km.mul(kmrate);
        return mint(_to, _amount);
    } 
}

 
contract ERC223Token is KmMintableToken {
    using SafeMath for uint256;

    //mapping(address => uint256) balances;
  
    string public name;
    string public symbol;
    uint8 public decimals;
    

    constructor (string _name, string _symbol, uint8 _decimals) public {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
    }
    
    //   // Function to access name of token .
    //   function name() public view returns (string _name) {
    //       return name;
    //   }
    //   // Function to access symbol of token .
    //   function symbol() public view returns (string _symbol) {
    //       return symbol;
    //   }
    //   // Function to access decimals of token .
    //   function decimals() public view returns (uint8 _decimals) {
    //       return decimals;
    //   }
    //   // Function to access total supply of tokens .
    //   function totalSupply() public view returns (uint256 _totalSupply) {
    //       return totalSupply;
    //   }
  
  
    // Function that is called when a user or another contract wants to transfer funds .
    function transfer(address _to, uint256 _value, bytes _data, string _custom_fallback) 
        private 
        // onlyPayloadSize(3 * 32)
        returns (bool success) {
      
        if(isContract(_to)) {
            balances[msg.sender] = balanceOf(msg.sender).sub(_value);
            balances[_to] = balanceOf(_to).add(_value);
            assert(_to.call.value(0)(bytes4(keccak256(_custom_fallback)), msg.sender, _value, _data));
            emit Transfer(msg.sender, _to, _value, _data);
            return true;
        }
        else {
            return transferToAddress(_to, _value, _data);
        }
    }
  

    // Function that is called when a user or another contract wants to transfer funds .
    function transfer(address _to, uint256 _value, bytes _data) 
        private
        // onlyPayloadSize(3 * 32)
        returns (bool success) {
        
        if(isContract(_to)) {
            return transferToContract(_to, _value, _data);
        }
        else {
            return transferToAddress(_to, _value, _data);
        }
    }
  
    // Standard function transfer similar to ERC20 transfer with no _data .
    // Added due to backwards compatibility reasons .
    function transfer(address _to, uint256 _value) 
        public
        // onlyPayloadSize(3 * 32)
        returns (bool success) {
        
        //standard function transfer similar to ERC20 transfer with no _data
        //added due to backwards compatibility reasons
        bytes memory empty;
        if(isContract(_to)) {
            return transferToContract(_to, _value, empty);
        }
        else {
            return transferToAddress(_to, _value, empty);
        }
    }

    //assemble the given address bytecode. If bytecode exists then the _addr is a contract.
    function isContract(address _addr) private view returns (bool is_contract) {
        uint256 length;
        assembly {
                //retrieve the size of the code on target address, this needs assembly
                length := extcodesize(_addr)
        }
        return (length>0);
    }

    //function that is called when transaction target is an address
    function transferToAddress(address _to, uint256 _value, bytes _data) private returns (bool success) {
        balances[msg.sender] = balanceOf(msg.sender).sub(_value);
        balances[_to] = balanceOf(_to).add(_value);
        emit Transfer(msg.sender, _to, _value, _data);
        return true;
    }
    
    //function that is called when transaction target is a contract
    function transferToContract(address _to, uint256 _value, bytes _data) private returns (bool success) {
        balances[msg.sender] = balanceOf(msg.sender).sub(_value);
        balances[_to] = balanceOf(_to).add(_value);
        ContractReceiver receiver = ContractReceiver(_to);
        receiver.tokenFallback(msg.sender, _value, _data);
        emit Transfer(msg.sender, _to, _value, _data);
        return true;
    }


    function balanceOf(address who) public view returns (uint256 balance) {
        return balances[who];
    }
}
