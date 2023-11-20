// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import {Ownable, Ownable2Step} from "@openzeppelin/contracts/access/Ownable2Step.sol";
import {IAuction} from "./interfaces/IAuction.sol";
import {ErrorsLib} from "./libraries/ErrorsLib.sol";
import {EventsLib} from "./libraries/EventsLib.sol";
import {ConstantsLib} from "./libraries/ConstantsLib.sol";

contract Auction is Ownable2Step, IAuction {
    uint256 private immutable AUCTION_START_TIME;
    uint256 private immutable AUCTION_END_TIME;

    uint256 currentMaximumBidAmount;

    mapping(address bidder => BidInfo) public bids;
    uint256 claimed = ConstantsLib.PRIZE_IS_NOT_CLAIMED;

    constructor(uint256 auctionStartTime, uint256 auctionDuration) Ownable(msg.sender) payable {
        if (auctionDuration < ConstantsLib.AUCTION_MIN_DURATION) revert ErrorsLib.InvalidAuctionDuration();
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
        if (claimed == ConstantsLib.PRIZE_CLAIMED) revert ErrorsLib.PrizeAlreadyClaimed();
        claimed = ConstantsLib.PRIZE_CLAIMED;
        BidInfo memory bidInfo = bids[msg.sender];
        if (bidInfo.bid != currentMaximumBidAmount) revert ErrorsLib.NotAllowedToClaim();
        bidInfo.status = false;

        bids[msg.sender] = bidInfo;

        (bool success,) = msg.sender.call{value: ConstantsLib.PRIZE}("");
        if (!success) revert ErrorsLib.OperationFailed();
        emit EventsLib.PrizeClaimed(msg.sender, ConstantsLib.PRIZE);
    }

    
    function withdraw() external {
        if (block.timestamp <= AUCTION_END_TIME) revert ErrorsLib.AuctionStillActive();

        BidInfo memory bidInfo = bids[msg.sender];
        uint256 amountToSend = bidInfo.bid;
        if (amountToSend != 0) {
            delete bids[msg.sender];

            (bool success, ) = msg.sender.call{value: amountToSend}("");
            if (!success) revert ErrorsLib.OperationFailed();
            emit EventsLib.BidWithdrawn(msg.sender, amountToSend);
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
            emit EventsLib.BidCancelled(msg.sender, amountToSend);
        }
    }

    function renounceOwnership() public pure override {
        revert ErrorsLib.OperationNotAllowed();
    }
}
