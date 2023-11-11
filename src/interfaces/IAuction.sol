// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

interface IAuction {
    error OperationNotAllowed();
    error InvalidTimeToBid();
    error InvalidStartTime();
    error InvalidAuctionDuration();
    error InvalidBidAmount();
    error PrizeAlreadyClaimed();
    error AuctionStillActive();
    error AuctionEnded();
    error NotAllowedToClaim();
    error OperationFailed();
    error InvalidBidder();

    event BidWithdrawn(uint256 indexed bid, address indexed receiver);
    event PrizeClaimed(uint256 indexed amount, address indexed winner);
    event BidCancelled(uint256 indexed bid, address indexed receiver);

    struct BidInfo {
        uint256 bid;
        address bidder;
        bool status;
    }
}