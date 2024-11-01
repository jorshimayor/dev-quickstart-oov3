// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/PredictionMarket.sol";

contract PredictionMarketTest is Test {
    PredictionMarket public market;
    address owner = address(0x1);
    address relayer = address(0x2);
    address alice = address(0x3);
    address bob = address(0x4);

    function setUp() public {
        vm.prank(owner);
        market = new PredictionMarket(1 days, relayer);
    }

    function testBetYesAndNo() public {
        vm.deal(alice, 1 ether);
        vm.deal(bob, 2 ether);

        vm.prank(alice);
        market.betYes{value: 1 ether}();

        vm.prank(bob);
        market.betNo{value: 2 ether}();

        assertEq(market.betsOnYes(alice), 1 ether, "Alice's Yes bet should be 1 ether");
        assertEq(market.betsOnNo(bob), 2 ether, "Bob's No bet should be 2 ether");
    }

    function testRequestAndResolveMarket() public {
        vm.warp(block.timestamp + 1 days);
        vm.prank(owner);
        market.requestMarketData("Did event occur?");

        vm.prank(relayer);
        market.resolveMarket(true);

        assertTrue(market.marketResolved(), "Market should be resolved");
        assertTrue(market.outcome(), "Outcome should be Yes");
    }
}