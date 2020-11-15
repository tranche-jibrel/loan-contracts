// SPDX-License-Identifier: MIT
/**
 * Created on 2020-11-09
 * @summary: Jibrel Loan Deployer
 * @author: Jibrel Team
 */
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


interface IJLoanCommons {
    struct GeneralParams {
        uint earlySettlementWindow;
        uint foreclosureWindow;
        uint8 requiredCollateralRatio;
        uint8 foreclosingRatio;
        uint8 instantForeclosureRatio;
        uint8 limitCollRatioForWithdraw;
        address factoryAddress;
        address loanDeployerAddress;
        address priceOracleAddress;
    }

    struct FeesParams {
        uint earlySettlementFee;
        uint8 factoryFees;
        uint8 userRewardShare;
        uint8 vaultRewardShare;
        uint8 cancellationFees;
        uint16 undercollateralizedForeclosingMultiple;
        uint16 atRiskForeclosedMultiple;
    }

    struct ContractParams {
        uint rpbRate; 
        uint initialCollateralRatio;
        uint creationBlock;
    }

    enum Status {
        pending,                // 0    by borrower
        active,                 // 1    by lender(s) and >= 200% initialCollateralRatio
        underCollateralized,    // 2    (< 150%) foreclosingRatio
        atRisk,                 // 3    (< 120%) instantForeclosureRatio
        foreclosing,            // 4    third party proposal (fees), starting time and vlaue conditions to go in atrisk
        foreclosed,             // 5    if foreclosing and atrisk, set by third party (fees) (borrower could not adjust collateral, and he cannot send back stable coins)
                                //      firts rewards (80/20), then shareholders (collateral + interests), then borrower
        earlyClosing,           // 6    loan is settled early by the borrower, it continue to calculate interests until the earlySettlementWindow, 
                                //      then it can be closed by lender(s). Borrower could not add collateral
        closing,                // 7    only by borrower (borrower could not adjust collateral)
        closed,                 // 8    by lender(s): from atRisk or from foreclosed (borrower could not adjust collateral)
        cancelled               // 9    loan cancelled by the borrower before receiving lender's stable coins (borrower could not adjust collateral)
    } 

}


interface IJFactory {
    function isAdmin(address account) external view returns (bool);
    function addAdmin(address account) external;
    function removeAdmin(address account) external;
    function renounceAdmin() external;
    function setLoanDeployerAddress(address _loanDepl) external;
    function setPriceOracleAddress(address _priceOracle) external;
    function calculateCollFeesOnActivation(uint _collAmount) external view returns (uint);
    function calcMinCollateralAmount(uint _pairId, uint _askAmount) external view returns (uint);
    function calcMinCollateralWithFeesAmount(uint _pairId, uint _askAmount) external view returns (uint);
    function setEarlySettlementWindow(uint _value) external;
    function setForeclosureWindow(uint _value) external;
    function setForeclosureRatio(uint8 _value) external;
    function setInstantForeclosureRatio(uint8 _value) external;
    function setRequiredCollateralRatio(uint8 _value) external;
    function setFactoryFees(uint8 _value) external;
    function setEarlySettlementFee(uint _value) external;
    function setUserRewardShare(uint8 _value) external;
    function setVaultShares(uint8 _value) external;
    function setUndercollateralizedForeclosingMultiple(uint16 _value) external;
    function setAtRiskForeclosedMultiple(uint16 _value) external;
    function setCancellationFees(uint8 _value) external;
    function getGeneralParams() external view returns (IJLoanCommons.GeneralParams memory);
    function getGeneralFees() external view returns (IJLoanCommons.FeesParams memory);
    function createNewLoanContract() external returns (address);
    function getLoanDeployer() external view returns(address);
    function getDeployedLoan(uint _idx) external view returns (address);
    function setLoanGeneralParamsInContract(uint _idx) external;
    function setLoanFeesParamsInContract(uint _idx) external;
    function setStatusInLoan (uint _idx, uint _loanId, uint _newStatus) external;
    function adjustDecimalsCollateral(uint _pairId, uint _numerator, uint _quotient) external view returns (uint result);
    function ratioDiffCollAmount(uint _pairId, uint _ratio, uint _amount, uint _balance) external view returns (uint collDiff);
    function collateralAdjustingRatio(uint _pairId, uint _borrAmount, uint _balance, uint _newAmount, bool _adding) external view returns (uint ratio);
    function getCollateralRatio(uint _pairId, uint _borrAmount, uint _balance) external view returns (uint newCollRatio);
}


/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}


/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow, so we distribute
        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}


/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () internal {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}


interface IJLoan {
    function getCollateralTokenAddress(uint _pairId) external view returns (address);
    function getLentTokenAddress(uint _pairId) external view returns (address);
    function openNewLoan(uint _pairId, uint _borrowedAskAmount, uint _rpbRate) external payable;
    function getLoansCounter() external view returns (uint);
    function setNewGeneralLoansParams() external;
    function setNewFeesParams() external;
    function depositEthCollateral(uint _id) external payable;
    function depositTokenCollateral(uint _id, address _tok, uint _amount) external;
    function withdrawCollateral(uint _id, uint _amount) external;
    function getContractBalance(uint _id) external view returns (uint);
    function getLoanBalance(uint _id) external view returns (uint);
    function getLoanStatus(uint _id) external view returns (uint);
    function setNewStatus(uint _id, uint _newStatus) external;
    function checkLoanInEarlySettlementWindow(uint _id) external view returns (bool);
    function checkEarlySettledLoan(uint _id) external view returns (bool);
    function setInitalCollateralRatio(uint _id) external;
    function getActualCollateralRatio(uint _id) external view returns (uint newCollRatio);
    function calcRatioAdjustingCollateral(uint _id, uint _amount, bool _adding) external view returns (uint ratio);
    function calcDiffCollAmountForRatio(uint _id, uint _ratio) external view returns (uint collDiff);
    function lenderSendStableCoins(uint _id, address _stableAddr) external;
    function setLoanStatusOnCollRatio(uint _id) external returns (uint);
    function initiateLoanForeclose(uint _id) external;
    function setLoanToForeclosed(uint _id) external returns (bool);
    function loanClosingByBorrower(uint _id) external;
    function setLoanCancelled(uint _id) external;
    function calculatingAccruedInterests(uint _id, uint _calcBlk) external view returns (uint);
    function getAccruedInterests(uint _id) external view returns (uint accruedInterests);
    function withdrawInterests(uint _id) external returns (uint);
    function withdrawInterestsMassive(uint[] calldata _id) external returns (bool success);
    function isShareholder(uint _id, address _holder) external view returns (bool);
    function getShareholderPlace(uint _id, address _holder) external view returns (uint);
    function addLoanShareholders(uint _id, address _newShareholder, uint _amount) external returns (uint);
    function addLoanShareholdersMassive(uint _id, address[] memory _newShareholder, uint[] memory _amount) external returns (bool success);
}


// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TH APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TH TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TH TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TH ETH_TRANSFER_FAILED');
    }
}


interface IJPriceOracle {
    function setFactoryAddress(address _factoryAddress) external;
    function setNewPair(string calldata _pairName, uint _price, uint8 _pairDecimals, 
                address _baseAddress, uint8 _baseDecimals, address _quoteAddress, uint8 _quoteDecimals) external;
    function setPairValue(uint _pairId, uint _price, uint8 _pairDecimals) external;
    function setBaseQuoteDecimals(uint _pairId, uint8 _baseDecimals, uint8 _quoteDecimals) external;
    function getPairCounter() external view returns (uint);
    function getPairValue(uint _pairId) external view returns (uint);
    function getPairName(uint _pairId) external view returns (string memory);
    function getPairDecimals(uint _pairId) external view returns (uint8);
    function getPairBaseDecimals(uint _pairId) external view returns (uint8);
    function getPairQuoteDecimals(uint _pairId) external view returns (uint8);
    function getPairBaseAddress(uint _pairId) external view returns (address);
    function getPairQuoteAddress(uint _pairId) external view returns (address);
}


contract JLoan is Ownable, ReentrancyGuard, IJLoanCommons, IJLoan {
    using SafeMath for uint;

    address public feesCollector;
    
    mapping(address => bool) public borrowers;
    mapping(uint => address) public loanBorrower;
    mapping(uint => uint) public loanPair;
    mapping(uint => uint) public loanBalance;
    mapping(uint => uint) public loanAskAmount;

    uint public loanId;
    bool public fLock;

    GeneralParams public generalLoansParams;
    FeesParams public loanFees;
    mapping (uint => ContractParams) public loanParams;
    mapping (uint => Status) public loanStatus;
    
    mapping(uint => uint) public loanActiveBlock;
    mapping(uint => uint) public loanLastDepositBlock;
    mapping(uint => uint) public loanLastWithdrawBlock;
    mapping(uint => uint) public loanInitiateForecloseBlock;
    mapping(uint => uint) public loanClosingBlock;
    mapping(uint => uint) public loanClosedBlock;
    mapping(uint => uint) public lastInterestWithdrawalBlock;
    mapping(uint => uint) public loanForeclosingBlock;
    mapping(uint => uint) public loanForeclosedBlock;

    struct Shareholder {
        address holder;
        uint shares;
        uint ownerBlockNumber;
    }

    mapping(uint => mapping(uint => Shareholder)) public loanShareholders;
    mapping(uint => mapping(address => bool)) public loanShareholdersAddress;
    mapping(uint => mapping(address => uint)) public loanShareholdersPlace;
    mapping(uint => uint) public shareholdersCounter;

    event CollateralReceived(uint id, uint pairId, address sender, uint value, uint status);
    event WithdrawCollateral(uint id, uint amount);
    event LoanStatusChanged(uint id, uint oldStatus, uint newStatus, uint collectorAmnt, uint userAmnt);
    event AddShareholderShares(uint id, address indexed sharesBuyer, uint indexed amount);
    event InterestsWithdrawed(uint id, uint accruedInterests);

    constructor(address _factoryAddress, address _feesCollector) public payable {
        generalLoansParams = IJFactory(_factoryAddress).getGeneralParams();
        loanFees = IJFactory(_factoryAddress).getGeneralFees();
        feesCollector = payable(_feesCollector);
    }

    modifier onlyLoanFactory() {
        require(msg.sender == generalLoansParams.factoryAddress, "!factory");
        _;
    }

    fallback() external { // cannot deposit eth
        revert("ETH not accepted!");
    }

    /**
    * @dev get collateral token address, reading them from price oracle
    * @param _pairId pairId
    * @return address of the collateral token
    */
    function getCollateralTokenAddress(uint _pairId) public override view returns (address) {
        return IJPriceOracle(generalLoansParams.priceOracleAddress).getPairBaseAddress(_pairId);
    }

    /**
    * @dev get lent token address, reading them from price oracle
    * @param _pairId pairId
    * @return address of the lent token
    */
    function getLentTokenAddress(uint _pairId) public override view returns (address) {
        return IJPriceOracle(generalLoansParams.priceOracleAddress).getPairQuoteAddress(_pairId);
    }

    /**
    * @dev open a new eth loan with msg.value amount of collateral
    * @param _pairId pair Id
    * @param _borrowedAskAmount ERC20 address
    * @param _rpbRate token amount
    */
    function openNewLoan(uint _pairId, uint _borrowedAskAmount, uint _rpbRate) external override payable nonReentrant {
        require(msg.sender!=address(0), "_senderZeroAddress");
        uint256 totalCollateralRequest = IJFactory(generalLoansParams.factoryAddress).calcMinCollateralWithFeesAmount(_pairId, _borrowedAskAmount);
        uint collAmount;
        uint allowance = 0;
        address collateralToken = getCollateralTokenAddress(_pairId);
        if (collateralToken == address(0)) {
            collAmount = msg.value;
            require(collAmount >= totalCollateralRequest, "!EnoughEth");
        } else {
            collAmount = totalCollateralRequest;
            allowance = IERC20(collateralToken).allowance(msg.sender, address(this));
            require(allowance >= totalCollateralRequest, "!allowance");
        }
        borrowers[msg.sender] = true;
        loanPair[loanId] = _pairId;
        loanBorrower[loanId] = msg.sender;
        loanBalance[loanId] = collAmount;
        loanParams[loanId].rpbRate = _rpbRate;
        loanAskAmount[loanId] = _borrowedAskAmount;
        loanParams[loanId].creationBlock = block.number;
        loanStatus[loanId] = Status.pending;
        emit CollateralReceived(loanId, _pairId, msg.sender, collAmount, uint(loanStatus[loanId]));
        loanId = loanId.add(1);
        if (collateralToken != address(0))
            TransferHelper.safeTransferFrom(collateralToken, msg.sender, address(this), totalCollateralRequest);
    }

    /**
    * @dev get loan id conuter
    * @return uint loan counter
    */
    function getLoansCounter() external override view returns (uint) {
        return loanId;
    }

    //// Utility functions
    /**
    * @dev set common parameters in loan contract, reading them from factory
    */
    function setNewGeneralLoansParams() external override onlyLoanFactory {
        generalLoansParams = IJFactory(generalLoansParams.factoryAddress).getGeneralParams();
    }

    /**
    * @dev set common parameters in loan contract, reading them from factory
    */
    function setNewFeesParams() external override onlyLoanFactory {
        loanFees = IJFactory(generalLoansParams.factoryAddress).getGeneralFees();
    }

    /**
    * @dev deposit collateral
    * @param _id loan id
    */
    function depositEthCollateral(uint _id) external override payable nonReentrant {
        require(getCollateralTokenAddress(loanPair[_id]) == address(0), "!ETHLoan");
        require(loanStatus[_id] <= Status.foreclosing, "!Status04");
        loanBalance[_id] = loanBalance[_id].add(msg.value);
        loanLastDepositBlock[_id] = block.number;
        uint status = setLoanStatusOnCollRatio(_id);
        emit CollateralReceived(_id, loanPair[_id], msg.sender, msg.value, status);
    }

    /**
    * @dev deposit collateral tokens
    * @param _id loan id
    * @param _tok ERC20 address
    * @param _amount token amount
    */
    function depositTokenCollateral(uint _id, address _tok, uint _amount) external override nonReentrant {
        address collateralToken = getCollateralTokenAddress(loanPair[_id]);
        require(collateralToken != address(0), "!TokenLoan");
        require(loanStatus[_id] <= Status.foreclosing, "!Status04");
        require(collateralToken == address(_tok), "!collToken" );
        uint allowance = IERC20(collateralToken).allowance(msg.sender, address(this));
        require(allowance >= _amount, "!allowance");
        loanBalance[_id] = loanBalance[_id].add(_amount);
        loanLastDepositBlock[_id] = block.number;
        uint status = setLoanStatusOnCollRatio(_id);
        emit CollateralReceived(_id, loanPair[_id], msg.sender, _amount, status);
        TransferHelper.safeTransferFrom(_tok, msg.sender, address(this), _amount);
    }

    /**
    * @dev withdraw ethers from contract
    * @param _id loan id
    * @param _amount eth amount
    */
    function withdrawCollateral(uint _id, uint _amount) external override nonReentrant {
        require(loanBorrower[_id] == msg.sender, "!borrower");
        uint status = setLoanStatusOnCollRatio(_id);
        require(status <= 1, "!Status01");
        uint withdrawalAmount = calcDiffCollAmountForRatio(_id, generalLoansParams.limitCollRatioForWithdraw);
        require(_amount <= withdrawalAmount, "TooMuch");
        loanBalance[_id] = loanBalance[_id].sub(_amount);
        loanLastWithdrawBlock[_id] = block.number;
        emit WithdrawCollateral(_id, _amount);
        address collateralToken = getCollateralTokenAddress(loanPair[_id]);
        if (collateralToken == address(0))
            TransferHelper.safeTransferETH(msg.sender, _amount);
        else
            TransferHelper.safeTransfer(collateralToken, msg.sender, _amount);
    }

    /**
    * @dev get contract overall balance about a token or eth
    * @param _id loan id
    * @return balance
    */
    function getContractBalance(uint _id) external override view returns (uint) {
        address collateralToken = getCollateralTokenAddress(loanPair[_id]);
        if (collateralToken == address(0))
            return address(this).balance;
        else
            return IERC20(collateralToken).balanceOf(address(this));
    }

    /**
    * @dev get single loan balance
    * @param _id loan id
    * @return uint balance of single loan
    */
    function getLoanBalance(uint _id) public override view returns (uint) {
        return loanBalance[_id];
    }   

    /**
    * @dev get single loan status
    * @param _id loan id
    * @return uint balance of single loan
    */
    function getLoanStatus(uint _id) external override view returns (uint) {
        return uint(loanStatus[_id]);
    }

    /**
    * @dev set single loan status
    * @param _id loan id
    * @param _newStatus new loan status
    */
    function setNewStatus(uint _id, uint _newStatus) external override onlyLoanFactory {
        loanStatus[_id] = IJLoanCommons.Status(_newStatus);
    }

    /**
    * @dev check if loan is in early settlement period
    * @param _id loan id
    * @return boolean
    */
    function checkLoanInEarlySettlementWindow(uint _id) external override view returns (bool) {
        uint lastEarlyBlock = loanActiveBlock[_id].add(generalLoansParams.earlySettlementWindow);
        if (block.number <= lastEarlyBlock)
            return true;
        else
            return false;
    }

    /**
    * @dev check if loan is in early settlement period
    * @param _id loan id
    * @return boolean
    */
    function checkEarlySettledLoan(uint _id) external override view returns (bool) {
        return loanStatus[_id] == Status.earlyClosing;
    }

    /**
    * @dev set initial collateral ratio of the loan
    * @param _id loan id
    */
    function setInitalCollateralRatio(uint _id) external override {
        if (loanStatus[_id] == Status.pending)
            loanParams[_id].initialCollateralRatio = getActualCollateralRatio(_id);
    }

    /**
    * @dev get the collateral ratio of the loan (subtracting the accrued interests)
    * @param _id loanId
    * @return newCollRatio collateral ratio
    */
    function getActualCollateralRatio(uint _id) public override view returns (uint newCollRatio) {
        uint borrAmnt = loanAskAmount[_id];
        uint loanBalanceId;
        if (loanStatus[_id] == Status.pending)
            loanBalanceId = getLoanBalance(_id);
        else
            loanBalanceId = getLoanBalance(_id).sub(getAccruedInterests(_id));
        newCollRatio = IJFactory(generalLoansParams.factoryAddress).getCollateralRatio(loanPair[_id], borrAmnt, loanBalanceId);
        return newCollRatio;
    }

    /**
    * @dev calc a new ratio if collateral amount has added to contract balance
    * @param _id loanId
    * @param _amount collateral amount to add
    * @param _adding bool, true if _amount is added, false if amount is removed to loan
    * @return ratio new collateral ratio, percentage with no decimals
    */
    function calcRatioAdjustingCollateral(uint _id, uint _amount, bool _adding) external override view returns (uint ratio) {
        uint borrAmnt = loanAskAmount[_id];
        uint loanBalanceId = getLoanBalance(_id);
        ratio = IJFactory(generalLoansParams.factoryAddress).collateralAdjustingRatio(loanPair[_id], borrAmnt, loanBalanceId, _amount, _adding);
        return ratio;
    }

    /**
    * @dev calc how much collateral amount has to be added to have a ratio
    * @param _id loanId
    * @param _ratio ratio to reach, percentage with no decimals (180 means 180%)
    * @return collDiff collateral amount to add or to subtract to reach that ratio
    */
    function calcDiffCollAmountForRatio(uint _id, uint _ratio) public override view returns (uint collDiff) {
        uint borrAmnt = loanAskAmount[_id];
        uint loanBalanceId = getLoanBalance(_id);
        collDiff = IJFactory(generalLoansParams.factoryAddress).ratioDiffCollAmount(loanPair[_id], _ratio, borrAmnt, loanBalanceId);
        return collDiff;
    }

    //// Status 0 -> 1
    /**
    * @dev lender sends required stable coins to borrower and set the initial lender as a stakeholder (100%)
    * @param _id loan id
    * @param _stableAddr, address of the stabl coin address
    */
    function lenderSendStableCoins(uint _id, address _stableAddr) external override nonReentrant {
        address collateralToken = getCollateralTokenAddress(loanPair[_id]);
        address lentToken = getLentTokenAddress(loanPair[_id]);
        require(_stableAddr == lentToken, "!TokenOk");
        require(loanStatus[_id] == Status.pending, "!Status0");
        uint actualRatio = getActualCollateralRatio(_id);
        require(actualRatio >= generalLoansParams.limitCollRatioForWithdraw, "!EnoughCollateral");
        uint allowance = IERC20(lentToken).allowance(msg.sender, address(this));
        require(allowance >= loanAskAmount[_id], "!allowance");
        shareholdersCounter[_id] = 1;
        loanShareholders[_id][shareholdersCounter[_id]] = Shareholder({holder: msg.sender, shares: 100, ownerBlockNumber: loanActiveBlock[_id]});
        loanShareholdersAddress[_id][msg.sender] = true;
        loanShareholdersPlace[_id][msg.sender] = shareholdersCounter[_id];
        loanStatus[_id] = Status.active;
        loanActiveBlock[_id] = block.number;
        lastInterestWithdrawalBlock[_id] = block.number;
        // move factory fees only when loan becomes active
        uint minCollateral = IJFactory(generalLoansParams.factoryAddress).calcMinCollateralAmount(loanPair[_id], loanAskAmount[_id]);
        uint fees4Factory = IJFactory(generalLoansParams.factoryAddress).calculateCollFeesOnActivation(minCollateral); // 5/1000 = 0,5%
        loanBalance[_id] = loanBalance[_id].sub(fees4Factory);
        emit LoanStatusChanged(_id, 0, uint(loanStatus[_id]), fees4Factory, 0);
        TransferHelper.safeTransferFrom(lentToken, msg.sender, loanBorrower[_id], loanAskAmount[_id]);
        if (collateralToken == address(0))
            TransferHelper.safeTransferETH(payable(feesCollector), fees4Factory);
        else
            TransferHelper.safeTransfer(collateralToken, feesCollector, fees4Factory);
    }

    //// Status 1 or 2 or 3 or 4, based on collateral ratio
    /**
    * @dev set the status of the loan based on collateral ratio, applied only in states allowed 
    * @param _id loan id
    * @return loan status
    */
    function setLoanStatusOnCollRatio(uint _id) public override returns (uint) {
        uint newCollRatio = getActualCollateralRatio(_id); // (i.e. 180 means 180%)
        uint oldStatus = uint(loanStatus[_id]);
        if (oldStatus > 0 && oldStatus < 4) {     //not allowed if loan not active or foreclosed or in closing status or closed
            if ( newCollRatio >= generalLoansParams.foreclosingRatio ) {
                loanStatus[_id] = Status(1);
                loanForeclosingBlock[_id] = 0;   //reset foreclosing block
            } else if ( newCollRatio <= generalLoansParams.foreclosingRatio && newCollRatio >= generalLoansParams.instantForeclosureRatio ) {
                loanStatus[_id] = Status(2);
            } else if ( newCollRatio < generalLoansParams.instantForeclosureRatio ) {
                loanStatus[_id] = Status(3);
            }  
        } else if (oldStatus == 4) {
            if ( newCollRatio >= generalLoansParams.foreclosingRatio ) {
                loanStatus[_id] = Status(1);
                loanForeclosingBlock[_id] = 0;   //reset foreclosing block
            }
        }
        // else no change on status
        emit LoanStatusChanged(_id, oldStatus, uint(loanStatus[_id]), 0, 0);
        return uint(loanStatus[_id]);
    }

    //// Status 4 or 5, starting from 2 or 3, depending on collateral ratio
    /**
    * @dev set the loan in foreclosure state for undercollateralized loans
    * @param _id loan id
    */
    function initiateLoanForeclose(uint _id) external override nonReentrant {
        uint status = setLoanStatusOnCollRatio(_id);
        require(status == 2 || status == 3, "!Status23");
        uint reward;
        if (status == 2) {
            reward = uint(loanFees.undercollateralizedForeclosingMultiple).mul(loanParams[_id].rpbRate);
            setLoanForeclosing(_id);
        } else {
            reward = uint(loanFees.atRiskForeclosedMultiple).mul(loanParams[_id].rpbRate);
            setLoanForeclosed(_id);
        }
        uint bal = loanBalance[_id];
        loanInitiateForecloseBlock[_id] = block.number;
        uint userReward;
        uint vaultReward;
        if (bal >= reward) {
            userReward = reward.mul(loanFees.userRewardShare).div(100);
            vaultReward = reward.mul(loanFees.vaultRewardShare).div(100);
        } else {
            userReward = bal.mul(loanFees.userRewardShare).div(100);
            vaultReward = bal.sub(userReward);
            setLoanClosed(_id);
        }
        loanBalance[_id] = loanBalance[_id].sub(userReward).sub(vaultReward);
        emit LoanStatusChanged(_id, status, uint(loanStatus[_id]), vaultReward, userReward);
        address collateralToken = getCollateralTokenAddress(loanPair[_id]);
        if (collateralToken == address(0)) {
            TransferHelper.safeTransferETH(msg.sender, userReward);
            TransferHelper.safeTransferETH(payable(feesCollector), vaultReward);
        } else {
            TransferHelper.safeTransfer(collateralToken, msg.sender, userReward);
            TransferHelper.safeTransfer(collateralToken, feesCollector, vaultReward);
        }
    }

    //// Status 2 -> 4
    /**
    * @dev set the loan in foreclosure state for undercollateralized loans
    * @param _id loan id
    */
    function setLoanForeclosing(uint _id) internal {
        loanStatus[_id] = Status.foreclosing;
        // get the block to calculate time to set it in foreclosed if no actions from the borrower
        loanForeclosingBlock[_id] = block.number;
    }

    /**
    * @dev set the loan in foreclosed state when foreclosureWindow time passed or collateral ratio is at risk
    * @param _id loan id
    * @return bool 
    */
    function setLoanToForeclosed(uint _id) external override nonReentrant returns (bool) {
        require(uint(loanStatus[_id]) == 4, "!Status4");
        bool result = false;
        if (loanForeclosingBlock[_id] != 0) {
            uint newCollRatio = getActualCollateralRatio(_id);
            uint reward = uint(loanFees.atRiskForeclosedMultiple).mul(loanParams[_id].rpbRate);
            uint bal = loanBalance[_id];
            uint userReward;
            uint vaultReward;
            if ( newCollRatio < generalLoansParams.instantForeclosureRatio || block.number >= loanForeclosingBlock[_id].add(generalLoansParams.foreclosureWindow) ) {
                if (bal >= reward) {
                    userReward = reward.mul(loanFees.userRewardShare).div(100);
                    vaultReward = reward.mul(loanFees.vaultRewardShare).div(100);
                    setLoanForeclosed(_id);
                } else {
                    userReward = bal.mul(loanFees.userRewardShare).div(100);
                    vaultReward = bal.sub(userReward);
                    setLoanClosed(_id);
                }
                loanBalance[_id] = loanBalance[_id].sub(userReward).sub(vaultReward);
                result = true;
                emit LoanStatusChanged(_id, 4, uint(loanStatus[_id]), vaultReward, userReward);
                address collateralToken = getCollateralTokenAddress(loanPair[_id]);
                if (collateralToken == address(0)) {
                    TransferHelper.safeTransferETH(msg.sender, userReward);
                    TransferHelper.safeTransferETH(payable(feesCollector), vaultReward);
                } else {
                    TransferHelper.safeTransfer(collateralToken, msg.sender, userReward);
                    TransferHelper.safeTransfer(collateralToken, feesCollector, vaultReward);
                }
            }
        }
        return result;
    }

    //// Status 2 -> 5
    /**
    * @dev set the loan in foreclosure state for undercollateralized loans
    * @param _id loan id
    */
    function setLoanForeclosed(uint _id) internal {
        loanForeclosedBlock[_id] = block.number;
        loanStatus[_id] = Status.foreclosed;
    }

    //// Status = 6
    /**
    * @dev set the loan in early closing state
    * @param _id loan id
    * @return uint requested balance
    */
    function loanEarlyClosing(uint _id) internal returns (uint) {
        loanStatus[_id] = Status.earlyClosing;
        uint remainingBlock = generalLoansParams.earlySettlementWindow;
        uint blockAlreadyUsed = 0;
        if (lastInterestWithdrawalBlock[_id] != 0) {
            blockAlreadyUsed = lastInterestWithdrawalBlock[_id].sub(loanActiveBlock[_id]);
            remainingBlock = (generalLoansParams.earlySettlementWindow).sub(blockAlreadyUsed);
        }
        uint balanceRequested = ( remainingBlock.sub(blockAlreadyUsed) ).mul(loanParams[_id].rpbRate);
        return balanceRequested;
    }

    //// Status = 7
    /**
    * @dev settle the loan in normal closing state by borrower
    * @param _id loan id
    */
    function loanClosingByBorrower(uint _id) external override nonReentrant {
        require(loanBorrower[_id] == msg.sender, "!borrower");
        uint status = setLoanStatusOnCollRatio(_id);
        require(status > 0 && status <= 3, "!Status13");
        // check that borrower gives back the loaned stable coin amount and transfer collateral to borrower
        address lentToken = getLentTokenAddress(loanPair[_id]);
        address collateralToken = getCollateralTokenAddress(loanPair[_id]);
        uint allowance = IERC20(lentToken).allowance(msg.sender, address(this));
        require(allowance >= loanAskAmount[_id], "!allowanceSettle");
        uint balanceRequested;
        if (block.number < loanActiveBlock[_id] + generalLoansParams.earlySettlementWindow)
            balanceRequested = loanEarlyClosing(_id);
        else
            balanceRequested = getAccruedInterests(_id);
        uint feesAmount = 0;
        if (loanStatus[_id] == Status.earlyClosing) 
            feesAmount = (loanFees.earlySettlementFee).mul(loanParams[_id].rpbRate);
        
        uint bal = loanBalance[_id];
        uint requestedAmount = balanceRequested.add(feesAmount);
        loanClosingBlock[_id] = block.number;
        loanStatus[_id] = Status.closing;
        uint withdrawalBalance = 0;
        // check if there are enough collateral
        if (bal >= requestedAmount) {
            // borrower receives back collateral
            withdrawalBalance = bal.sub(requestedAmount); 
        }
        borrowerSendBackLentToken(_id);
        loanBalance[_id] = loanBalance[_id].sub(withdrawalBalance).sub(feesAmount);
        emit LoanStatusChanged(_id, status, uint(loanStatus[_id]), feesAmount, withdrawalBalance);
        if (collateralToken == address(0)) {
            TransferHelper.safeTransferETH(msg.sender, withdrawalBalance);
            TransferHelper.safeTransferETH(payable(feesCollector), feesAmount);
        } else {
            TransferHelper.safeTransfer(collateralToken, msg.sender, withdrawalBalance);
            TransferHelper.safeTransfer(collateralToken, feesCollector, feesAmount);
        }
    }

    /**
    * @dev internal function to allow borrower to send back lent tokens to shareholders
    * @param _id loan id
    */
    function borrowerSendBackLentToken(uint _id) internal {
        address lentToken = getLentTokenAddress(loanPair[_id]);
        uint loanAmount = loanAskAmount[_id];
        for (uint8 i = 1; i <= shareholdersCounter[_id]; i++) {
            address shAddress = loanShareholders[_id][i].holder;
            uint shPlace = getShareholderPlace(_id, loanShareholders[_id][i].holder);
            uint shShares = loanShareholders[_id][shPlace].shares;
            uint shAmount = loanAmount.mul(shShares).div(100);
            TransferHelper.safeTransferFrom(lentToken, msg.sender, shAddress, shAmount);
        }
    }

    //// Status = 8
    /**
    * @dev set the loan in closed state, let shareholders to withdraw the stable coins back
    * @param _id loan id
    */
    function setLoanClosed(uint _id) internal {
        loanClosedBlock[_id] = block.number;
        loanStatus[_id] = Status.closed;
    }

    //// Status = 9
    /**
    * @dev set the loan in cancelled state (only if pending)
    * @param _id loan id
    */
    function setLoanCancelled(uint _id) external override nonReentrant {
        require(loanBorrower[_id] == msg.sender, "!borrower");
        require(uint(loanStatus[_id]) == 0, "!Status0");
        uint bal = loanBalance[_id];
        uint feeCanc = bal.mul(loanFees.cancellationFees).div(100);
        uint withdrawalBalance = bal.sub(feeCanc);
        loanStatus[_id] = Status.cancelled;
        loanBalance[_id] = loanBalance[_id].sub(withdrawalBalance).sub(feeCanc);
        emit LoanStatusChanged(_id, 0, uint(loanStatus[_id]), feeCanc, withdrawalBalance);
        address collateralToken = getCollateralTokenAddress(loanPair[_id]);
        if (collateralToken == address(0)) {
            TransferHelper.safeTransferETH(payable(feesCollector), feeCanc);
            TransferHelper.safeTransferETH(msg.sender, withdrawalBalance);
        } else {
            TransferHelper.safeTransfer(collateralToken, feesCollector, feeCanc);
            TransferHelper.safeTransfer(collateralToken, msg.sender, withdrawalBalance);
        }
    }


    //// Calculating interests functions
    /**
    * @dev calculate accrued interests of the contract
    * @param _id loan id
    * @param _calcBlk block number
    * @return uint accrued interests
    */
    function calculatingAccruedInterests(uint _id, uint _calcBlk) public override view returns (uint) {
        require(_calcBlk >= lastInterestWithdrawalBlock[_id], "!validBlockNumber");
        return _calcBlk.sub(lastInterestWithdrawalBlock[_id]).mul(loanParams[_id].rpbRate);  
    }

    /**
    * @dev get accrued interests of the contract
    * @param _id loan id
    * @return accruedInterests total accrued interests
    */
    function getAccruedInterests(uint _id) public override view returns (uint accruedInterests) {
        if (uint(loanStatus[_id]) > 0 && uint(loanStatus[_id]) < 8) {
            uint lastEarlyBlock = loanActiveBlock[_id].add(generalLoansParams.earlySettlementWindow);
            if (loanStatus[_id] == Status.earlyClosing && block.number <= lastEarlyBlock) {
                accruedInterests = calculatingAccruedInterests(_id, lastEarlyBlock);
            } else {
                if (loanClosedBlock[_id] != 0)
                    accruedInterests = calculatingAccruedInterests(_id, Math.min(loanClosedBlock[_id], block.number));
                else
                    accruedInterests = calculatingAccruedInterests(_id, block.number);
            }
            if ( accruedInterests > loanBalance[_id] )
                accruedInterests = loanBalance[_id];
        } else 
            accruedInterests = 0;
        return accruedInterests;
    }

    /**
    * @dev withdraw accreud interests for all shareholders and set the status after interests withdrawal
    * @param _id loan id
    * @return uint new status
    */
    function withdrawInterests(uint _id) public override nonReentrant returns (uint) {
        // interests of all shareholders must be withdrawn with their shares amount
        require(uint(loanStatus[_id]) > 0 && uint(loanStatus[_id]) < 8, "!Status17" );
        uint status = uint(loanStatus[_id]);
        uint bal = loanBalance[_id];
        uint accruedTotalInterests = getAccruedInterests(_id);
        if (bal >= accruedTotalInterests) {
            for (uint8 i = 1; i <= shareholdersCounter[_id]; i++) {
                shareholderWithdrawInterests(_id, loanShareholders[_id][i].holder, accruedTotalInterests);
            }
            lastInterestWithdrawalBlock[_id] = block.number;
            if (status <= 4)
                status = setLoanStatusOnCollRatio(_id);
        } else if (bal == 0 && isShareholder(_id, msg.sender)) {
            setLoanClosed(_id);
        } else {
            for (uint8 i = 1; i <= shareholdersCounter[_id]; i++) {
                shareholderWithdrawInterests(_id, loanShareholders[_id][i].holder, bal);
            }
            lastInterestWithdrawalBlock[_id] = block.number;
            loanClosedBlock[_id] = block.number;
            loanStatus[_id] = Status.closed;
            status = uint(loanStatus[_id]);
        }
        emit InterestsWithdrawed(_id, accruedTotalInterests);
        return status;
    }

    /**
    * @dev withdraw accreud interests for a bunch of loans for all shareholders and set the status after interests withdrawal
    * @param _id loan id array
    * @return success
    */
    function withdrawInterestsMassive(uint[] memory _id) external override returns (bool success) {
        require(_id.length <= 100, "TooMuchLoans");
        require(!fLock, "Locked");
        fLock = true;
        for (uint8 j = 0; j < _id.length; j++) {
            uint presentId = _id[j];
            withdrawInterests(presentId);
        }
        fLock = false;
        return true;
    }

    //// shareholders functions
    /**
    * @dev withdraw accreud interests for a shareholder
    * @param _id loan id
    * @param _shareholder shareholder address
    * @param _accruedTotalInterests accrued total interests
    */
    function shareholderWithdrawInterests(uint _id, address _shareholder, uint _accruedTotalInterests) internal {
        require(isShareholder(_id, _shareholder), "!shareholder"); 
        uint shPlace = getShareholderPlace(_id, _shareholder);
        uint shShares = loanShareholders[_id][shPlace].shares;
        uint interestsToSend = _accruedTotalInterests.mul(shShares).div(100);
        loanBalance[_id] = loanBalance[_id].sub(interestsToSend);
        address collateralToken = getCollateralTokenAddress(loanPair[_id]);
        if (collateralToken == address(0))
            TransferHelper.safeTransferETH(payable(_shareholder), interestsToSend);
        else
            TransferHelper.safeTransfer(collateralToken, _shareholder, interestsToSend);
    }

    /**
    * @dev check if an address is a shareholder
    * @param _id loan id
    * @param _holder shareholder address
    * @return bool
    */
    function isShareholder(uint _id, address _holder) public override view returns (bool) {
        return loanShareholdersAddress[_id][_holder];
    }

    /**
    * @dev get a shareholder place in shareholders array
    * @param _id loan id
    * @param _holder shareholder address
    * @return uint shareholder place
    */
    function getShareholderPlace(uint _id, address _holder) public override view returns (uint) {
        return loanShareholdersPlace[_id][_holder];
    }

    /**
    * @dev add shareholder in shareholders arrays
    * @param _id loan id
    * @param _newShareholder buyer address
    * @param _amount amount of shares
    * @return uint new status
    */
    function addLoanShareholders(uint _id, address _newShareholder, uint _amount) public override nonReentrant returns (uint) {
        require(isShareholder(_id, msg.sender), "!shareholder");
        uint shPlace = getShareholderPlace(_id, msg.sender);
        require(shPlace > 0, "!shPlace");
        require(loanShareholders[_id][shPlace].shares >= _amount, "!enoughShares");
        //before shares could be selled, interests of all shareholders must be withdrawn with old shares amount, in order to start with a new situation
        //require(block.number > loanActiveBlock[_id] + generalLoansParams.earlySettlementWindow, "earlyWindow");
        uint interestsAmount = getAccruedInterests(_id);
        for (uint8 i = 1; i <= shareholdersCounter[_id]; i++) {
            shareholderWithdrawInterests(_id, loanShareholders[_id][i].holder, interestsAmount);
        }
        loanShareholders[_id][shPlace].shares = loanShareholders[_id][shPlace].shares.sub(_amount);
        if(!isShareholder(_id, _newShareholder)) {
            shareholdersCounter[_id] = shareholdersCounter[_id].add(1);
            loanShareholders[_id][shareholdersCounter[_id]] = Shareholder({holder: _newShareholder, shares: _amount, ownerBlockNumber: block.number});
            loanShareholdersAddress[_id][_newShareholder] = true;
            loanShareholdersPlace[_id][_newShareholder] = shareholdersCounter[_id];
        } else {
            uint shPlaceNew = getShareholderPlace(_id, _newShareholder);
            loanShareholders[_id][shPlaceNew].shares = loanShareholders[_id][shPlaceNew].shares.add(_amount);
            loanShareholders[_id][shPlaceNew].ownerBlockNumber = block.number;
            emit AddShareholderShares(_id, _newShareholder, _amount);
        }
        lastInterestWithdrawalBlock[_id] = block.number;
        uint status = setLoanStatusOnCollRatio(_id);
        return status;
    }

    /**
    * @dev add shareholder in shareholders arrays in massive mode
    * @param _id loan id
    * @param _newShareholder buyer address array
    * @param _amount amount of shares array
    * @return success boolean
    */
    function addLoanShareholdersMassive(uint _id, address[] memory _newShareholder, uint[] memory _amount) external override returns (bool success) {
        require(_newShareholder.length <= 100, "TooMuchShareholders");
        require(_newShareholder.length == _amount.length, "!sameLength");
        require(!fLock, "Locked");
        fLock = true;
        for (uint8 j = 0; j < _newShareholder.length; j++) {
            address presentSH = _newShareholder[j];
            uint presentAmnt = _amount[j];
            addLoanShareholders(_id, presentSH, presentAmnt);
        }
        fLock = false;
        return true;
    }

}


interface IJLoanDeployer {
    function setLoanFactory(address _factAddr) external;
    function deployNewLoanContract(address _factAddr) external returns (address);
    function setFeesCollector(address _feeColl) external;
    function getFeesCollector() external view returns(address);
}


contract JLoanDeployer is Ownable, IJLoanDeployer {
    address private feesCollector;

    IJLoanCommons.GeneralParams public loanParams;

    constructor() public { }

    modifier onlyLoanFactory() {
        require(msg.sender == loanParams.factoryAddress, "!factory");
        _;
    }

    /**
    * @dev set loan factory contract address
    * @param _factAddr, address of loan factory contract to add
    */
    function setLoanFactory(address _factAddr) external override onlyOwner {
        loanParams.factoryAddress = _factAddr;
    }

     /**
    * @dev deploy a new eth loan contract, add its address to internal variables
    * @param _factAddr, factory address
    * @return address of new pair contract
    */              
    function deployNewLoanContract(address _factAddr) external override onlyLoanFactory returns (address) {
        address newLoanContract = address(new JLoan(_factAddr, feesCollector));
        return newLoanContract;
    }

    /**
    * @dev set the fee collector contract address
    * @param _feeColl fees collectro address
    */
    function setFeesCollector(address _feeColl) external override onlyOwner {
        feesCollector = _feeColl;
    }

    /**
    * @dev get the fee collector contract address
    * @return fee collector address
    */
    function getFeesCollector() external override view returns(address) {
        return feesCollector;
    }

}
