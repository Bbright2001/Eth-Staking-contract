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
  
    ERC20 public token;


    mapping(address => uint256) public stakeAmount;

    mapping(address => uint256) public stakeTimeStamp;

    mapping(address => bool) public claimed;

    uint256 constant public STAKE_LOCK_PERIOD = 10 seconds;

    error invalidAmount();
    error invalidAddress();
    error rewardTransferFailed();
    error withdrawEthFailed();
    error stakingPeriodStillAlive();
    error tokenClaimed();

    modifier onlyAfterStakePeriod() {
        
        if (block.timestamp< stakeTimeStamp[msg.sender] + STAKE_LOCK_PERIOD) {
            revert stakingPeriodStillAlive();
        }
        _;
    }

    constructor(address _rewardToken){
        reward = _rewardToken;
    }

    function stakeEth() external payable{
        if (msg.value == 0) revert invalidAmount();

        stakeAmount[msg.sender] += msg.value;
        stakeTimeStamp = block.timestamp;
        claimed[msg.sender] = false;
    }

    function withdraw() external onlyAfterStakePeriod(){
        uint256 amount = stakeAmount[msg.sender];
        require(amount > 0, "You aren't a participant");
        if(msg.sender == address(0) ) revert invalidAddress();
        require(!success, "");


        stakeAmount[msg.sender] = 0;
        claimed[msg.sender] = true;

        (bool success, ) = msg.sender.cal{value: amount}('');
        if (!success) revert withdrawEthFailed();
        uint256 rewardAmount = (amount * 10) / 1 ether;

        require(token.transfer(msg.sender, rewardAmount), "Reward transfer failed");

    }

    receive() external payable;
}