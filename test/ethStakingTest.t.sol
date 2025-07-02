// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {EthStaking} from "../src/ethStaking.sol";
import {ERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract TestToken is ERC20 {
    constructor()
        ERC20("testToken", "tt")
    {
        _mint(msg.sender, 1_000_000 * 10 ** decimals());
    }
}

contract EthStakingTest is Test {
        address staker;
        EthStaking public staking;
        TestToken public mockToken;
        

        function setUp() public{

                staker = address(0x1);

                mockToken = new TestToken();   

                staking = new EthStaking( address(this), address(mockToken) );



                //transfer test token to staking contract

                mockToken.transfer( address(staking), 1_000_000 * 1e18 );

                vm.deal(staker, 5 ether);
        }


        function testStakeAndWithdrawAfterTenSeconds() public {
                vm.startPrank(staker);

                staking.stakeEth{value: 1 ether}();

                assertEq(staking.stakeAmount(staker), 1 ether);

                console.log(staking.stakeAmount(staker));

                vm.warp(block.timestamp + 11 seconds);

                uint256 contractBalance = mockToken.balanceOf(address(staking));
                 console.log("Staking contract token balance:", contractBalance);
                assertTrue(contractBalance >= 10 ether);

                staking.withdraw();

                uint256 reward = mockToken.balanceOf(staker);
                assertEq(reward, 10 );
                console.log("staker reward: ",  reward);


                assertEq(staker.balance, 5 ether);


                assertEq(staking.stakeAmount(staker), 0);
                assertEq(staking.claimed(staker), true);

                vm.stopPrank();
        }

        function testStakeZeroEth()  public {
                vm.prank(staker);

                vm.expectRevert(EthStaking.invalidAmount.selector);
                staking.stakeEth{ value: 0 ether}();
               
        }

}
