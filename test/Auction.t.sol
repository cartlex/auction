// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import {console2, Test, StdStyle} from "forge-std/Test.sol";
import {Auction} from "../src/Auction.sol";
import {IAuction} from "../src/interfaces/IAuction.sol";

contract AuctionTest is Test {
    Auction public auction;

    address public alice;
    address public bob;
    address public owner;

    function setUp() public virtual {

        alice = makeAddr("Alice");
        bob = makeAddr("Bob");
        owner = makeAddr("owner");

        vm.label(alice, "alice");
        vm.label(bob, "bob");
        vm.label(owner, "owner");
    }
}

contract DeployAuctionTest is AuctionTest {

    function setUp() public override {
        super.setUp();
    }

    function test_DeployInvalidAuctionDuration() external {
            uint256 auctionStartTime = block.timestamp;
            uint256 auctionDuration = 1 days - 1;

            vm.startPrank(owner);

            vm.expectRevert(IAuction.InvalidAuctionDuration.selector);
            auction = new Auction(
                auctionStartTime,
                auctionDuration
            );

            vm.stopPrank();
        }

    function test_DeployInvalidStartTime() external {
        vm.warp(block.timestamp + 10_000);

        uint256 auctionStartTime = block.timestamp - 1;
        uint256 auctionDuration = 1 days;

        vm.startPrank(owner);

        vm.expectRevert(IAuction.InvalidStartTime.selector);
        auction = new Auction(
            auctionStartTime,
            auctionDuration
        );
        
        vm.stopPrank();
    }

    function test_DeployCheckOwner() external {
        vm.startPrank(owner);

        uint256 auctionDuration = 1 days;
        
        auction = new Auction(
            block.timestamp,
            auctionDuration
        );

        assertEq(auction.owner(), owner);
        
        vm.stopPrank();
    }
}