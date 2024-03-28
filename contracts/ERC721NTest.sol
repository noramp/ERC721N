// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./ERC721N.sol";

contract ERC721NTest is ERC721N {
    constructor(
        IERC20 erc20Token_
    ) ERC721N(erc20Token_, "NoRamp721N", "NR721N") {
        reserveTokenAddress = erc20Token_;
    }

    function mint(address to, uint256 amount) external {
        safeMint(to, amount);
    }
}
