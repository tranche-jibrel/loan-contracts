// SPDX-License-Identifier: MIT
/**
 * Created on 2020-11-26
 * @summary: Jibrel Loans storage
 * @author: Jibrel Team
 */
pragma solidity 0.6.12;


import "@openzeppelin/contracts-ethereum-package/contracts/access/Ownable.sol";
import "./JLoanStructs.sol";

contract JLoanStorage is OwnableUpgradeSafe, JLoanStructs {
    /* WARNING: NEVER RE-ORDER VARIABLES! Always double-check that new variables are added APPEND-ONLY. Re-ordering variables can permanently BREAK the deployed proxy contract.*/
    // other contracts addresses
    address public feesCollectorAddress;
    address public priceOracleAddress;
    address public loanHelperAddress;

    // loan id 
    uint256 public loanId;

    // locking booleans
    bool public fLock;
    bool public fLockAux;

    // contract version
    uint256 public contractVersion;

    // shareholders struct
    struct Shareholder {
        address holder;
        uint256 shares;
        uint256 ownerBlockNumber;
    }

    // general loans parameters
    GeneralParams public generalLoansParams;

    // general fees parameters
    FeesParams public generalLoanFees;

    // mappings
    mapping (uint256 => ContractParams) public loanParams;
    mapping (uint256 => Status) public loanStatus;

    mapping(address => bool) public borrowers;
    mapping(uint256 => address) public loanBorrower;
    mapping(uint256 => uint256) public loanPair;
    mapping(uint256 => uint256) public loanBalance;
    mapping(uint256 => uint256) public loanAskAmount;
    
    mapping(uint256 => uint256) public loanActiveBlock;
    mapping(uint256 => uint256) public loanLastDepositBlock;
    mapping(uint256 => uint256) public loanLastWithdrawBlock;
    mapping(uint256 => uint256) public loanInitiateForecloseBlock;
    mapping(uint256 => uint256) public loanClosingBlock;
    mapping(uint256 => uint256) public loanClosedBlock;
    mapping(uint256 => uint256) public lastInterestWithdrawalBlock;
    mapping(uint256 => uint256) public loanForeclosingBlock;
    mapping(uint256 => uint256) public loanForeclosedBlock;

    mapping(uint256 => mapping(uint256 => Shareholder)) public loanShareholders;
    mapping(uint256 => mapping(address => bool)) public loanShareholdersAddress;
    mapping(uint256 => mapping(address => uint256)) public loanShareholdersPlace;
    mapping(uint256 => uint256) public shareholdersCounter;
}