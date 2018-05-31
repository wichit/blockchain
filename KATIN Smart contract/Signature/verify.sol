pragma solidity ^0.4.24;
contract Verifier {
    bool public success;
    
    function splitSignature(bytes sig)
    public
    pure
    returns (uint8, bytes32, bytes32)
    {
        require(sig.length == 65);
    
        bytes32 r;
        bytes32 s;
        uint8 v;
    
        assembly {
            // first 32 bytes, after the length prefix
            r := mload(add(sig, 32))
            // second 32 bytes
            s := mload(add(sig, 64))
            // final byte (first byte of the next 32 bytes)
            v := byte(0, mload(add(sig, 96)))
        }
    
        return (v, r, s);
    }
    
    function recoverAddr(bytes32 msgHash, uint8 v, bytes32 r, bytes32 s) returns (address) {
        return ecrecover(msgHash, v, r, s);
    }
    
    // Builds a prefixed hash to mimic the behavior of eth_sign.
    function prefixed() public pure returns (bytes32) {
        return keccak256("\x19Ethereum Signed Message:\n3msg");
    }
    
    
    
    function recoverSigner(bytes32 message, bytes sig)
        public
        pure
        returns (address)
    {
        uint8 v;
        bytes32 r;
        bytes32 s;
    
        (v, r, s) = splitSignature(sig);
    
        return ecrecover(message, v, r, s);
    }
    
    function recoverSignedPrefixed(bytes sig) public returns (address) {
    
        // This recreates the message that was signed on the client.
        bytes32 message = prefixed();
    
        return recoverSigner(message, sig);
    }
    
    function isSigned(address _addr, bytes32 msgHash, uint8 v, bytes32 r, bytes32 s) returns (bool) {
        success = ecrecover(msgHash, v, r, s) == _addr; 
        return success;
    }
    
    function validate(uint8 v,bytes32 r,bytes32 s)  view public returns (address){

        //bytes memory prefix = "\x19Ethereum Signed Message:\n32";

         bytes32 prefixedHash = keccak256("I really did make this message");

        address endecodedAddress = ecrecover(prefixedHash, v, r, s);

        return endecodedAddress;

  }
}
