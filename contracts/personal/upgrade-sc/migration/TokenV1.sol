//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.5;

import '@openzeppelin/contracts/token/ERC20/ERC20.sol';

contract TokenV1 is ERC20 {
    constructor() ERC20('Token V1', 'TV1') {
        _mint(msg.sender, 1000000);
    }
}