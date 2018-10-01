pragma solidity ^0.4.24;

/**
 * ERC223 token by Dexaran
 *
 * https://github.com/Dexaran/ERC223-token-standard
 */
 
contract ContractReceiver {
    function tokenFallback(
        address _sender,
        uint256 _value,
        bytes _extraData) public returns (bool);
}
