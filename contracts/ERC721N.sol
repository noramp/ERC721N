// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

abstract contract ERC721N is ERC721, ERC721Burnable, ReentrancyGuard {
    uint256 private _nextTokenId;
    string private _baseTokenURI;
    address private _owner;

    // Mapping from token ID to the ERC20 amount it holds
    mapping(uint256 => uint256) public tokenERC20Balances;

    // The ERC20 token this contract interacts with
    IERC20 public reserveTokenAddress;
    uint256 public unclaimedReserveBalance;

    // Events
    event DepositReserves(address indexed _from, uint256 indexed _amount);
    event RedeemReserves(
        address indexed _from,
        uint256 indexed _amount,
        uint256 indexed _tokenId
    );
    event ERC721NMinted(
        address indexed _to,
        uint256 indexed _tokenId,
        uint256 indexed _amount
    );

    constructor(IERC20 _erc20Token) ERC721("NoRamp721N", "NoRamp721N") {
        reserveTokenAddress = _erc20Token;
        _owner = msg.sender;
    }

    function getReserveTokenAddress() external view returns (address) {
        return address(reserveTokenAddress);
    }

    function _safeMint(
        address _to,
        uint256 _amount
    ) internal override nonReentrant {
        require(msg.sender == address(_owner), "Invalid caller");
        require(_amount > 0, "Amount must be greater than 0");
        require(_to != address(0), "Invalid address");
        require(
            reserveTokenAddress.balanceOf(address(this)) >=
                unclaimedReserveBalance + _amount,
            "Insufficient reserve balance"
        );
        uint256 tokenId = _nextTokenId++;
        unclaimedReserveBalance += _amount;
        tokenERC20Balances[tokenId] = _amount;
        _mint(_to, tokenId);
        emit ERC721NMinted(_to, tokenId, _amount);
    }

    // Modifier to check token allowance
    modifier checkAllowance(uint amount) {
        require(
            reserveTokenAddress.allowance(msg.sender, address(this)) >= amount,
            "Error"
        );
        _;
    }

    function depositReserves(
        uint256 _amount
    ) external checkAllowance(_amount) nonReentrant {
        require(
            reserveTokenAddress.transferFrom(
                msg.sender,
                address(this),
                _amount
            ),
            "Transfer failed"
        );
        emit DepositReserves(msg.sender, _amount);
    }

    function getReserveBalance() external view returns (uint) {
        return reserveTokenAddress.balanceOf(address(this));
    }

    // Burn the NFT to redeem the ERC20 balance it holds
    function redeemReserves(uint256 tokenId) external nonReentrant {
        uint256 amount = tokenERC20Balances[tokenId];
        require(amount > 0, "No ERC20 balance to redeem");
        require(
            msg.sender == ownerOf(tokenId),
            "Caller is not the owner of the NFT"
        );

        // Burn the NFT
        _burn(tokenId);

        // Reset the ERC20 balance for the token to prevent re-entrancy
        tokenERC20Balances[tokenId] = 0;

        // Transfer the ERC20 tokens to the caller
        require(
            reserveTokenAddress.transfer(msg.sender, amount),
            "ERC20 transfer failed"
        );
        emit RedeemReserves(msg.sender, amount, tokenId);
    }
}
