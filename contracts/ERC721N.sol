// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// Importing OpenZeppelin smart contract modules for ERC721, ERC20, and security features
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/**
 * @title ERC721N
 * @dev An abstract contract extending ERC721 to include burnable tokens,
 *      reentrancy protection, and interactions with an ERC20 token.
 *      It allows for minting ERC721 tokens that hold an ERC20 token balance,
 *      and for burning those tokens to redeem the associated ERC20 balance.
 */
abstract contract ERC721N is ERC721, ERC721Burnable, ReentrancyGuard {
    // Next token ID to be minted
    uint256 private _nextTokenId;
    // Base URI for token metadata
    string private _baseTokenURI;
    // Owner of the contract
    address private _owner;

    using SafeERC20 for IERC20;

    // Mapping from token ID to the ERC20 amount it holds
    mapping(uint256 => uint256) public tokenERC20Balances;

    // Each users can have multiple NFTs
    mapping(address => uint256[]) public userNFTs;

    // The ERC20 token this contract interacts with
    IERC20 public reserveTokenAddress;
    // Total unclaimed ERC20 balance within minted NFTs
    uint256 public unclaimedReserveBalance;

    /////////////////////////////////////////////
    /////// EVENTS
    /////////////////////////////////////////////
    // Emitted when reserves are redeemed
    event RedeemReserves(
        address indexed _from,
        uint256 indexed _amount,
        uint256 indexed _tokenId
    );
    // Emitted when a new ERC721N token is minted
    event ERC721NMinted(
        address indexed _to,
        uint256 indexed _tokenId,
        uint256 indexed _amount
    );

    /////////////////////////////////////////////
    /////// ERRORS
    /////////////////////////////////////////////
    error Unauthorized(address caller);
    error AmountMustBeGreaterThan0(uint256 amount);
    error InsufficientReserveBalance(
        uint256 amount,
        uint256 reserveBalance,
        uint256 unclaimedReserveBalance
    );
    error NoERC20BalanceToRedeem(uint256 tokenId);
    error NotOwnerOfToken(address caller, uint256 tokenId);

    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
     *      Also sets the ERC20 token address that this contract interacts with.
     * @param erc20Token_ The ERC20 token address.
     * @param name_ The name of the token collection.
     * @param symbol_ The symbol of the token collection.
     */
    constructor(
        IERC20 erc20Token_,
        string memory name_,
        string memory symbol_
    ) ERC721(name_, symbol_) {
        reserveTokenAddress = erc20Token_;
        _owner = msg.sender;
    }

    /**
     * @dev Safely mints a new ERC721N token with a specific ERC20 balance to a designated address.
     *      Can only be called by the owner of the contract.
     * @param _to The address that will own the minted token.
     * @param _quantity The amount of ERC20 tokens to be associated with the minted NFT.
     */
    function safeMint(address _to, uint256 _quantity) internal nonReentrant {
        // Only the owner of the contract can mint new tokens
        if (msg.sender != _owner) {
            revert Unauthorized(msg.sender);
        }
        // User must select a valid amount of ERC20 tokens to reserve
        if (_quantity <= 0) {
            revert AmountMustBeGreaterThan0(_quantity);
        }
        uint reserveBalance = reserveTokenAddress.balanceOf(address(this));
        if (reserveBalance < unclaimedReserveBalance + _quantity) {
            revert InsufficientReserveBalance(
                _quantity,
                reserveBalance,
                unclaimedReserveBalance
            );
        }
        uint256 tokenId = _nextTokenId++;
        unclaimedReserveBalance += _quantity;
        tokenERC20Balances[tokenId] = _quantity;
        userNFTs[_to].push(tokenId);
        _safeMint(_to, tokenId);
        emit ERC721NMinted(_to, tokenId, _quantity);
    }

    /**
     * @dev Allows the owner of the contract to redeem any excessive ERC20 tokens that were sent to the contract.
     */
    function claimExcessiveToken() external {
        require(msg.sender == _owner, "only owner can claim fund");
        uint256 balance = reserveTokenAddress.balanceOf(address(this));
        if (balance > unclaimedReserveBalance) {
            reserveTokenAddress.safeTransfer(
                msg.sender,
                balance - unclaimedReserveBalance
            );
        }
    }

    //        reserveTokenAddress.approve(address(this), amount);

    /**
     * @dev Allows the owner of a token to burn it and redeem the associated ERC20 balance.
     * @param tokenId The ID of the token to be burned.
     */
    function redeemReserves(uint256 tokenId) external nonReentrant {
        uint256 amount = tokenERC20Balances[tokenId];

        if (amount == 0) {
            revert NoERC20BalanceToRedeem(tokenId);
        }

        address owner = ownerOf(tokenId);
        if (
            msg.sender != owner &&
            !isApprovedForAll(owner, msg.sender) &&
            _getApproved(tokenId) != msg.sender
        ) {
            revert NotOwnerOfToken(msg.sender, tokenId);
        }
        _burn(tokenId); // Burn the NFT
        tokenERC20Balances[tokenId] = 0; // Reset the ERC20 balance for the token
        unclaimedReserveBalance -= amount;

        // Attempt to transfer the ERC20 tokens to the caller
        reserveTokenAddress.safeTransfer(msg.sender, amount);

        emit RedeemReserves(msg.sender, amount, tokenId);
    }
}
