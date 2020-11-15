// SPDX-License-Identifier: MIT
/**
 * Created on 2020-11-09
 * @summary: Jibrel Loans Factory
 * @author: Jibrel Team
 */
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

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


interface IJLoanDeployer {
    function setLoanFactory(address _factAddr) external;
    function deployNewLoanContract(address _factAddr) external returns (address);
    function setFeesCollector(address _feeColl) external;
    function getFeesCollector() external view returns(address);
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


contract JFactory is Ownable, ReentrancyGuard, IJLoanCommons, IJFactory { 
    using SafeMath for uint256;

    IJLoanDeployer public loanDeplContract;
    IJPriceOracle public priceOracleContract;

    mapping(uint => address) internal deployedLoans;
    uint public loanCounter;

    mapping (address => bool) private _Admins;
 
    uint public pairNumber;

    GeneralParams public generalParams;
    FeesParams public generalFees;

    uint public factoryDeployBlock;

    event AdminAdded(address account);
    event AdminRemoved(address account);
    event NewLoanContractCreated(address indexed newLoan, uint counter);
    event SetNewStatus(uint idx, uint loanId, uint oldStatus, uint newStatus);
    
    constructor(address _loanDepl, address _priceOracle) public {
        generalParams.earlySettlementWindow = 540000;
        generalParams.foreclosureWindow = 18000;
        generalParams.requiredCollateralRatio = 200;
        generalParams.foreclosingRatio = 150;
        generalParams.instantForeclosureRatio = 120;
        generalParams.limitCollRatioForWithdraw = 160;
        generalParams.loanDeployerAddress = _loanDepl;
        loanDeplContract = IJLoanDeployer(_loanDepl);
        generalParams.priceOracleAddress = _priceOracle;
        priceOracleContract = IJPriceOracle(_priceOracle);
        generalParams.factoryAddress = address(this);
        generalFees.factoryFees = 5;
        generalFees.earlySettlementFee = 1080000; 
        generalFees.userRewardShare = 80;
        generalFees.vaultRewardShare = 20;
        generalFees.undercollateralizedForeclosingMultiple = 1000;
        generalFees.atRiskForeclosedMultiple = 3000;
        generalFees.cancellationFees = 3;
        _Admins[msg.sender] = true;
        factoryDeployBlock = block.number;
    }

    /* Modifiers */
    modifier onlyAdmins() {
        require(isAdmin(msg.sender), "Not an Admin!");
        _;
    }

    /*   Admins Roles Mngmt  */
    function _addAdmin(address account) internal {
        _Admins[account] = true;
        emit AdminAdded(account);
    }

    function _removeAdmin(address account) internal {
        _Admins[account] = false;
        emit AdminRemoved(account);
    }

    function isAdmin(address account) public override view returns (bool) {
        return _Admins[account];
    }

    function addAdmin(address account) external override onlyAdmins {
        require(account != address(0), "Not a valid address!");
        require(!isAdmin(account), " Address already Administrator");
        _addAdmin(account);
    }

    function removeAdmin(address account) external override onlyAdmins {
        _removeAdmin(account);
    }

    function renounceAdmin() external override onlyAdmins {
        _removeAdmin(msg.sender);
    }

    /**
    * @dev set a new address for pair loan deployer contract
    * @param _loanDepl new address
    */
    function setLoanDeployerAddress(address _loanDepl) external override onlyAdmins {
        require(_loanDepl != generalParams.loanDeployerAddress, "new address is the same as the old one");
        generalParams.loanDeployerAddress = _loanDepl;
        loanDeplContract = IJLoanDeployer(_loanDepl);
    }

    /**
    * @dev set a new address for pair price oracle contract
    * @param _priceOracle new address
    */
    function setPriceOracleAddress(address _priceOracle) external override onlyAdmins {
        require(_priceOracle != generalParams.priceOracleAddress, "new address is the same as the old one");
        generalParams.priceOracleAddress = _priceOracle;
        priceOracleContract = IJPriceOracle(_priceOracle);
    }

    /**
    * @dev math round up
    * @param numerator numerator
    * @param denominator denominator
    * @param precision precision
    * @return number of quote currency decimals
    */
    function roundUp(uint numerator, uint denominator, uint precision) internal pure returns (uint) {
        uint _numerator  = numerator.mul(10 ** (precision.add(1)));
        uint _quotient =  ((_numerator.div(denominator)).add(5)).div(10);
        return _quotient;
    }

    /**
    * @dev calculate fees on collateral amount
    * @param _collAmount collateral amount
    * @return amount of collateral fees
    */
    function calculateCollFeesOnActivation(uint _collAmount) public override view returns (uint) {
        return roundUp(_collAmount.mul(generalFees.factoryFees), 1000, 0);
    }

    /**
    * @dev get the amount of collateral needed to have stable coin amount (no fees)
    * @param _pairId number of the pair
    * @param _askAmount amount in stable coin the borrower would like to receive
    * @return amount of collateral the borrower needs to send
    */
    function calcMinCollateralAmount(uint _pairId, uint _askAmount) public override view returns (uint) {
        uint price = priceOracleContract.getPairValue(_pairId);
        uint pairDecimals = uint(priceOracleContract.getPairDecimals(_pairId));
        uint minCollEthAmount = roundUp(_askAmount.mul(generalParams.requiredCollateralRatio).mul(10 ** pairDecimals).div(100), price, 0);
        uint baseDecimals = uint(priceOracleContract.getPairBaseDecimals(_pairId));
        uint quoteDecimals = uint(priceOracleContract.getPairQuoteDecimals(_pairId));
        if (baseDecimals >= quoteDecimals) {
            uint diffBaseQuoteDecimals = baseDecimals.sub(quoteDecimals);
            minCollEthAmount = minCollEthAmount.mul(10 ** diffBaseQuoteDecimals).add(5); //add 5 to be sure evrything is ok
        } else {
            uint diffBaseQuoteDecimals = quoteDecimals.sub(baseDecimals);
            minCollEthAmount = minCollEthAmount.div(10 ** diffBaseQuoteDecimals).add(5); //add 5 to be sure evrything is ok
        }
        return minCollEthAmount;
    }

    /**
    * @dev get the amount of collateral needed to have stable coin amount, with fees
    * @param _pairId number of the pair
    * @param _askAmount amount in stable coin the borrower would like to receive
    * @return amount of collateral the borrower needs to send
    */
    function calcMinCollateralWithFeesAmount(uint _pairId, uint _askAmount) external override view returns (uint) {
        uint minCollEthAmount = calcMinCollateralAmount(_pairId, _askAmount);
        uint feesCollAmount = calculateCollFeesOnActivation(minCollEthAmount);
        uint totalCollAmountWithFees = minCollEthAmount.add(feesCollAmount);
        return totalCollAmountWithFees;
    }

    /**
    * @dev set GeneralParams
    * @param _value set new param
    */
    function setEarlySettlementWindow(uint _value) external override onlyOwner {
        generalParams.earlySettlementWindow = _value;
    }

    /**
    * @dev set GeneralParams
    * @param _value set new param
    */
    function setForeclosureWindow(uint _value) external override onlyOwner {
        generalParams.foreclosureWindow = _value;
    }

    function setForeclosureRatio(uint8 _value) external override onlyOwner {
        generalParams.foreclosingRatio = _value;
    }

    /**
    * @dev set GeneralParams
    * @param _value set new param
    */
    function setInstantForeclosureRatio(uint8 _value) external override onlyOwner {
        generalParams.instantForeclosureRatio = _value;
    }

    /**
    * @dev set GeneralParams
    * @param _value set new param
    */
    function setRequiredCollateralRatio(uint8 _value) external override onlyOwner {
        generalParams.requiredCollateralRatio = _value;
    }

    /**
    * @dev set GeneralParams
    * @param _value set new param
    */
    function setFactoryFees(uint8 _value) external override onlyOwner {
        generalFees.factoryFees = _value;
    }

    /**
    * @dev set GeneralParams
    * @param _value set new param
    */
    function setEarlySettlementFee(uint _value) external override onlyOwner {
        generalFees.earlySettlementFee = _value;
    }

    /**
    * @dev set GeneralParams
    * @param _value set new param
    */
    function setUserRewardShare(uint8 _value) external override onlyOwner {
        generalFees.userRewardShare = _value;
    }

    /**
    * @dev set GeneralParams
    * @param _value set new param
    */
    function setVaultShares(uint8 _value) external override onlyOwner {
        generalFees.vaultRewardShare = _value;
    }

    /**
    * @dev set GeneralParams
    * @param _value set new param
    */
    function setUndercollateralizedForeclosingMultiple(uint16 _value) external override onlyOwner {
        generalFees.undercollateralizedForeclosingMultiple = _value;
    }

    /**
    * @dev set GeneralParams
    * @param _value set new param
    */
    function setAtRiskForeclosedMultiple(uint16 _value) external override onlyOwner {
        generalFees.atRiskForeclosedMultiple = _value;
    }

    /**
    * @dev set GeneralParams
    * @param _value set new param
    */
    function setCancellationFees(uint8 _value) external override onlyOwner {
        generalFees.cancellationFees = _value;
    }

    /**
    * @dev get all general GeneralParams
    * @return param struct
    */
    function getGeneralParams() external override view returns (GeneralParams memory) {
        return generalParams;
    }

    /**
    * @dev get all general GeneralParams
    * @return param struct
    */
    function getGeneralFees() external override view returns (FeesParams memory) {
        return generalFees;
    }

    /**
    * @dev create a new loan contract and set the address in the mapping
    * @return address of the new contract
    */
    function createNewLoanContract() external override nonReentrant onlyAdmins returns (address) {
        address newTokenLoan = loanDeplContract.deployNewLoanContract(address(this));
        deployedLoans[loanCounter] = newTokenLoan;
        emit NewLoanContractCreated(newTokenLoan, loanCounter);
        loanCounter = loanCounter.add(1);
        return newTokenLoan;
    }

    /**
    * @dev get all deployers addresses
    * @return addresses of the deployer
    */
    function getLoanDeployer() external override view returns(address) {
        return address(loanDeplContract);
    }

    /**
    * @dev get a single loan address deployed by the factory
    * @param _idx deployed loan index
    * @return loan contract address
    */
    function getDeployedLoan(uint _idx) external override view returns (address) {
        return deployedLoans[_idx];
    }

        /**
    * @dev set new common GeneralParams in single eth loans contract
    * @param _idx, index of the loan pair contract
    */
    function setLoanGeneralParamsInContract(uint _idx) external override onlyOwner {
        IJLoan(deployedLoans[_idx]).setNewGeneralLoansParams();
    }

    /**
    * @dev set new fees GeneralParams in single eth loans contract
    * @param _idx, index of the loan pair contract
    */
    function setLoanFeesParamsInContract(uint _idx) external override onlyOwner {
        IJLoan(deployedLoans[_idx]).setNewFeesParams();
    }

        /**
    * @dev set new status in single eth loans contract
    * @param _idx, index of the loan contract
    * @param _loanId loan id
    * @param _newStatus, new status
    */
    function setStatusInLoan (uint _idx, uint _loanId, uint _newStatus) external override nonReentrant onlyOwner {
        require(_newStatus <= 7, "!Status07");
        IJLoan jContract = IJLoan(deployedLoans[_idx]);
        uint oldStatus = jContract.getLoanStatus(_loanId);
        require(_newStatus != oldStatus, "!newStatus");
        jContract.setNewStatus(_loanId, _newStatus);
        uint newStatus = jContract.getLoanStatus(_loanId);
        emit SetNewStatus(_idx, _loanId, oldStatus, newStatus);
    }

    /**
    * @dev adjust for decimals in tokens pair for ratio
    * @param _pairId pair Id
    * @param _numerator numerator
    * @param _quotient quotient
    * @return result of operation
    */
    function adjustDecimalsRatio(uint _pairId, uint _numerator, uint _quotient) internal view returns (uint result) {
        uint collDecimals = uint(priceOracleContract.getPairBaseDecimals(_pairId));
        uint lendDecimals = uint(priceOracleContract.getPairQuoteDecimals(_pairId));
        if (collDecimals >= lendDecimals) {
            uint diffBaseQuoteDecimals = collDecimals.sub(lendDecimals);
            result = _numerator.mul(10 ** diffBaseQuoteDecimals).div(_quotient);
        } else {
            uint diffBaseQuoteDecimals = lendDecimals.sub(collDecimals);
            result = _numerator.div(_quotient).div(10 ** diffBaseQuoteDecimals);
        }
        return result;
    }

    /**
    * @dev adjust for decimals in tokens pair for collateral
    * @param _pairId pair Id
    * @param _numerator numerator
    * @param _quotient quotient
    * @return result of operation
    */
    function adjustDecimalsCollateral(uint _pairId, uint _numerator, uint _quotient) public override view returns (uint result) {
        uint collDecimals = uint(priceOracleContract.getPairBaseDecimals(_pairId));
        uint lendDecimals = uint(priceOracleContract.getPairQuoteDecimals(_pairId));
        if (collDecimals >= lendDecimals) {
            uint diffBaseQuoteDecimals = collDecimals.sub(lendDecimals);
            result = _numerator.div(_quotient).div(10 ** diffBaseQuoteDecimals);
        } else {
            uint diffBaseQuoteDecimals = lendDecimals.sub(collDecimals);
            result = _numerator.mul(10 ** diffBaseQuoteDecimals).div(_quotient);
        }
        return result;
    }

    /**
    * @dev calc how much collateral amount has to be added to have a ratio
    * @param _pairId pair Id
    * @param _ratio ratio to reach, percentage with no decimals (180 means 180%)
    * @param _borrAmount borrowed amount
    * @param _balance laon balance
    * @return collDiff collateral amount to add or to subtract to reach that ratio
    */
    function ratioDiffCollAmount(uint _pairId, uint _ratio, uint _borrAmount, uint _balance) external override view returns (uint collDiff) {
        uint price = priceOracleContract.getPairValue(_pairId);
        uint pairDecimals = uint(priceOracleContract.getPairDecimals(_pairId));
        uint numerator = _borrAmount.mul(_ratio).mul(10 ** pairDecimals);
        uint quotient = price.mul(100);
        uint newBal = adjustDecimalsRatio(_pairId, numerator, quotient);
        if (newBal >= _balance)
            collDiff = newBal.sub(_balance);
        else
            collDiff = _balance.sub(newBal);
        return collDiff;
    }

    /**
    * @dev calc a new ratio if collateral amount has added to contract balance
    * @param _pairId pair Id
    * @param _borrAmount borrowed amount
    * @param _balance laon balance
    * @param _newAmount collateral amount to add
    * @param _adding bool, true if _newAmount is added, false if _newAmount is removed to loan
    * @return ratio new collateral ratio, percentage with no decimals
    */
    function collateralAdjustingRatio(uint _pairId, uint _borrAmount, uint _balance, uint _newAmount, bool _adding) external override view returns (uint ratio) {
        uint actualPrice = priceOracleContract.getPairValue(_pairId);
        uint pairDecimals = uint(priceOracleContract.getPairDecimals(_pairId));
        uint newLoanBal;
        if (_adding)
            newLoanBal = _balance.add(_newAmount);
        else {
            if (_newAmount < _balance)
                newLoanBal = _balance.sub(_newAmount);
            else 
                return 0;
        }
        uint numerator = newLoanBal.mul(actualPrice).mul(100);
        uint quotient = _borrAmount.mul(10 ** pairDecimals);
        ratio = adjustDecimalsCollateral(_pairId, numerator, quotient);
        return ratio;
    }

    /**
    * @dev get the collateral ratio of the loan (subtracting the accrued interests)
    * @param _pairId pair Id
    * @param _borrAmount borrowed amount
    * @param _balance laon balance
    * @return newCollRatio collateral ratio
    */
    function getCollateralRatio(uint _pairId, uint _borrAmount, uint _balance) external override view returns (uint newCollRatio) {
        uint newPrice = priceOracleContract.getPairValue(_pairId);
        uint pairDecimals = uint(priceOracleContract.getPairDecimals(_pairId));
        uint numerator = _balance.mul(newPrice).mul(100);
        uint quotient = _borrAmount.mul(10 ** pairDecimals);
        newCollRatio = adjustDecimalsCollateral(_pairId, numerator, quotient);
        return newCollRatio;
    }
    
}
