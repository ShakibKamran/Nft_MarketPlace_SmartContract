# NFT Marketplace Smart Contract

## Overview
The **NFTMarketplace** smart contract is an Ethereum-based platform that allows users to list, buy, and auction NFTs securely. It facilitates seamless NFT transactions with fixed-price sales and auction-based bidding mechanisms.

## Features
### 1. **Listing NFTs for Sale**
- Owners can list their NFTs for a fixed price.
- Buyers can purchase NFTs by sending the exact price.
- Sellers can remove their listings before a sale is completed.

### 2. **Auctioning NFTs**
- Sellers can create auctions with a starting price and a duration.
- Bidders can place bids, with only the highest bid being recorded.
- The highest bidder wins the NFT when the auction ends.
- Sellers receive the highest bid amount.

### 3. **Bidding System**
- Users can bid on active auctions.
- Previous highest bidders receive refunds automatically.

### 4. **Secure Funds Handling**
- Balances are managed securely within the contract.
- Sellers can withdraw earnings at any time.

## Contract Functionalities
### **1. Listing an NFT**
```solidity
function listNFT(address nftContract, uint256 tokenId, uint256 price) external;
```
- Transfers NFT ownership to the marketplace contract for listing.

### **2. Buying an NFT**
```solidity
function buyNFT(uint256 listingId) external payable;
```
- Transfers NFT ownership to the buyer.
- Sends funds to the seller’s balance.

### **3. Delisting an NFT**
```solidity
function delistNFT(uint256 listingId) external;
```
- Allows sellers to remove their active listing.

### **4. Creating an Auction**
```solidity
function createAuction(address nftContract, uint256 tokenId, uint256 startPrice, uint256 duration) external;
```
- Starts an auction with a minimum bid and a duration.

### **5. Placing a Bid**
```solidity
function placeBid(uint256 auctionId) external payable;
```
- Users can place a bid higher than the current highest bid.
- The previous highest bidder receives a refund.

### **6. Ending an Auction**
```solidity
function endAuction(uint256 auctionId) external;
```
- Transfers the NFT to the highest bidder.
- Sends the highest bid amount to the seller.

### **7. Withdrawing Funds**
```solidity
function withdrawFunds() external;
```
- Allows users to withdraw their available balance securely.

## Events
- `NFTListed` - Triggered when an NFT is listed for sale.
- `NFTSold` - Triggered when an NFT is purchased.
- `AuctionCreated` - Triggered when an auction is initiated.
- `NewBidPlaced` - Triggered when a new bid is made.
- `AuctionEnded` - Triggered when an auction successfully ends.
- `NFTDelisted` - Triggered when a seller removes their listing.

## Deployment
- The contract should be deployed on an Ethereum-compatible blockchain.
- The contract owner has administrative privileges.

## Security Considerations
- The contract is protected against **reentrancy attacks** using **ReentrancyGuard**.
- User funds are managed using **safe balance storage**.
- **Ownable** ensures restricted access to administrative functions.

## License
This project is licensed under the **MIT License**.

