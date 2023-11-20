// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import {Ownable, Ownable2Step} from "@openzeppelin/contracts/access/Ownable2Step.sol";
import {IAuction} from "./interfaces/IAuction.sol";
import {ErrorsLib} from "./libraries/ErrorsLib.sol";

contract Auction is Ownable2Step, IAuction {
    uint256 private constant AUCTION_MIN_DURATION = 1 days;
    uint256 private constant PRIZE_CLAIMED = 1;
    uint256 private constant PRIZE_IS_NOT_CLAIMED = 2;
    uint256 private constant PRIZE = 10 ether;
    uint256 private immutable AUCTION_START_TIME;
    uint256 private immutable AUCTION_END_TIME;

    uint256 currentMaximumBidAmount;

    mapping(address bidder => BidInfo) public bids;
    uint256 claimed = PRIZE_IS_NOT_CLAIMED;

    constructor(uint256 auctionStartTime, uint256 auctionDuration) Ownable(msg.sender) payable {
        if (auctionDuration < AUCTION_MIN_DURATION) revert ErrorsLib.InvalidAuctionDuration();
        if (auctionStartTime < block.timestamp) revert ErrorsLib.InvalidStartTime();
        AUCTION_START_TIME = auctionStartTime;
        AUCTION_END_TIME = AUCTION_START_TIME + auctionDuration;
    }

    function participate() external payable {
        if (!(block.timestamp >= AUCTION_START_TIME && block.timestamp <= AUCTION_END_TIME)) {
            revert ErrorsLib.InvalidTimeToBid();
        }

        if (msg.value <= currentMaximumBidAmount) revert ErrorsLib.InvalidBidAmount();
        
        bids[msg.sender] = BidInfo({bid: msg.value, bidder: msg.sender, status: true});
    }

    function claimPrize() external {
        if (block.timestamp <= AUCTION_END_TIME) revert ErrorsLib.AuctionStillActive();
        if (claimed == PRIZE_CLAIMED) revert ErrorsLib.PrizeAlreadyClaimed();
        claimed = PRIZE_CLAIMED;
        BidInfo memory bidInfo = bids[msg.sender];
        if (bidInfo.bid != currentMaximumBidAmount) revert ErrorsLib.NotAllowedToClaim();
        bidInfo.status = false;

        bids[msg.sender] = bidInfo;

        (bool success,) = msg.sender.call{value: PRIZE}("");
        if (!success) revert ErrorsLib.OperationFailed();
        emit PrizeClaimed(PRIZE, msg.sender);
    }

    
    function withdraw() external {
        if (block.timestamp <= AUCTION_END_TIME) revert ErrorsLib.AuctionStillActive();

        BidInfo memory bidInfo = bids[msg.sender];
        uint256 amountToSend = bidInfo.bid;
        if (amountToSend != 0) {
            delete bids[msg.sender];

            (bool success, ) = msg.sender.call{value: amountToSend}("");
            if (!success) revert ErrorsLib.OperationFailed();
            emit BidWithdrawn(amountToSend, msg.sender);
        }
    }

    function cancelBid() external {
        if (block.timestamp > AUCTION_END_TIME) revert ErrorsLib.AuctionEnded();

        BidInfo memory bidInfo = bids[msg.sender];
        uint256 amountToSend = bidInfo.bid;
        if (bidInfo.status && amountToSend != 0) {
            delete bids[msg.sender];

            (bool success, ) = msg.sender.call{value: amountToSend}("");
            if (!success) revert ErrorsLib.OperationFailed();
            emit BidCancelled(amountToSend, msg.sender);
        }
    }

    function renounceOwnership() public pure override {
        revert ErrorsLib.OperationNotAllowed();
    }
}
