// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// Importing OpenZeppelin smart contract modules for enhanced functionality and security
// ERC721: Non-Fungible Token Standard implementation
// IERC20: Interface for ERC20 token standard
// ReentrancyGuard: Protection against reentrancy attacks
// ERC721Burnable: Extension allowing token burning
// ERC721URIStorage: Extension for storing token URIs
// SafeERC20: Wrapper around ERC20 operations to prevent unexpected behavior
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/**
 * @title ERC721N
 * @dev An innovative abstract contract extending ERC721 functionality
 *      This contract introduces several key features:
 *      1. Burnable tokens: Allows token destruction
 *      2. Reentrancy protection: Guards against malicious contract interactions
 *      3. ERC20 token interaction: Enables association of ERC20 balances with ERC721 tokens
 *      4. Minting mechanism: Creates ERC721 tokens with embedded ERC20 balances
 *      5. Redemption feature: Allows burning of ERC721 tokens to claim associated ERC20 balances
 *
 *      The contract serves as a bridge between ERC721 and ERC20 tokens, enabling
 *      new use cases and economic models in the realm of NFTs and fungible tokens.
 */
abstract contract ERC721N is ERC721, ERC721Burnable, ReentrancyGuard {
    // Tracks the ID for the next token to be minted, ensuring unique token IDs
    uint256 private _nextTokenId;
    // Stores the base URI for token metadata, enhancing token information accessibility
    string private _baseTokenURI;
    // Maintains the address of the contract owner, crucial for administrative functions
    address private _owner;

    // Enables safe interactions with ERC20 tokens, preventing common pitfalls
    using SafeERC20 for IERC20;

    // Associates each token ID with its corresponding ERC20 token balance
    // This mapping is key to the contract's core functionality
    mapping(uint256 => uint256) public tokenERC20Balances;

    // Tracks all NFTs owned by each user address, enabling efficient token management
    mapping(address => uint256[]) public userNFTs;

    // Stores the address of the ERC20 token contract this ERC721N interacts with
    IERC20 public reserveTokenAddress;
    // Keeps track of the total ERC20 balance associated with all minted NFTs
    // Critical for maintaining the contract's economic balance
    uint256 public unclaimedReserveBalance;

    /////////////////////////////////////////////
    /////// EVENTS
    /////////////////////////////////////////////
    // Triggered when an NFT owner redeems the associated ERC20 balance
    // Provides transparency and allows for off-chain tracking of redemptions
    event RedeemReserves(
        address indexed _from,
        uint256 indexed _amount,
        uint256 indexed _tokenId
    );
    // Fired when a new ERC721N token is created
    // Useful for monitoring minting activity and associated ERC20 allocations
    event ERC721NMinted(
        address indexed _to,
        uint256 indexed _tokenId,
        uint256 indexed _amount
    );

    /////////////////////////////////////////////
    /////// ERRORS
    /////////////////////////////////////////////
    // Custom error for unauthorized access attempts, enhancing security
    error Unauthorized(address caller);
    // Ensures valid input for token amounts, preventing zero-value transactions
    error AmountMustBeGreaterThan0(uint256 amount);
    // Protects against minting more tokens than the contract can back with ERC20 reserves
    error InsufficientReserveBalance(
        uint256 amount,
        uint256 reserveBalance,
        uint256 unclaimedReserveBalance
    );
    // Prevents attempts to redeem from tokens with no associated ERC20 balance
    error NoERC20BalanceToRedeem(uint256 tokenId);
    // Ensures only legitimate token owners can perform certain actions
    error NotOwnerOfToken(address caller, uint256 tokenId);

    /**
     * @dev Initializes the ERC721N contract with essential parameters
     * @param erc20Token_ Address of the ERC20 token contract to be used as a reserve
     * @param name_ Name of the ERC721 token collection
     * @param symbol_ Symbol of the ERC721 token collection
     *
     * This constructor sets up the fundamental structure of the ERC721N contract,
     * linking it with a specific ERC20 token and establishing the NFT collection's identity.
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
     * @dev Mints a new ERC721N token with an associated ERC20 balance
     * @param _to Address that will receive the newly minted token
     * @param _quantity Amount of ERC20 tokens to be associated with the new NFT
     *
     * This function performs several critical operations:
     * 1. Verifies the caller is the contract owner
     * 2. Ensures a non-zero ERC20 quantity
     * 3. Checks if sufficient ERC20 balance is available in the contract
     * 4. Mints a new NFT and associates it with the specified ERC20 balance
     * 5. Updates relevant state variables and emits an event
     *
     * The function is protected against reentrancy attacks and unauthorized access.
     */
    function safeMint(address _to, uint256 _quantity) internal nonReentrant {
        // Restrict minting capability to the contract owner for controlled token issuance
        if (msg.sender != _owner) {
            revert Unauthorized(msg.sender);
        }
        // Prevent minting of tokens with zero ERC20 balance, ensuring economic viability
        if (_quantity <= 0) {
            revert AmountMustBeGreaterThan0(_quantity);
        }
        // Verify that the contract has sufficient ERC20 tokens to back the new NFT
        uint reserveBalance = reserveTokenAddress.balanceOf(address(this));
        if (reserveBalance < unclaimedReserveBalance + _quantity) {
            revert InsufficientReserveBalance(
                _quantity,
                reserveBalance,
                unclaimedReserveBalance
            );
        }
        // Generate a unique token ID and update the next available ID
        uint256 tokenId = _nextTokenId++;
        // Increase the total unclaimed ERC20 balance to account for the new token
        unclaimedReserveBalance += _quantity;
        // Associate the ERC20 balance with the newly minted NFT
        tokenERC20Balances[tokenId] = _quantity;
        // Add the new token to the recipient's list of owned NFTs
        userNFTs[_to].push(tokenId);
        // Safely mint the new NFT to the specified address
        _safeMint(_to, tokenId);
        // Emit an event to log the minting of the new ERC721N token
        emit ERC721NMinted(_to, tokenId, _quantity);
    }

    /**
     * @dev Allows the contract owner to claim excess ERC20 tokens
     *
     * This function serves as a safeguard to retrieve any ERC20 tokens sent to the contract
     * that exceed the total balance associated with minted NFTs. It helps maintain
     * the economic balance of the contract and prevents unintended token lockup.
     */
    function claimExcessiveToken() external {
        require(msg.sender == _owner, "Only the contract owner can claim excess funds");
        uint256 balance = reserveTokenAddress.balanceOf(address(this));
        if (balance > unclaimedReserveBalance) {
            reserveTokenAddress.safeTransfer(
                msg.sender,
                balance - unclaimedReserveBalance
            );
        }
    }

    /**
     * @dev Allows the owner of an NFT to burn it and redeem the associated ERC20 balance
     * @param tokenId The unique identifier of the NFT to be burned and redeemed
     *
     * This function is a core feature of the ERC721N contract, enabling users to
     * exchange their NFTs for the associated ERC20 tokens. It includes several checks:
     * 1. Verifies the token has an associated ERC20 balance
     * 2. Ensures the caller is authorized to burn the token
     * 3. Burns the NFT and updates relevant state variables
     * 4. Transfers the associated ERC20 tokens to the caller
     *
     * The function is protected against reentrancy attacks for enhanced security.
     */
    function redeemReserves(uint256 tokenId) external nonReentrant {
        uint256 amount = tokenERC20Balances[tokenId];

        // Prevent redemption attempts for tokens with no associated ERC20 balance
        if (amount == 0) {
            revert NoERC20BalanceToRedeem(tokenId);
        }

        // Verify that the caller is authorized to burn and redeem the token
        address owner = ownerOf(tokenId);
        if (
            msg.sender != owner &&
            !isApprovedForAll(owner, msg.sender) &&
            _getApproved(tokenId) != msg.sender
        ) {
            revert NotOwnerOfToken(msg.sender, tokenId);
        }
        _burn(tokenId); // Permanently destroy the NFT
        tokenERC20Balances[tokenId] = 0; // Clear the ERC20 balance associated with the burned token
        unclaimedReserveBalance -= amount; // Update the total unclaimed ERC20 balance

        // Transfer the associated ERC20 tokens to the caller using a safe transfer method
        reserveTokenAddress.safeTransfer(msg.sender, amount);

        // Emit an event to log the redemption of ERC20 tokens
        emit RedeemReserves(msg.sender, amount, tokenId);
    }
}
