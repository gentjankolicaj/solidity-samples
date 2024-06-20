//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.5;


import './IContract.sol'; //To have visibility on structs present at IContract.sol file.


contract MainContract {

    address _admin;
    address _implementation;

    constructor(){
        _admin = msg.sender;
    }


    function admin() public view returns (address){
        return _admin;
    }

    function impl() public view returns (address){
        return _implementation;
    }

    function updateImpl(address newImpl) public returns (bool){
        require(admin() == msg.sender, "Admin: Only admin can update impl.");
        require(newImpl != address(0), "Address: address 0 not allowed");
        _implementation = newImpl;

        return true;
    }

    //Functions called on different implementation of contracts
    function readFunction() public view returns (RData memory){
        IContract icontract = IContract(_implementation);
        return icontract.read();
    }


    function writeFunction(WData memory wdata) public returns (bool){
        IContract(_implementation).write(wdata);
        return true;
    }


    function executeFunction() public returns (bytes32[] memory){
        IContract icontract = IContract(_implementation);
        return icontract.execute();
    }


}
