// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./ERC721N.sol";

contract ERC721NTest is ERC721N {
    constructor(IERC20 _erc20Token) ERC721N(_erc20Token) {
        reserveTokenAddress = _erc20Token;
    }

    function mint(address to, uint256 amount) external {
        safeMint(to, amount);
    }
}
