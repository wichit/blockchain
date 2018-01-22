pragma solidity ^0.4.0;

contract adder {
    
    string name;
    
    function setName(string _name) public {
        name = _name;
    }
    
    function getName() constant returns (string) {
        return name;
    }
    
    function add(int a, int b) constant returns (int) {
        return a+b;
    }
    
    function addAndRename(int a, int b, string _name) returns (int) {
        name = _name;
        return a+b;
    }
}