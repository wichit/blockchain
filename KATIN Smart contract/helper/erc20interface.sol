pragma solidity ^0.4.24;


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