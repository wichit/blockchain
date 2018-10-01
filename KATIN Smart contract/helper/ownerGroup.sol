pragma solidity ^0.4.24;
import "./signature.sol";

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract OwnerGroup is Verifier {

    /// Group of owners that can gorvoment contract
    address[] public owners;

    /// Over half of owners need to vote on topic within this period
    uint votePeriod; // 24 hours

    /**
    * @dev The Ownable constructor sets the initial `owners` of the contract from providing.
    * list of owner addresses.
    */
    constructor(address[] _owners, uint _votePeriod) public {
        require(_owners.length >= 1);

        owners = _owners;
        votePeriod = _votePeriod;
    }


    /**
    * @dev Throws if called by any account other than the owner.
    */
    modifier onlyOwners() {
        require(msg.sender == owner);
        _;
    }

    /**
    * @dev Throws if called by any account other than the owner.
    */
    // modifier onlyOwners(string _topic, string _blockBegin, string[] _signatures) {
    modifier onlyOwners(
        string _topic, 
        address _destAddr, 
        uint _expiredTime, 
        address[] _addrs, 
        bytes[] sig
    ) {
        // Require over half of owners for successful voting

        // exp: "change mintOnwer to 0xabcd... expired "
        bytes32 msgHash = keccak256(_topic, " to ", _destAddr, " expired ", _expiredTime);

        verifySigned(msg.sender, msgHash, sig[0]);

        require(_signatures.length > owners.length / 2); // We have not much owners here so no need to use safemath


        require(msg.sender == owner);
        _;
    }

    // which visibility should be on this function ?
    function onlyOwners2 view (
        string _topic, 
        string _destAddr, 
        string _expiredTime, 
        string stringLength, 
        address _addrs, 
        bytes sig
    ) returns (string) {
        // Require over half of owners for successful voting

        // exp: "change mintOnwer to 0xabcd... expired "
        bytes32 msgHash = keccak256("\x19Ethereum Signed Message:\n", stringLength, _topic, _destAddr, "expired", _expiredTime);

        require(verifySigned(_addrs, msgHash, sig));
        
        return "totiz";
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
