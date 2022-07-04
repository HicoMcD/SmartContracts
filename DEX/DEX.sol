// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DEX {
// Interface
    IERC20 public immutable token0;
    IERC20 public immutable token1;

// Variables
    uint public reserve0;
    uint public reserve1;

    uint totalSupply;
    mapping(address => uint) public balanceOf;

    // Events

    // Constructor to initiate contract
    constructor(address _token0, address _token1) {
        token0 = IERC20(_token0);
        token1 = IERX20(_token1);
    }

    

}