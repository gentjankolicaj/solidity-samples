pragma solidity ^0.8.5;

contract ContractV1 {
    uint public storage1;

    function updateStorage1(uint _storage) public {
        storage1 = _storage;
    }


}
