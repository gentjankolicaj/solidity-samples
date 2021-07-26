//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.5;


import './IContract.sol';


contract ContractV1 is IContract {


    function read() public view override returns (RData memory rdata){
        rdata = RData(address(this), bytes32("ContractV1.Method"), 111);
    }


    function write(WData memory wdata) external override returns (bool){
        wdata.addr = address(msg.sender);

        return true;
    }

    function execute() external override returns (bytes32[] memory){
        //do something

        bytes32[] memory array = new bytes32[](1);
        return array;
    }
}