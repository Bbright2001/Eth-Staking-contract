// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;


import {ERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "lib/openzeppelin-contracts/contracts/access/Ownable.sol";

contract FavoredBright is ERC20, Ownable {
    constructor(address recipient, address initialOwner)
        ERC20("FavoredBright", "FB")
        Ownable(initialOwner)
    {
        _mint(recipient, 1000000 * 10 ** decimals());
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }
}


contract EthStaking is ERC20, Ownable {
  
    ERC20 public reward;


    mapping(address => uint256) public stakeAmount;

    mapping(address => uint256) public stakeTimeStamp;

    uint256 constant public STAKE_LOCK_PERIOD = 10 seconds;

    error invalidAmount();
    error invalidAddress();
    error rewardTransferFailed();
    error stakeEthFailed();
    error stakingPeriodStillAlive();

    modifier onlyAfterStakePeriod() {
        
        if (block.timestamp< stakeTimeStamp[msg.sender] + STAKE_LOCK_PERIOD) {
            revert stakingPeriodStillAlive();
        }
        _;
    }

    constructor(address _rewardToken){
        reward = _rewardToken;
    }

}