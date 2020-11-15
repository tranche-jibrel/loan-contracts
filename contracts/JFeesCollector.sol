// SPDX-License-Identifier: MIT
/**
 * Created on 2020-11-09
 * @summary: Jibrel Fees Collector
 * @author: Jibrel Team
 */
pragma solidity 0.6.12;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "./TransferHelper.sol";


contract JFeesCollector is Ownable, ReentrancyGuard {
    using SafeMath for uint;

    mapping(address => bool) public tokensAllowed;
    
    event EthReceived(address sender, uint amount, uint blockNumber);
    event EthWithdrawed(uint amount, uint blockNumber);
    event TokenAdded(address token, uint blockNumber);
    event TokenRemoved(address token, uint blockNumber);
    event TokenWithdrawed(address token, uint amount, uint blockNumber);

    constructor() payable public { }
    
    function getEthBalance() external view returns (uint) {
        return address(this).balance;
    }
    
    receive() external payable {
        emit EthReceived(msg.sender, msg.value, block.number);
    }

    /**
    * @dev withdraw eth amount
    * @param _amount amount of withdrawed eth
    */
    function ethWithdraw(uint _amount) external nonReentrant onlyOwner {
        require(_amount <= address(this).balance, "Not enough contract balance");
        TransferHelper.safeTransferETH(msg.sender, _amount);
        emit EthWithdrawed(_amount, block.number);
    }

    /**
    * @dev add allowed token address
    * @param _tok address of the token to add
    */
    function allowToken(address _tok) external onlyOwner {
        require(!isTokenAllowed(_tok), "Token already allowed");
        tokensAllowed[_tok] = true;
        emit TokenAdded(_tok, block.number);
    }

    /**
    * @dev remove allowed token address
    * @param _tok address of the token to add
    */
    function disallowToken(address _tok) external onlyOwner {
        require(isTokenAllowed(_tok), "Token not allowed");
        tokensAllowed[_tok] = false;
        emit TokenRemoved(_tok, block.number);
    }

    /**
    * @dev get contract token balance
    * @param _tok address of the token
    */
    function getTokenBalance(address _tok) external view returns (uint) {
        return IERC20(_tok).balanceOf(address(this));
    }

    /**
    * @dev check if a token is already allowed
    * @param _tok address of the token
    */
    function isTokenAllowed(address _tok) public view returns (bool) {
        return tokensAllowed[_tok];
    }

    /**
    * @dev withdraw tokens from the contract, checking if a token is already allowed
    * @param _tok address of the token
    * @param _amount token amount
    */
    function withdrawTokens(address _tok, uint _amount) external nonReentrant onlyOwner {
        require(isTokenAllowed(_tok), "Token not allowed");
        TransferHelper.safeTransfer(_tok, msg.sender, _amount);
        emit TokenWithdrawed(_tok, _amount, block.number);
    }
}
