// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

interface IAuction {
    struct BidInfo {
        uint256 bid;
        address bidder;
        bool status;
    }

    /// @notice Do a bid to paricipate in auction.
    function participate() external;

    /// @notice Claims prize.
    function claimPrize() external;

    /// @notice Allows to withdraw a bid.
    function withdraw() external;

    /// @notice Allows to cancel a bid.
    function cancelBid() external;
}