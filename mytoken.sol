pragma solidity 0.4.11;

contract owned {
    address public owner;
    
    function owned() {
        owner = msg.sender;
    }
    
    modifier onlyOwner {
        if (msg.sender != owner) throw;
        _;
    }
    
    function transferOwnership(address newOwner) onlyOwner {
        owner = newOwner;
    }
}

contract MyToken is owned{
    
    uint256 public totalSupply;
    string public name;
    string public symbol;
    uint8 public decimals;
    
    uint256 public sellPrice;
    uint256 public buyPrice;
    uint minBalanceForAccounts;
    
    mapping (address => uint256) public balanceOf;
    mapping (address => bool) public frozenAccount;
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event FrozenFunds(address target, bool frozen);
    
    function MyToken(uint256 initialSupply, 
                    string tokenName, 
                    uint8 decimalUnits, 
                    string tokenSymbol,
                    address centralMinter) {
                    if (centralMinter != 0) owner = centralMinter;
        totalSupply = initialSupply;
        name = tokenName;
        symbol = tokenSymbol;
        decimals = decimalUnits;
    }
    
    function setPrices(uint256 newSellPrice, uint256 newBuyPrice) onlyOwner {
        sellPrice = newSellPrice;
        buyPrice = newBuyPrice;
    }
    
    function setMinBalance (uint minimumBalanceInFinney) onlyOwner {
        minBalanceForAccounts = minimumBalanceInFinney * 1 finney;
    }
    
    function transfer(address _to, uint256 _value) {
        if (frozenAccount[msg.sender]) throw;
        
        /* Check if sender has balance and for overflows */
        if (balanceOf[msg.sender] < _value || balanceOf[_to] + _value < balanceOf[_to])
            throw;
        
        /* add and substract */
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        
        /* Notify anyonelistening that this transfer took place */
        Transfer(msg.sender, _to, _value);
    }
    
    function mintToken(address target, uint256 mintedAmount) onlyOwner {
        balanceOf[target] += mintedAmount;
        totalSupply += mintedAmount;
        Transfer(0, owner, mintedAmount);
        Transfer(owner, target, mintedAmount);
    }
    
    function freezeAccount(address target, bool freeze) onlyOwner {
        frozenAccount[target] = freeze;
        FrozenFunds(target, freeze);
    }
}
