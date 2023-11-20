// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

/// @title ConstantsLib
/// @author cartlex
/// @custom:contact cartlexeth@gmail.com
/// @notice Library exposing constants.
library ConstantsLib {
    /// @notice Minimum auction duration.
    uint256 internal constant AUCTION_MIN_DURATION = 1 days;

    /// @notice A constant that signals that the prize claimed.
    uint256 internal constant PRIZE_CLAIMED = 1;

    /// @notice A constant that signals that the prize is NOT claimed.
    uint256 internal constant PRIZE_IS_NOT_CLAIMED = 2;

    /// @notice Amount of ETH that receive auction winner.
    uint256 internal constant PRIZE = 10 ether;
}