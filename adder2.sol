pragma solidity ^0.4.0;
contract adder {
    
    int total;
    
    function adder() public {
        total = 0;
    }
    
    function getTotal() constant returns (int) {
        return total;
    }
    
    function addToTotal(int add) returns (int) {
        total = total + add;
        return total;
    }
}