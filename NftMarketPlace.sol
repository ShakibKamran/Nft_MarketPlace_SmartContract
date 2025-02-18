// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "node_modules/@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "node_modules/@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "node_modules/@openzeppelin/contracts/access/Ownable.sol";

contract NFTMarketplace is ReentrancyGuard, Ownable {
    uint256 private _listingIds;
    uint256 private _auctionIds;

    struct Listing {
        address seller;
        address nftContract;
        uint256 tokenId;
        uint256 price;
        bool isActive;
    }

    struct Auction {
        address seller;
        address nftContract;
        uint256 tokenId;
        uint256 startPrice;
        uint256 highestBid;
        address highestBidder;
        uint256 endTime;
        bool isActive;
    }

    mapping(uint256 => Listing) public listings;
    mapping(uint256 => Auction) public auctions;
    mapping(address => uint256) public balances;

    event NFTListed(uint256 listingId, address seller, address nftContract, uint256 tokenId, uint256 price);
    event NFTSold(uint256 listingId, address buyer, uint256 price);
    event AuctionCreated(uint256 auctionId, address seller, address nftContract, uint256 tokenId, uint256 startPrice, uint256 endTime);
    event NewBidPlaced(uint256 auctionId, address bidder, uint256 amount);
    event AuctionEnded(uint256 auctionId, address winner, uint256 amount);
    event NFTDelisted(uint256 listingId);

    constructor() {}

    function setApprovalForMarketplace(address nftContract) public {
       IERC721(nftContract).setApprovalForAll(address(this), true);
    }

    function listNFT(address nftContract, uint256 tokenId, uint256 price) external nonReentrant {
        require(price > 0, "Price must be greater than zero");
        require(IERC721(nftContract).ownerOf(tokenId) == msg.sender, "Not the owner of NFT");
        require(IERC721(nftContract).isApprovedForAll(msg.sender, address(this)), "Approve marketplace first");

        _listingIds++;
        uint256 listingId = _listingIds;

        IERC721(nftContract).safeTransferFrom(msg.sender, address(this), tokenId);
        listings[listingId] = Listing(msg.sender, nftContract, tokenId, price, true);
        emit NFTListed(listingId, msg.sender, nftContract, tokenId, price);
    }

    function delistNFT(uint256 listingId) external nonReentrant {
        Listing storage listing = listings[listingId];
        require(listing.seller == msg.sender, "Not the seller");
        require(listing.isActive, "Listing is not active");

        listing.isActive = false;
        IERC721(listing.nftContract).safeTransferFrom(address(this), listing.seller, listing.tokenId);
        emit NFTDelisted(listingId);
    }

    function buyNFT(uint256 listingId) external payable nonReentrant {
        Listing storage listing = listings[listingId];
        require(listing.isActive, "Listing is not active");
        require(msg.value == listing.price, "Incorrect price");

        listing.isActive = false;
        balances[listing.seller] += msg.value;
        IERC721(listing.nftContract).safeTransferFrom(address(this), msg.sender, listing.tokenId);
        emit NFTSold(listingId, msg.sender, listing.price);
    }

    function createAuction(address nftContract, uint256 tokenId, uint256 startPrice, uint256 duration) external nonReentrant {
        require(startPrice > 0, "Start price must be greater than zero");
        require(duration > 0, "Duration must be positive");
        require(IERC721(nftContract).ownerOf(tokenId) == msg.sender, "Not the owner of NFT");
        require(IERC721(nftContract).isApprovedForAll(msg.sender, address(this)), "Approve marketplace first");

        _auctionIds++;
        uint256 auctionId = _auctionIds;

        IERC721(nftContract).safeTransferFrom(msg.sender, address(this), tokenId);
        auctions[auctionId] = Auction(msg.sender, nftContract, tokenId, startPrice, 0, address(0), block.timestamp + duration, true);
        emit AuctionCreated(auctionId, msg.sender, nftContract, tokenId, startPrice, block.timestamp + duration);
    }

    function placeBid(uint256 auctionId) external payable nonReentrant {
        Auction storage auction = auctions[auctionId];
        require(auction.isActive, "Auction is not active");
        require(block.timestamp < auction.endTime, "Auction has ended");
        require(msg.value > auction.highestBid, "Bid must be higher");

        if (auction.highestBidder != address(0)) {
            balances[auction.highestBidder] += auction.highestBid;
        }
        auction.highestBid = msg.value;
        auction.highestBidder = msg.sender;
        emit NewBidPlaced(auctionId, msg.sender, msg.value);
    }

    function endAuction(uint256 auctionId) external nonReentrant {
        Auction storage auction = auctions[auctionId];
        require(auction.isActive, "Auction is not active");
        require(block.timestamp >= auction.endTime, "Auction not ended yet");
        auction.isActive = false;

        if (auction.highestBidder != address(0)) {
            balances[auction.seller] += auction.highestBid;
            IERC721(auction.nftContract).safeTransferFrom(address(this), auction.highestBidder, auction.tokenId);
        } else {
            IERC721(auction.nftContract).safeTransferFrom(address(this), auction.seller, auction.tokenId);
        }
        emit AuctionEnded(auctionId, auction.highestBidder, auction.highestBid);
    }

    function withdrawFunds() external nonReentrant {
        uint256 amount = balances[msg.sender];
        require(amount > 0, "No funds to withdraw");
        balances[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
    }
}
 