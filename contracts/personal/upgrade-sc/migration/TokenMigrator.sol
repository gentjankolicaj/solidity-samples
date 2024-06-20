//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.5;


import '@openzeppelin/contracts/token/ERC20/IERC20.sol';

contract TokenMigrator {

    mapping(address => bool) public migrations;
    IERC20 public token1;
    IERC20 public token2;


    constructor(address t1, address t2){
        token1 = IERC20(t1);
        token2 = IERC20(t2);
    }


    function migrate() public returns (bool){
        address owner = msg.sender;
        require(migrations[owner] == false, 'Migration: already done');

        uint256 tokenAmount = token1.balanceOf(owner);

        //transfer new tokens to token owner
        token2.transfer(owner, tokenAmount);

        //burn old tokens
        token1.transferFrom(owner, address(1), tokenAmount);

        return true;
    }
}