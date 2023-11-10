// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import {Ownable2Step} from "@openzeppelin/contracts/access/Ownable2Step.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract Auction is Ownable2Step {
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

    uint256 private constant AUCTION_MIN_DURATION = 1 days;
    uint256 private constant PRIZE_CLAIMED = 1;
    uint256 private constant PRIZE_IS_NOT_CLAIMED = 2;
    uint256 private constant PRIZE = 10 ether;
    uint256 private immutable AUCTION_START_TIME;
    uint256 private immutable AUCTION_END_TIME;

    uint256 currentMaximumBidAmount;

    struct BidInfo {
        uint256 bid;
        address bidder;
        bool status;
    }

    mapping(address bidder => BidInfo) public bids;
    uint256 claimed = PRIZE_IS_NOT_CLAIMED;

    constructor(uint256 auctionStartTime, uint256 auctionDuration) Ownable(msg.sender) {
        if (auctionDuration < AUCTION_MIN_DURATION) revert InvalidAuctionDuration();
        if (auctionStartTime < block.timestamp) revert InvalidStartTime();
        AUCTION_START_TIME = auctionStartTime;
        AUCTION_END_TIME = AUCTION_START_TIME + auctionDuration;
    }

    function participate() external payable {
        if (!(block.timestamp >= AUCTION_START_TIME && block.timestamp <= AUCTION_END_TIME)) {
            revert InvalidTimeToBid();
        }

        if (msg.value <= currentMaximumBidAmount) revert InvalidBidAmount();
        
        bids[msg.sender] = BidInfo({bid: msg.value, bidder: msg.sender, status: true});
    }

    function claimPrize() external {
        if (block.timestamp <= AUCTION_END_TIME) revert AuctionStillActive();
        if (claimed == PRIZE_CLAIMED) revert PrizeAlreadyClaimed();
        claimed = PRIZE_CLAIMED;
        BidInfo memory bidInfo = bids[msg.sender];
        if (bidInfo.bid != currentMaximumBidAmount) revert NotAllowedToClaim();
        bidInfo.status = false;

        bids[msg.sender] = bidInfo;

        (bool success,) = msg.sender.call{value: PRIZE}("");
        if (!success) revert OperationFailed();
        emit PrizeClaimed(PRIZE, msg.sender);
    }

    
    function withdraw() external {
        if (block.timestamp <= AUCTION_END_TIME) revert AuctionStillActive();

        BidInfo memory bidInfo = bids[msg.sender];
        uint256 amountToSend = bidInfo.bid;
        if (amountToSend != 0) {
            delete bids[msg.sender];

            (bool success, ) = msg.sender.call{value: amountToSend}("");
            if (!success) revert OperationFailed();
            emit BidWithdrawn(amountToSend, msg.sender);
        }
    }

    function cancelBid() external {
        if (block.timestamp > AUCTION_END_TIME) revert AuctionEnded();

        BidInfo memory bidInfo = bids[msg.sender];
        uint256 amountToSend = bidInfo.bid;
        if (bidInfo.status && amountToSend != 0) {
            delete bids[msg.sender];

            (bool success, ) = msg.sender.call{value: amountToSend}("");
            if (!success) revert OperationFailed();
            emit BidCancelled(amountToSend, msg.sender);
        }
    }

    function renounceOwnership() public override {
        revert OperationNotAllowed();
    }
}
