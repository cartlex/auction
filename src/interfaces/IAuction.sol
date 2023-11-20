// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

interface IAuction {
    struct BidInfo {
        uint256 bid;
        address bidder;
        bool status;
    }
}