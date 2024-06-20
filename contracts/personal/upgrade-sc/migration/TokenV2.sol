//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.5;

import '@openzeppelin/contracts/token/ERC20/ERC20.sol';

contract TokenV2 is ERC20 {
    constructor() ERC20('Token V2', 'TV2') {
        _mint(msg.sender, 1000000);
    }

    function burn(uint amount) external {
        _burn(msg.sender, amount);
    }
}