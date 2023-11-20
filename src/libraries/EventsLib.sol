// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

/// @title EventsLib
/// @author cartlex
/// @custom:contact cartlexeth@gmail.com
/// @notice Library exposing events.
library EventsLib {
    /// @notice Emitted when withdraw a bid.
    /// @param bid Amount of ETH to send.
    /// @param receiver Address to send bid to.
    event BidWithdrawn(address indexed receiver, uint256 indexed bid);

    /// @notice Emitted when auction winner claimed a prize.
    /// @param amount Prize amount that auction winner claimed.
    /// @param winner The winner of the auction.
    event PrizeClaimed( address indexed winner, uint256 indexed amount);

    /// @notice Emitted when bid is cancelled.
    /// @param bid Amount of ETH to send.
    /// @param receiver Address to send bid to.
    event BidCancelled(address indexed receiver, uint256 indexed bid);
}