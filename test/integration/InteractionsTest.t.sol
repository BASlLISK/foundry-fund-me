//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundFundMe, WithdrawFundMe} from "../../script/Interactions.s.sol";

contract InteractionsTest is Test {
    FundMe fundMe;
    DeployFundMe deployFundMe;
    address marx = makeAddr("marx");
    uint256 public constant SEND_VALUE = 0.1 ether;

    function setUp() external {
        deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(marx, 10 ether);
    }

    function testUserCanFundAndOwnerWithdraw() public {
        uint256 preUserBalance = address(marx).balance;
        uint256 preOwnerBalance = address(fundMe.getOwner()).balance;

        vm.prank(marx);
        fundMe.fund{value: SEND_VALUE}();

        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        withdrawFundMe.withdrawFundMe(address(fundMe));

        uint256 postUserBalance = address(marx).balance;
        uint256 postOwnerBalance = address(fundMe.getOwner()).balance;

        assert(address(fundMe).balance == 0);
        assert(postUserBalance < preUserBalance);
        assert(postOwnerBalance > preOwnerBalance);
    }
}
