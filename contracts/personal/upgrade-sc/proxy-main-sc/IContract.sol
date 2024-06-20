//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.5;

//Struct declared outside interface in order to have them visible wherever I import IContract.sol file.
    struct RData {
        address addr;
        bytes32 fx;
        uint256 arg;

    }

    struct WData {
        address addr;
        bytes32 fx;
        uint256 arg;
    }


interface IContract {


    function read() external view returns (RData memory);

    function write(WData memory wdata) external returns (bool);

    function execute() external returns (bytes32[] memory);

}