// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./ERC721N.sol";

// This contract demonstrates how ERC721N can be used for NFT Treasury Management
contract ERC721NTest is ERC721N {
    // Constructor initializes the ERC721N contract with a specified ERC20 token
    // This ERC20 token will be used as the reserve currency for the NFT collection
    constructor(
        IERC20 erc20Token_
    ) ERC721N(erc20Token_, "NoRamp721N", "NR721N") {
        reserveTokenAddress = erc20Token_;
    }

    // Simple mint function to demonstrate how new NFTs can be created
    // In a real treasury management app, this might involve more complex logic
    // such as calculating fees, updating reserve balances, etc.
    function mint(address to, uint256 amount) external {
        safeMint(to, amount);
    }

    // Additional treasury management functions could be added here
    // For example:
    // - Functions to adjust reserve ratios
    // - Functions to withdraw or deposit reserve tokens
    // - Functions to calculate and distribute yields
}
