# Tokenized FD NFT Smart Contract

## Overview

Tokenized FD is an Ethereum smart contract that converts fixed deposits (FDs) into tFD NFTs. Each NFT represents a deposit with details like principal, interest rate, duration, and redemption status, offering transparency, portability, and compatibility with NFT wallets.

The NFTs can be viewed, tracked, and redeemed through the smart contract. This project uses ERC721 standards with on-chain JSON metadata encoded in Base64 for each NFT.

## Features

### Admin Features

* **Create FD Products**: Admin can define FD packages with `interestRate`, `duration`, `minDepositAmt`, and `maxDepositAmt`.
* **Activate/Deactivate Products**: Admin can toggle the status of FD products.
* **View FD Pool**: Admin can view the total deposited tokens held in the smart contract.
* **View Customer Data**: Admin can inspect customer information and their NFT holdings.

### Customer Features

* **Purchase FD NFT**: Users can deposit ERC20 tokens to mint an NFT representing their FD.
* **View Purchase History**: Users can query all NFTs they have purchased.
* **Redeem FD**: Users can redeem their NFT at maturity or early, with interest applied (or penalized for early redemption).
* **NFT Metadata**: Each NFT includes details of the FD encoded in Base64 JSON, with fields such as principal, interest rate, start/end timestamps, and product name.

## Technical Details

* **Solidity Version**: `^0.8.13`
* **Token Standard**: ERC721 (`ERC721URIStorage`) for NFTs.
* **ERC20 Integration**: Uses any ERC20 token (`YangCoin`) as the deposit token.
* **NFT Metadata**: Base64-encoded JSON on-chain; includes `name`, `description`, and `attributes`.
* **Access Control**: `Ownable` is used to restrict admin-only functions.

## Deployment

1. **Use Remix IDE**: Create YangCoin.sol and FDToken.sol on Remix IDE and paste their respective codes.
2. **Deploy YangCoin**: Deploy the ERC20 token YangCoin.
3. **Deploy Contract**: Pass the YangCoin address to the constructor.


## Example Usage

```solidity
// Mint some YangCoins for the participants (e.g. TokenizedFD Contract, Customers)
_mint(customerAddress, 10000)

// Admin creates a product
createFDProduct("Gold FD", 400, 30, 1000, 10000);

// Customer purchases an FD tokens
purchaseFDProduct(0, 1000);

// View pool
viewPool()

// Customer views their FD tokens
myPurchasesHistory(customerAddress);

// Customer redeems FD tokens
redeemFDToken(tokenID);

// View customer's balance
despositToken.balanceOf(customerAddress)

// View pool
viewPool()
```

## Next Step
1. Frontend Development: Build a React-based interface for users to interact with the Tokenized FD smart contract. This includes wallet connection, browsing available FD products, minting FD NFTs, viewing owned NFTs, and redeeming matured FD tokens.
2. Smart Contract Interaction: Integrate ethers.js or web3.js to allow the frontend to fetch data from the deployed smart contract and send transactions.
3. NFT Metadata Display: Decode and display the on-chain NFT metadata (Base64 JSON) in the frontend, showing principal, interest rate, start/end time, and redemption status.
