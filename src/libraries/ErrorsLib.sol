// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

/// @title ErrorsLib
/// @author cartlex
/// @custom:contact cartlexeth@gmail.com
/// @notice Library exposing error messages.
library ErrorsLib {
    /// @notice Thrown when the caller can't call the function.
    error OperationNotAllowed();

    /// @notice Thrown when it's not possible to make a bid.
    error InvalidTimeToBid();

    /// @notice Thrown when passed to the constructor timestamp value is less then current timestamp.
    error InvalidStartTime();

    /// @notice Thrown when passed to the constructor auction duration is less than `AUCTION_MIN_DURATION`.
    error InvalidAuctionDuration();

    /// @notice Thrown when the bid is less or equal to current maximum bid.
    error InvalidBidAmount();

    /// @notice Thrown when the prize is already claimed.
    error PrizeAlreadyClaimed();

    /// @notice Thrown when `claimPrize` function used before auction ended.
    error AuctionStillActive();

    /// @notice Thrown when `cancelBid` function used after auction ended.
    error AuctionEnded();

    /// @notice Thrown when caller's bid is not `currentMaximumBidAmount`.
    error NotAllowedToClaim();

    /// @notice Thrown when return value of `call` is equal to false.
    error OperationFailed();
}