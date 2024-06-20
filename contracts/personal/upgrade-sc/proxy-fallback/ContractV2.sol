pragma solidity ^0.8.5;

contract ContractV2 {
    uint public storage1;
    uint public storage2;

    function updateStorage1(uint _storage) public {
        storage1 = _storage;
    }

    function updateStorage2(uint _storage) public {
        storage2 = _storage;
    }

}
