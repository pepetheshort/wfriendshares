// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import {Test, console2} from "forge-std/Test.sol";
import {FriendtechSharesV1} from "../src/FriendtechSharesV1.sol";
import {WFriendShares} from "../src/WFriendShares.sol";

contract WFriendSharesTest is Test {
    FriendtechSharesV1 public friendShares;
    WFriendShares public wrapper;
    address testFren = address(0xfab);

    // functions to play well with callbacks and receive payments
    receive() external payable {}

    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes calldata
    ) external pure returns (bytes4) {
        return this.onERC1155Received.selector;
    }    

    function setUp() public {
        friendShares = new FriendtechSharesV1();
        wrapper = new WFriendShares(address(friendShares));

        vm.prank(testFren);
        friendShares.buyShares(testFren, 1);
    }

    function testWrap() public {
        uint price = friendShares.getBuyPrice(testFren, 10);
        wrapper.wrap{value: price}(testFren, 10);

        assertEq(wrapper.balanceOf(address(this), uint160(testFren)), 10);
        assertEq(address(wrapper).balance, 0);
    }

    function testUnwrap() public {
        testWrap(); // starting with 10 wTestFren

        uint price = friendShares.getSellPriceAfterFee(testFren, 10);
        uint prevBalance = address(this).balance;

        wrapper.unwrap(testFren, 10);
        assertEq(wrapper.balanceOf(address(this), uint160(testFren)), 0);
        assertEq(address(wrapper).balance, 0);
        assertEq(address(this).balance, prevBalance + price);
    }
}
