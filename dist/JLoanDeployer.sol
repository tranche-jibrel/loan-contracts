
pragma solidity ^0.6.0;

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
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
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
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
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
     * https://github.com/ethereum/EIPs/issues/20
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
 * @title Initializable
 *
 * @dev Helper contract to support initializer functions. To use it, replace
 * the constructor with a function that has the `initializer` modifier.
 * WARNING: Unlike constructors, initializer functions must be manually
 * invoked. This applies both to deploying an Initializable contract, as well
 * as extending an Initializable contract via inheritance.
 * WARNING: When used with inheritance, manual care must be taken to not invoke
 * a parent initializer twice, or ensure that all initializers are idempotent,
 * because this is not dealt with automatically as with constructors.
 */
contract Initializable {

  /**
   * @dev Indicates that the contract has been initialized.
   */
  bool private initialized;

  /**
   * @dev Indicates that the contract is in the process of being initialized.
   */
  bool private initializing;

  /**
   * @dev Modifier to use in the initializer function of a contract.
   */
  modifier initializer() {
    require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

    bool isTopLevelCall = !initializing;
    if (isTopLevelCall) {
      initializing = true;
      initialized = true;
    }

    _;

    if (isTopLevelCall) {
      initializing = false;
    }
  }

  /// @dev Returns true if and only if the function is running in the constructor
  function isConstructor() private view returns (bool) {
    // extcodesize checks the size of the code stored in an address, and
    // address returns the current address. Since the code is still not
    // deployed when running a constructor, any checks on its code size will
    // yield zero, making it an effective way to detect if a contract is
    // under construction or not.
    address self = address(this);
    uint256 cs;
    assembly { cs := extcodesize(self) }
    return cs == 0;
  }

  // Reserved storage space to allow for layout changes in the future.
  uint256[50] private ______gap;
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
contract ContextUpgradeSafe is Initializable {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.

    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {


    }


    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }

    uint256[50] private __gap;
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
contract OwnableUpgradeSafe is Initializable, ContextUpgradeSafe {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */

    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {


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

    uint256[49] private __gap;
}


// SPDX-License-Identifier: MIT

// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
library TransferHelper {
    function safeApprove(address token, address to, uint256 value) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TH APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint256 value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TH TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint256 value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TH TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint256 value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TH ETH_TRANSFER_FAILED');
    }
}


/**
 * Created on 2020-11-09
 * @summary: JPriceOracle Interface
 * @author: Jibrel Team
 */

interface IJPriceOracle {
    function isAdmin(address account) external view returns (bool);
    function addAdmin(address account) external;
    function removeAdmin(address account) external;
    function renounceAdmin() external;
    function setNewPair(string memory _pairName, 
            uint256 _price, 
            address _baseAddress, 
            address _quoteAddress,
            address _clAddress, 
            uint8 _pairDecimals,
            uint8 _baseDecimals,
            uint8 _quoteDecimals, 
            uint8 _removeDecimals,
            bool _reciprPrice) external;
    function setPairValue(uint256 _pairId, uint256 _price, uint8 _pairDecimals) external;
    function setBaseQuoteDecimals(uint256 _pairId, uint8 _baseDecimals, uint8 _quoteDecimals) external;
    function setPairDecimals(uint256 _pairId, uint8 _pairDecimals) external;
    function setChainlinkParameters(uint256 _pairId, address _clAddress, bool _reciprPrice) external;
    function setPairRemoveDecimals(uint256 _pairId, uint8 _removeDecimals) external;
    function getPairCounter() external view returns (uint256);
    function getPairValue(uint256 _pairId) external view returns (uint256);
    function getPairName(uint256 _pairId) external view returns (string memory);
    function getPairDecimals(uint256 _pairId) external view returns (uint8);
    function getPairBaseDecimals(uint256 _pairId) external view returns (uint8);
    function getPairQuoteDecimals(uint256 _pairId) external view returns (uint8);
    function getPairBaseAddress(uint256 _pairId) external view returns (address);
    function getPairQuoteAddress(uint256 _pairId) external view returns (address);
}


/**
 */

interface IJLoanHelper {
    function calculateCollFeesOnActivation(uint256 _collAmount, uint8 _factoryFees) external view returns (uint256);
    function calcMinCollateralAmount(uint256 _pairId, 
            uint256 _askAmount, 
            uint8 _requiredCollateralRatio) external view returns (uint256);
    function calcMinCollateralWithFeesAmount(uint256 _pairId, 
            uint256 _askAmount, 
            uint8 _requiredCollateralRatio, 
            uint8 _factoryFees) external view returns (uint256);
    function calcMaxStableCoinAmount(uint256 _pairId, 
            uint256 _collAmount, 
            uint8 _requiredCollateralRatio) external view returns (uint256);
    function calcMaxStableCoinWithFeesAmount(uint256 _pairId, 
            uint256 _collAmount, 
            uint8 _requiredCollateralRatio, 
            uint8 _factoryFees) external view returns (uint256);
    function adjustDecimalsCollateral(uint _pairId, uint _numerator, uint _quotient) external view returns (uint result);
    function ratioDiffCollAmount(uint256 _pairId, 
            uint256 _ratio, 
            uint256 _borrAmount, 
            uint256 _balance) external view returns (uint256 collDiff);
    function collateralAdjustingRatio(uint256 _pairId, 
            uint256 _borrAmount, 
            uint256 _balance, 
            uint256 _newAmount, 
            bool _adding)  external view returns (uint256 ratio);
    function getCollateralRatio(uint256 _pairId, uint256 _borrAmount, uint256 _balance) external view returns (uint256 newCollRatio);
    function getAccruedInterests(uint256 _status, 
            uint256 _activeBlock, 
            uint256 _earlyWindow, 
            uint256 _closedBlock, 
            uint256 _balance,
            uint256 _lastWithdrawBlock, 
            uint256 _loanRpb) external view returns (uint256 accruedInterests);
    function calcActualCollateralRatio(uint256 _pairId, 
            uint256 _askAmount, 
            uint256 _status, 
            uint256 _balance,
            uint256 _activeBlock, 
            uint256 _earlyWindow, 
            uint256 _closedBlock,
            uint256 _lastWithdrawBlock, 
            uint256 _loanRpb) external view returns (uint256 newCollRatio);
    function calcLoanStatusOnCollRatio(uint256 _pairId, 
            uint256 _askAmount, 
            uint256 _status, 
            uint256 _balance,
            uint256 _activeBlock, 
            uint256 _earlyWindow, 
            uint256 _closedBlock,
            uint256 _lastWithdrawBlock, 
            uint256 _loanRpb,
            uint8 _foreclosingRatio,
            uint8 _instantFCRatio) external returns (uint256);
}


/**
 */


contract JLoanStructs is OwnableUpgradeSafe {
/* WARNING: NEVER RE-ORDER VARIABLES! Always double-check that new variables are added APPEND-ONLY. Re-ordering variables can permanently BREAK the deployed proxy contract.*/
    struct GeneralParams {
        uint256 earlySettlementWindow;
        uint256 foreclosureWindow;
        uint8 requiredCollateralRatio;
        uint8 foreclosingRatio;
        uint8 instantForeclosureRatio;
        uint8 limitCollRatioForWithdraw;
    }

    struct FeesParams {
        uint256 earlySettlementFee;
        uint8 factoryFees;
        uint8 userRewardShare;
        uint8 vaultRewardShare;
        uint8 cancellationFees;
        uint16 undercollateralizedForeclosingMultiple;
        uint16 atRiskForeclosedMultiple;
    }

    // shareholders struct
    struct Shareholder {
        address holder;
        uint256 shares;
        uint256 ownerBlockNumber;
    }

    struct LoanFeatures {
        uint256 loanRpbRate; 
        uint256 loanInitialCollateralRatio;
        address loanBorrower;
        uint256 loanPair;
        uint256 loanBalance;
        uint256 loanAskAmount;
        uint256 loanShareholdersCounter;
        mapping(uint256 => Shareholder) loanShareholders;
        mapping(address => bool) loanShareholdersAddress;
        mapping(address => uint256) loanShareholdersPlace;
    }

    struct LoanBlocks {
        uint256 loanCreationBlock;
        uint256 loanActiveBlock;
        uint256 loanLastDepositBlock;
        uint256 loanLastWithdrawBlock;
        uint256 loanInitiateForecloseBlock;
        uint256 loanClosingBlock;
        uint256 loanClosedBlock;
        uint256 lastInterestWithdrawalBlock;
        uint256 loanForeclosingBlock;
        uint256 loanForeclosedBlock;
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


/**
 */



contract JLoanStorage is OwnableUpgradeSafe, JLoanStructs {
/* WARNING: NEVER RE-ORDER VARIABLES! Always double-check that new variables are added APPEND-ONLY. Re-ordering variables can permanently BREAK the deployed proxy contract.*/
    // other contracts addresses
    address public feesCollectorAddress;
    address public priceOracleAddress;
    address public loanHelperAddress;
    address public loanStorageAddress;

    // loan id 
    uint256 public loanId;

    // locking booleans
    bool public fLock;
    bool public fLockAux;

    // contract version
    uint256 public contractVersion;

    // general loans parameters
    GeneralParams public generalLoansParams;

    // general fees parameters
    FeesParams public generalLoanFees;

    // mappings
    mapping(address => bool) public borrowers;
    mapping(uint256 => Status) public loanStatus;
    mapping(uint256 => LoanFeatures) public loanFeatures;
    mapping(uint256 => LoanBlocks) public loanBlocks;
}


/**
 */
pragma experimental ABIEncoderV2;








contract JLoan is OwnableUpgradeSafe, JLoanStorage {
    using SafeMath for uint256;

    event CollateralReceived(uint256 id, uint256 pairId, address sender, uint256 value, uint256 status);
    event WithdrawCollateral(uint256 id, uint256 amount);
    event LoanStatusChanged(uint256 id, uint256 oldStatus, uint256 newStatus, uint256 collectorAmnt, uint256 userAmnt);
    event AddShareholderShares(uint256 id, address indexed sharesBuyer, uint256 indexed amount);
    event InterestsWithdrawed(uint256 id, uint256 accruedInterests);

    function initialize(address _priceOracle, address _feesCollector, address _loanHelper) public initializer() {
        OwnableUpgradeSafe.__Ownable_init();
        priceOracleAddress = _priceOracle;
        feesCollectorAddress = payable(_feesCollector);
        loanHelperAddress = _loanHelper;

        generalLoansParams.earlySettlementWindow = 540000;
        generalLoansParams.foreclosureWindow = 18000;
        generalLoansParams.requiredCollateralRatio = 200;
        generalLoansParams.foreclosingRatio = 150;
        generalLoansParams.instantForeclosureRatio = 120;
        generalLoansParams.limitCollRatioForWithdraw = 160;

        generalLoanFees.factoryFees = 5;
        generalLoanFees.earlySettlementFee = 1080000; 
        generalLoanFees.userRewardShare = 80;
        generalLoanFees.vaultRewardShare = 20;
        generalLoanFees.undercollateralizedForeclosingMultiple = 1000;
        generalLoanFees.atRiskForeclosedMultiple = 3000;
        generalLoanFees.cancellationFees = 3;

        contractVersion = 1;
    }

    modifier onlyAdmins() {
        require(IJPriceOracle(priceOracleAddress).isAdmin(msg.sender), "!Admin");
        _;
    }

    fallback() external { // cannot deposit eth
        revert("ETH not accepted!");
    }

    /**
    * @dev update contract version
    * @param _ver new version
    */
    function updateVersion(uint256 _ver) external onlyAdmins {
        require(_ver > contractVersion, "!NewVersion");
        contractVersion = _ver;
    }

    /**
    * @dev set helper contract address 
    * @param _loanHelper helper contract new address
    */
    function setHelperContractAddress(address _loanHelper) external onlyAdmins {
        require(_loanHelper != loanHelperAddress, "sameHalperAddres");
        loanHelperAddress = _loanHelper;
    }

    /**
    * @dev set early settlement window
    * @param _value new param
    */
    function setEarlySettlementWindow(uint256 _value) external onlyAdmins {
        generalLoansParams.earlySettlementWindow = _value;
    }

    /**
    * @dev set foreclosure window
    * @param _value new param
    */
    function setForeclosureWindow(uint256 _value) external onlyAdmins {
        generalLoansParams.foreclosureWindow = _value;
    }

    /**
    * @dev set foreclosure ratio
    * @param _value set new param
    */
    function setForeclosureRatio(uint8 _value) external onlyAdmins {
        generalLoansParams.foreclosingRatio = _value;
    }

    /**
    * @dev set instant foreclosure ratio
    * @param _value new param
    */
    function setInstantForeclosureRatio(uint8 _value) external onlyAdmins {
        generalLoansParams.instantForeclosureRatio = _value;
    }

    /**
    * @dev set required collateral ratio
    * @param _value new param
    */
    function setRequiredCollateralRatio(uint8 _value) external onlyAdmins {
        generalLoansParams.requiredCollateralRatio = _value;
    }

    /**
    * @dev set factory fees
    * @param _value new param
    */
    function setFactoryFees(uint8 _value) external onlyAdmins {
        generalLoanFees.factoryFees = _value;
    }

    /**
    * @dev set early settlement fee
    * @param _value new param
    */
    function setEarlySettlementFee(uint256 _value) external onlyAdmins {
        generalLoanFees.earlySettlementFee = _value;
    }

    /**
    * @dev set user reward share
    * @param _value new param
    */
    function setUserRewardShare(uint8 _value) external onlyAdmins {
        generalLoanFees.userRewardShare = _value;
    }

    /**
    * @dev set set vault shares
    * @param _value new param
    */
    function setVaultShares(uint8 _value) external onlyAdmins {
        generalLoanFees.vaultRewardShare = _value;
    }

    /**
    * @dev set undercollateralized foreclosing multiple
    * @param _value new param
    */
    function setUndercollateralizedForeclosingMultiple(uint16 _value) external onlyAdmins {
        generalLoanFees.undercollateralizedForeclosingMultiple = _value;
    }

    /**
    * @dev set at risk foreclosed multiple
    * @param _value new param
    */
    function setAtRiskForeclosedMultiple(uint16 _value) external onlyAdmins {
        generalLoanFees.atRiskForeclosedMultiple = _value;
    }

    /**
    * @dev set cancellation fees
    * @param _value set new param
    */
    function setCancellationFees(uint8 _value) external onlyAdmins {
        generalLoanFees.cancellationFees = _value;
    }

    /**
    * @dev get collateral token address, reading them from price oracle
    * @param _pairId pairId
    * @return address of the collateral token
    */
    function getCollateralTokenAddress(uint256 _pairId) public view returns (address) {
        return IJPriceOracle(priceOracleAddress).getPairBaseAddress(_pairId);
    }

    /**
    * @dev get lent token address, reading them from price oracle
    * @param _pairId pairId
    * @return address of the lent token
    */
    function getLentTokenAddress(uint256 _pairId) public view returns (address) {
        return IJPriceOracle(priceOracleAddress).getPairQuoteAddress(_pairId);
    }

    /**
    * @dev get the amount of collateral needed to have stable coin amount (no fees)
    * @param _pairId number of the pair
    * @param _askAmount amount in stable coin the borrower would like to receive
    * @return amount of collateral the borrower needs to send
    */
    function getMinCollateralNoFeesAmount(uint256 _pairId, uint256 _askAmount) public view returns (uint256) {
        return IJLoanHelper(loanHelperAddress).calcMinCollateralAmount(_pairId, _askAmount, generalLoansParams.requiredCollateralRatio);
    }

    /**
    * @dev get the amount of collateral needed to have stable coin amount (with fees)
    * @param _pairId number of the pair
    * @param _askAmount amount in stable coin the borrower would like to receive
    * @return amount of collateral the borrower needs to send
    */
    function getMinCollateralWithFeesAmount(uint256 _pairId, uint256 _askAmount) public view returns (uint256) {
        return IJLoanHelper(loanHelperAddress).calcMinCollateralWithFeesAmount(_pairId, _askAmount, generalLoansParams.requiredCollateralRatio, generalLoanFees.factoryFees);
    }
/*
    /**
    * @dev get the amount of stable coin based on a collateral amount (no fees)
    * @param _pairId number of the pair
    * @param _collAmount amount in collateral the borrower is sending to the loan
    * @return amount of stable coins the borrower could receive
    */
/*    function getMaxStableCoinNoFeesAmount(uint256 _pairId, uint256 _collAmount) public view returns (uint256) {
        return IJLoanHelper(loanHelperAddress).calcMaxStableCoinAmount(_pairId, _collAmount, generalLoansParams.requiredCollateralRatio);
    }
*/
    /**
    * @dev get the amount of stable coin based on a collateral amount (with fees)
    * @param _pairId number of the pair
    * @param _collAmount amount in collateral the borrower is sending to the loan
    * @return amount of stable coins the borrower could receive
    */
    function getMaxStableCoinWithFeesAmount(uint256 _pairId, uint256 _collAmount) public view returns (uint256) {
        return IJLoanHelper(loanHelperAddress).calcMaxStableCoinWithFeesAmount(_pairId, _collAmount, generalLoansParams.requiredCollateralRatio, generalLoanFees.factoryFees);
    }

    /**
    * @dev get fees on collateral amount on activation
    * @param _collAmount collateral amount
    * @return amount of collateral fees
    */
    function getCollFeesOnActivation(uint256 _collAmount) public view returns (uint256) {
        return IJLoanHelper(loanHelperAddress).calculateCollFeesOnActivation(_collAmount, generalLoanFees.factoryFees);
    }
    
    /**
    * @dev open a new eth loan with msg.value amount of collateral
    * @param _pairId pair Id
    * @param _borrowedAskAmount ERC20 address
    * @param _rpbRate token amount
    */
    function openNewLoan(uint256 _pairId, uint256 _borrowedAskAmount, uint256 _rpbRate) external payable {
        require(_rpbRate > 0, "!allowedRPB");
        require(!fLock, "locked");
        fLock = true;
        require(msg.sender!=address(0), "_senderZeroAddress");
        uint256 totalCollateralRequest = getMinCollateralWithFeesAmount(_pairId, _borrowedAskAmount);
        uint256 collAmount;
        uint256 allowance = 0;
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
        loanFeatures[loanId].loanPair = _pairId;
        loanFeatures[loanId].loanBorrower = msg.sender;
        loanFeatures[loanId].loanBalance = collAmount;
        loanFeatures[loanId].loanRpbRate = _rpbRate;
        loanFeatures[loanId].loanAskAmount = _borrowedAskAmount;
        loanBlocks[loanId].loanCreationBlock = block.number;
        loanStatus[loanId] = Status.pending;
        emit CollateralReceived(loanId, _pairId, msg.sender, collAmount, uint256(loanStatus[loanId]));
        loanId = loanId.add(1);
        if (collateralToken != address(0))
            TransferHelper.safeTransferFrom(collateralToken, msg.sender, address(this), totalCollateralRequest);
        fLock = false;
    }

    /**
    * @dev get loan id conuter
    * @return uint256 loan counter
    */
/*    function getLoansCounter() external view returns (uint256) {
        return loanId;
    }
*/
    //// Utility functions


    /**
    * @dev deposit collateral
    * @param _id loan id
    */
    function depositEthCollateral(uint256 _id) external payable {
        require(!fLock, "locked");
        fLock = true;
        require(getCollateralTokenAddress(loanFeatures[_id].loanPair) == address(0), "!ETHLoan");
        require(loanStatus[_id] <= Status.foreclosing, "!Status04");
        loanFeatures[_id].loanBalance = loanFeatures[_id].loanBalance.add(msg.value);
        loanBlocks[_id].loanLastDepositBlock = block.number;
        uint256 status = setLoanStatusOnCollRatio(_id);
        emit CollateralReceived(_id, loanFeatures[_id].loanPair, msg.sender, msg.value, status);
        fLock = false;
    }

    /**
    * @dev deposit collateral tokens
    * @param _id loan id
    * @param _tok ERC20 address
    * @param _amount token amount
    */
    function depositTokenCollateral(uint256 _id, address _tok, uint256 _amount) external {
        require(!fLock, "locked");
        fLock = true;
        address collateralToken = getCollateralTokenAddress(loanFeatures[_id].loanPair);
        require(collateralToken != address(0), "!TokenLoan");
        require(loanStatus[_id] <= Status.foreclosing, "!Status04");
        require(collateralToken == address(_tok), "!collToken" );
        uint256 allowance = IERC20(collateralToken).allowance(msg.sender, address(this));
        require(allowance >= _amount, "!allowance");
        loanFeatures[_id].loanBalance = loanFeatures[_id].loanBalance.add(_amount);
        loanBlocks[_id].loanLastDepositBlock = block.number;
        uint256 status = setLoanStatusOnCollRatio(_id);
        emit CollateralReceived(_id, loanFeatures[_id].loanPair, msg.sender, _amount, status);
        TransferHelper.safeTransferFrom(_tok, msg.sender, address(this), _amount);
        fLock = false;
    }

    /**
    * @dev withdraw ethers from contract
    * @param _id loan id
    * @param _amount eth amount
    */
    function withdrawCollateral(uint256 _id, uint256 _amount) external {
        require(!fLock, "locked");
        fLock = true;
        require(loanFeatures[_id].loanBorrower == msg.sender, "!borrower");
        uint256 status = setLoanStatusOnCollRatio(_id);
        require(status <= 1, "!Status01");
        uint256 withdrawalAmount = calcDiffCollAmountForRatio(_id, generalLoansParams.limitCollRatioForWithdraw);
        require(_amount <= withdrawalAmount, "TooMuch");
        loanFeatures[_id].loanBalance = loanFeatures[_id].loanBalance.sub(_amount);
        loanBlocks[_id].loanLastWithdrawBlock = block.number;
        emit WithdrawCollateral(_id, _amount);
        address collateralToken = getCollateralTokenAddress(loanFeatures[_id].loanPair);
        if (collateralToken == address(0))
            TransferHelper.safeTransferETH(msg.sender, _amount);
        else
            TransferHelper.safeTransfer(collateralToken, msg.sender, _amount);
        fLock = false;
    }

    /**
    * @dev get contract overall balance about a token or eth
    * @param _id loan id
    * @return balance
    */
    function getContractBalance(uint256 _id) external view returns (uint256) {
        address collateralToken = getCollateralTokenAddress(loanFeatures[_id].loanPair);
        if (collateralToken == address(0))
            return address(this).balance;
        else
            return IERC20(collateralToken).balanceOf(address(this));
    }
/*
    /**
    * @dev get single loan balance
    * @param _id loan id
    * @return uint256 balance of single loan
    */
/*    function getLoanBalance(uint256 _id) public view returns (uint256) {
        return loanFeatures[_id].loanBalance;
    }   
/*
    /**
    * @dev get single loan status
    * @param _id loan id
    * @return uint256 balance of single loan
    */
/*    function getLoanStatus(uint256 _id) external view returns (uint256) {
        return uint256(loanStatus[_id]);
    }*/
/*
    /**
    * @dev set single loan status
    * @param _id loan id
    * @param _newStatus new loan status
    */
/*    function setNewStatus(uint256 _id, uint256 _newStatus) external onlyAdmins {
        loanStatus[_id] = Status(_newStatus);
    }
*/
/*
    /**
    * @dev get general parameters in loan contract
    * @return param struct
    */
/*    function getGeneralParams() external view returns (GeneralParams memory) {
        return generalLoansParams;
    }
*/
/*
    /**
    * @dev get general fees in loan contract
    * @return param struct
    */
/*    function getGeneralFees() external view returns (FeesParams memory) {
        return generalLoanFees;
    }
*/
    /**
    * @dev check if loan is in early settlement period
    * @param _id loan id
    * @return boolean
    */
    function checkLoanInEarlySettlementWindow(uint256 _id) external view returns (bool) {
        uint256 lastEarlyBlock = loanBlocks[_id].loanActiveBlock.add(generalLoansParams.earlySettlementWindow);
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
    function checkEarlySettledLoan(uint256 _id) external view returns (bool) {
        return loanStatus[_id] == Status.earlyClosing;
    }
/*
    /**
    * @dev set initial collateral ratio of the loan
    * @param _id loan id
    */
/*    function setInitalCollateralRatio(uint256 _id) external {
        if (loanStatus[_id] == Status.pending)
            loanFeatures[_id].loanInitialCollateralRatio = getActualCollateralRatio(_id);
    }
*/
    /**
    * @dev get the collateral ratio of the loan (subtracting the accrued interests)
    * @param _id loanId
    * @return newCollRatio collateral ratio
    */
    function getActualCollateralRatio(uint256 _id) public view returns (uint256 newCollRatio) {
        newCollRatio = IJLoanHelper(loanHelperAddress).calcActualCollateralRatio(loanFeatures[_id].loanPair, loanFeatures[_id].loanAskAmount, uint256(loanStatus[_id]),
            loanFeatures[_id].loanBalance, loanBlocks[_id].loanActiveBlock, generalLoansParams.earlySettlementWindow, 
            loanBlocks[_id].loanClosedBlock, loanBlocks[_id].lastInterestWithdrawalBlock, loanFeatures[_id].loanRpbRate);
        return newCollRatio;
    }

    /**
    * @dev calc a new ratio if collateral amount has added to contract balance
    * @param _id loanId
    * @param _amount collateral amount to add
    * @param _adding bool, true if _amount is added, false if amount is removed to loan
    * @return ratio new collateral ratio, percentage with no decimals
    */
    function calcRatioAdjustingCollateral(uint256 _id, uint256 _amount, bool _adding) external view returns (uint256 ratio) {
        ratio = IJLoanHelper(loanHelperAddress).collateralAdjustingRatio(loanFeatures[_id].loanPair, 
                loanFeatures[_id].loanAskAmount, loanFeatures[_id].loanBalance, _amount, _adding);
        return ratio;
    }

    /**
    * @dev calc how much collateral amount has to be added to have a ratio
    * @param _id loanId
    * @param _ratio ratio to reach, percentage with no decimals (180 means 180%)
    * @return collDiff collateral amount to add or to subtract to reach that ratio
    */
    function calcDiffCollAmountForRatio(uint256 _id, uint256 _ratio) public view returns (uint256 collDiff) {
        collDiff = IJLoanHelper(loanHelperAddress).ratioDiffCollAmount(loanFeatures[_id].loanPair, 
                _ratio, loanFeatures[_id].loanAskAmount, loanFeatures[_id].loanBalance);
        return collDiff;
    }

    /**
    * @dev get shareholder mapping based on shareholder number
    * @param _id loanId
    * @param _shPlace shareholder place
    * @return JLoanStructs.Shareholder of the shareholder
    */
    function getSHAddress(uint256 _id, uint256 _shPlace) public view returns (JLoanStructs.Shareholder memory) {
        return loanFeatures[_id].loanShareholders[_shPlace];
    }

    //// Status 0 -> 1
    /**
    * @dev lender sends required stable coins to borrower and set the initial lender as a stakeholder (100%)
    * @param _id loan id
    * @param _stableAddr, address of the stabl coin address
    */
    function lenderSendStableCoins(uint256 _id, address _stableAddr) external {
        require(!fLock, "locked");
        fLock = true;
        address collateralToken = getCollateralTokenAddress(loanFeatures[_id].loanPair);
        address lentToken = getLentTokenAddress(loanFeatures[_id].loanPair);
        require(_stableAddr == lentToken, "!TokenOk");
        require(loanStatus[_id] == Status.pending, "!Status0");
        uint256 actualRatio = getActualCollateralRatio(_id);
        require(actualRatio >= generalLoansParams.limitCollRatioForWithdraw, "!EnoughCollateral");
        uint256 allowance = IERC20(lentToken).allowance(msg.sender, address(this));
        require(allowance >= loanFeatures[_id].loanAskAmount, "!allowance");
        loanFeatures[_id].loanShareholdersCounter = 1;
        loanBlocks[_id].loanActiveBlock = block.number;
        loanFeatures[_id].loanShareholders[loanFeatures[_id].loanShareholdersCounter] = Shareholder({holder: msg.sender, shares: 100, ownerBlockNumber: loanBlocks[_id].loanActiveBlock});
        loanFeatures[_id].loanShareholdersAddress[msg.sender] = true;
        loanFeatures[_id].loanShareholdersPlace[msg.sender] = loanFeatures[_id].loanShareholdersCounter;
        loanStatus[_id] = Status.active;
        loanBlocks[_id].lastInterestWithdrawalBlock = block.number;
        // move factory fees only when loan becomes active
        uint256 minCollateral = getMinCollateralNoFeesAmount(loanFeatures[_id].loanPair, loanFeatures[_id].loanAskAmount);
        uint256 fees4Factory = getCollFeesOnActivation(minCollateral);
        loanFeatures[_id].loanBalance = loanFeatures[_id].loanBalance.sub(fees4Factory);
        emit LoanStatusChanged(_id, 0, uint256(loanStatus[_id]), fees4Factory, 0);
        TransferHelper.safeTransferFrom(lentToken, msg.sender, loanFeatures[_id].loanBorrower, loanFeatures[_id].loanAskAmount);
        if (collateralToken == address(0))
            TransferHelper.safeTransferETH(payable(feesCollectorAddress), fees4Factory);
        else
            TransferHelper.safeTransfer(collateralToken, feesCollectorAddress, fees4Factory);
        fLock = false;
    }

    //// Status 1 or 2 or 3 or 4, based on collateral ratio
    /**
    * @dev set the status of the loan based on collateral ratio, applied only in states allowed 
    * @param _id loan id
    * @return loan status
    */
    function setLoanStatusOnCollRatio(uint256 _id) public returns (uint256) {
        uint256 oldStatus = uint256(loanStatus[_id]);
        loanStatus[_id] = Status( IJLoanHelper(loanHelperAddress).calcLoanStatusOnCollRatio(loanFeatures[_id].loanPair, loanFeatures[_id].loanAskAmount, 
            uint256(loanStatus[_id]), loanFeatures[_id].loanBalance, loanBlocks[_id].loanActiveBlock, generalLoansParams.earlySettlementWindow, 
            loanBlocks[_id].loanClosedBlock, loanBlocks[_id].lastInterestWithdrawalBlock, loanFeatures[_id].loanRpbRate, 
            generalLoansParams.foreclosingRatio, generalLoansParams.instantForeclosureRatio) );
        if (uint(loanStatus[_id]) == 1 && oldStatus == 4) {
            loanBlocks[_id].loanForeclosingBlock = 0;   //reset foreclosing block
        }
        emit LoanStatusChanged(_id, oldStatus, uint256(loanStatus[_id]), 0, 0);
        return uint256(loanStatus[_id]);
    }

    function safeTransferCollateralAmounts(uint256 _id, uint256 _userReward, uint256 _vaultReward) internal {
        address collateralToken = getCollateralTokenAddress(loanFeatures[_id].loanPair);
        if (collateralToken == address(0)) {
            TransferHelper.safeTransferETH(msg.sender, _userReward);
            TransferHelper.safeTransferETH(payable(feesCollectorAddress), _vaultReward);
        } else {
            TransferHelper.safeTransfer(collateralToken, msg.sender, _userReward);
            TransferHelper.safeTransfer(collateralToken, feesCollectorAddress, _vaultReward);
        }
    }

    //// Status 4 or 5, starting from 2 or 3, depending on collateral ratio
    /**
    * @dev set the loan in foreclosure state for undercollateralized loans
    * @param _id loan id
    */
    function initiateLoanForeclose(uint256 _id) external {
        require(!fLock, "locked");
        fLock = true;
        uint256 status = setLoanStatusOnCollRatio(_id);
        require(status == 2 || status == 3, "!Status23");
        uint256 reward;
        if (status == 2) {
            reward = uint256(generalLoanFees.undercollateralizedForeclosingMultiple).mul(loanFeatures[_id].loanRpbRate);
            setLoanForeclosing(_id);
        } else {
            reward = uint256(generalLoanFees.atRiskForeclosedMultiple).mul(loanFeatures[_id].loanRpbRate);
            setLoanForeclosed(_id);
        }
        uint256 bal = loanFeatures[_id].loanBalance;
        if (bal == 0 && loanStatus[_id] != Status.closed) {
            setLoanClosed(_id);
            fLock = false;
        }
        require(uint256(loanStatus[_id]) < 8, "LoanClosedOrCancelled");
        loanBlocks[_id].loanInitiateForecloseBlock = block.number;
        uint256 userReward;
        uint256 vaultReward;
        if (bal >= reward) {
            userReward = reward.mul(generalLoanFees.userRewardShare).div(100);
            vaultReward = reward.mul(generalLoanFees.vaultRewardShare).div(100);
        } else {
            userReward = bal.mul(generalLoanFees.userRewardShare).div(100);
            vaultReward = bal.sub(userReward);
            setLoanClosed(_id);
        }
        if (loanFeatures[_id].loanBalance > 0)
            loanFeatures[_id].loanBalance = loanFeatures[_id].loanBalance.sub(userReward).sub(vaultReward);
        emit LoanStatusChanged(_id, status, uint256(loanStatus[_id]), vaultReward, userReward);
        if (loanStatus[_id] != Status.closed)
            safeTransferCollateralAmounts(_id, userReward, vaultReward);
        fLock = false;
    }

    //// Status 2 -> 4
    /**
    * @dev set the loan in foreclosure state for undercollateralized loans
    * @param _id loan id
    */
    function setLoanForeclosing(uint256 _id) internal {
        loanStatus[_id] = Status.foreclosing;
        // get the block to calculate time to set it in foreclosed if no actions from the borrower
        loanBlocks[_id].loanForeclosingBlock = block.number;
    }

    /**
    * @dev set the loan in foreclosed state when foreclosureWindow time passed or collateral ratio is at risk
    * @param _id loan id
    * @return bool 
    */
    function setLoanToForeclosed(uint256 _id) external returns (bool) {
        require(!fLock, "locked");
        fLock = true;
        require(uint256(loanStatus[_id]) == 4, "!Status4");
        bool result = false;
        if (loanBlocks[_id].loanForeclosingBlock != 0) {
            uint256 bal = loanFeatures[_id].loanBalance;
            if (bal == 0) {
                setLoanClosed(_id);
                fLock = false;
            }
            require(uint256(loanStatus[_id]) < 8, "LoanClosedOrCancelled");
            uint256 newCollRatio = getActualCollateralRatio(_id);
            uint256 reward = uint256(generalLoanFees.atRiskForeclosedMultiple).mul(loanFeatures[_id].loanRpbRate);
            uint256 userReward;
            uint256 vaultReward;
            if ( newCollRatio < generalLoansParams.instantForeclosureRatio || block.number >= loanBlocks[_id].loanForeclosingBlock.add(generalLoansParams.foreclosureWindow) ) {
                if (bal >= reward) {
                    userReward = reward.mul(generalLoanFees.userRewardShare).div(100);
                    vaultReward = reward.mul(generalLoanFees.vaultRewardShare).div(100);
                    setLoanForeclosed(_id);
                } else {
                    userReward = bal.mul(generalLoanFees.userRewardShare).div(100);
                    vaultReward = bal.sub(userReward);
                    setLoanClosed(_id);
                }
                if (loanFeatures[_id].loanBalance > 0)
                    loanFeatures[_id].loanBalance = loanFeatures[_id].loanBalance.sub(userReward).sub(vaultReward);
                emit LoanStatusChanged(_id, 4, uint256(loanStatus[_id]), vaultReward, userReward);
                if (loanStatus[_id] != Status.closed)
                    safeTransferCollateralAmounts(_id, userReward, vaultReward);
                result = true;
            }
        }
        fLock = false;
        return result;
    }

    //// Status 2 -> 5
    /**
    * @dev set the loan in foreclosure state for undercollateralized loans
    * @param _id loan id
    */
    function setLoanForeclosed(uint256 _id) internal {
        // lender receives 100% of collateral of the borrowed amount
        address collateralToken = getCollateralTokenAddress(loanFeatures[_id].loanPair);
        uint256 collToSend = getMinCollateralNoFeesAmount(loanFeatures[_id].loanPair, loanFeatures[_id].loanAskAmount);
        loanBlocks[_id].loanForeclosedBlock = block.number;
        loanStatus[_id] = Status.foreclosed;
        if (collToSend > loanFeatures[_id].loanBalance)
            collToSend = loanFeatures[_id].loanBalance;
        for (uint8 i = 1; i <= loanFeatures[_id].loanShareholdersCounter; i++) {
            address shAddress = loanFeatures[_id].loanShareholders[i].holder;
            uint256 shPlace = getShareholderPlace(_id, loanFeatures[_id].loanShareholders[i].holder);
            uint256 shShares = loanFeatures[_id].loanShareholders[shPlace].shares;
            uint256 shAmount = collToSend.mul(shShares).div(100);
            if (collateralToken == address(0)) {
                TransferHelper.safeTransferETH(shAddress, shAmount);
            } else {
                TransferHelper.safeTransfer(collateralToken, shAddress, shAmount);
            }
        }
        loanFeatures[_id].loanBalance = loanFeatures[_id].loanBalance.sub(collToSend);
        if (loanFeatures[_id].loanBalance == 0) {
            loanBlocks[_id].loanClosedBlock = block.number;
            loanStatus[_id] = Status.closed;
        }
    }

    //// Status = 6
    /**
    * @dev set the loan in early closing state
    * @param _id loan id
    * @return uint256 requested balance
    */
    function loanEarlyClosing(uint256 _id) internal returns (uint256) {
        loanStatus[_id] = Status.earlyClosing;
        uint256 remainingBlock = generalLoansParams.earlySettlementWindow;
        uint256 blockAlreadyUsed = 0;
        if (loanBlocks[_id].lastInterestWithdrawalBlock != 0) {
            blockAlreadyUsed = loanBlocks[_id].lastInterestWithdrawalBlock.sub(loanBlocks[_id].loanActiveBlock);
            remainingBlock = (generalLoansParams.earlySettlementWindow).sub(blockAlreadyUsed);
        }
        uint256 balanceRequested = ( remainingBlock.sub(blockAlreadyUsed) ).mul(loanFeatures[_id].loanRpbRate);
        return balanceRequested;
    }

    //// Status = 7
    /**
    * @dev settle the loan in normal closing state by borrower
    * @param _id loan id
    */
    function loanClosingByBorrower(uint256 _id) external {
        require(!fLock, "locked");
        fLock = true;
        require(loanFeatures[_id].loanBorrower == msg.sender, "!borrower");
        uint256 status = setLoanStatusOnCollRatio(_id);
        require(status > 0 && status <= 3, "!Status13");
        // check that borrower gives back the loaned stable coin amount and transfer collateral to borrower
        address lentToken = getLentTokenAddress(loanFeatures[_id].loanPair);
        uint256 allowance = IERC20(lentToken).allowance(msg.sender, address(this));
        require(allowance >= loanFeatures[_id].loanAskAmount, "!allowanceSettle");
        uint256 balanceRequested;
        if (block.number < loanBlocks[_id].loanActiveBlock + generalLoansParams.earlySettlementWindow)
            balanceRequested = loanEarlyClosing(_id);
        else
            balanceRequested = getAccruedInterests(_id);
        uint256 feesAmount = 0;
        if (loanStatus[_id] == Status.earlyClosing) 
            feesAmount = (generalLoanFees.earlySettlementFee).mul(loanFeatures[_id].loanRpbRate);
        
        uint256 bal = loanFeatures[_id].loanBalance;
        uint256 requestedAmount = balanceRequested.add(feesAmount);
        loanBlocks[_id].loanClosingBlock = block.number;
        loanStatus[_id] = Status.closing;
        uint256 withdrawalBalance = 0;
        // check if there are enough collateral
        if (bal >= requestedAmount) {
            // borrower receives back collateral
            withdrawalBalance = bal.sub(requestedAmount); 
        }
        borrowerSendBackLentToken(_id);
        loanFeatures[_id].loanBalance = loanFeatures[_id].loanBalance.sub(withdrawalBalance).sub(feesAmount);
        emit LoanStatusChanged(_id, status, uint256(loanStatus[_id]), feesAmount, withdrawalBalance);
        safeTransferCollateralAmounts(_id, withdrawalBalance, feesAmount);
        fLock = false;
    }

    /**
    * @dev internal function to allow borrower to send back lent tokens to shareholders
    * @param _id loan id
    */
    function borrowerSendBackLentToken(uint256 _id) internal {
        address lentToken = getLentTokenAddress(loanFeatures[_id].loanPair);
        uint256 loanAmount = loanFeatures[_id].loanAskAmount;
        for (uint8 i = 1; i <= loanFeatures[_id].loanShareholdersCounter; i++) {
            address shAddress = loanFeatures[_id].loanShareholders[i].holder;
            uint256 shPlace = getShareholderPlace(_id, loanFeatures[_id].loanShareholders[i].holder);
            uint256 shShares = loanFeatures[_id].loanShareholders[shPlace].shares;
            uint256 shAmount = loanAmount.mul(shShares).div(100);
            TransferHelper.safeTransferFrom(lentToken, msg.sender, shAddress, shAmount);
        }
    }

    //// Status = 8
    /**
    * @dev set the loan in closed state, let shareholders to withdraw the stable coins back
    * @param _id loan id
    */
    function setLoanClosed(uint256 _id) internal {
        loanBlocks[_id].loanClosedBlock = block.number;
        loanStatus[_id] = Status.closed;
    }

    //// Status = 9
    /**
    * @dev set the loan in cancelled state (only if pending)
    * @param _id loan id
    */
    function setLoanCancelled(uint256 _id) external {
        require(!fLock, "locked");
        fLock = true;
        require(loanFeatures[_id].loanBorrower == msg.sender, "!borrower");
        require(uint256(loanStatus[_id]) == 0, "!Status0");
        uint256 bal = loanFeatures[_id].loanBalance;
        uint256 feeCanc = bal.mul(generalLoanFees.cancellationFees).div(100);
        uint256 withdrawalBalance = bal.sub(feeCanc);
        loanStatus[_id] = Status.cancelled;
        loanFeatures[_id].loanBalance = loanFeatures[_id].loanBalance.sub(withdrawalBalance).sub(feeCanc);
        emit LoanStatusChanged(_id, 0, uint256(loanStatus[_id]), feeCanc, withdrawalBalance);
        address collateralToken = getCollateralTokenAddress(loanFeatures[_id].loanPair);
        if (collateralToken == address(0)) {
            TransferHelper.safeTransferETH(payable(feesCollectorAddress), feeCanc);
            TransferHelper.safeTransferETH(msg.sender, withdrawalBalance);
        } else {
            TransferHelper.safeTransfer(collateralToken, feesCollectorAddress, feeCanc);
            TransferHelper.safeTransfer(collateralToken, msg.sender, withdrawalBalance);
        }
        fLock = false;
    }


    //// Calculating interests functions
    /**
    * @dev get accrued interests of the contract
    * @param _id loan id
    * @return accruedInterests total accrued interests
    */
    function getAccruedInterests(uint256 _id) public view returns (uint256 accruedInterests) {
        return IJLoanHelper(loanHelperAddress).getAccruedInterests(uint256(loanStatus[_id]), loanBlocks[_id].loanActiveBlock, generalLoansParams.earlySettlementWindow, 
            loanBlocks[_id].loanClosedBlock, loanFeatures[_id].loanBalance, loanBlocks[_id].lastInterestWithdrawalBlock, loanFeatures[_id].loanRpbRate);
    }

    /**
    * @dev withdraw accreud interests for all shareholders and set the status after interests withdrawal
    * @param _id loan id
    * @return uint256 new status
    */
    function withdrawInterests(uint256 _id) public returns (uint256) {
        require(!fLock, "locked");
        fLock = true;
        // interests of all shareholders must be withdrawn with their shares amount
        require(uint256(loanStatus[_id]) > 0 && uint256(loanStatus[_id]) < 8, "!Status17" );
        uint256 bal = loanFeatures[_id].loanBalance;
        if (bal == 0) {
            setLoanClosed(_id);
            fLock = false;
        }
        require(uint256(loanStatus[_id]) < 8, "LoanClosedOrCancelled");
        uint256 status = uint256(loanStatus[_id]);
        uint256 accruedTotalInterests = getAccruedInterests(_id);
        if (bal >= accruedTotalInterests) {
            for (uint8 i = 1; i <= loanFeatures[_id].loanShareholdersCounter; i++) {
                shareholderWithdrawInterests(_id, loanFeatures[_id].loanShareholders[i].holder, accruedTotalInterests);
            }
            loanBlocks[_id].lastInterestWithdrawalBlock = block.number;
            if (status <= 4)
                status = setLoanStatusOnCollRatio(_id);
        } else {
            for (uint8 i = 1; i <= loanFeatures[_id].loanShareholdersCounter; i++) {
                shareholderWithdrawInterests(_id, loanFeatures[_id].loanShareholders[i].holder, bal);
            }
            loanBlocks[_id].lastInterestWithdrawalBlock = block.number;
            loanBlocks[_id].loanClosedBlock = block.number;
            loanStatus[_id] = Status.closed;
            status = uint256(loanStatus[_id]);
        }
        emit InterestsWithdrawed(_id, accruedTotalInterests);
        fLock = false;
        return status;
    }

    /**
    * @dev withdraw accreud interests for a bunch of loans for all shareholders and set the status after interests withdrawal
    * @param _id loan id array
    * @return success
    */
    function withdrawInterestsMassive(uint256[] memory _id) external returns (bool success) {
        require(_id.length <= 100, "TooMuchLoans");
        require(!fLockAux, "Locked");
        fLockAux = true;
        for (uint8 j = 0; j < _id.length; j++) {
            uint256 presentId = _id[j];
            withdrawInterests(presentId);
        }
        fLockAux = false;
        return true;
    }

    //// shareholders functions
    /**
    * @dev withdraw accreud interests for a shareholder
    * @param _id loan id
    * @param _shareholder shareholder address
    * @param _accruedTotalInterests accrued total interests
    */
    function shareholderWithdrawInterests(uint256 _id, address _shareholder, uint256 _accruedTotalInterests) internal {
        require(isShareholder(_id, _shareholder), "!shareholder"); 
        uint256 shPlace = getShareholderPlace(_id, _shareholder);
        uint256 shShares = loanFeatures[_id].loanShareholders[shPlace].shares;
        uint256 interestsToSend = _accruedTotalInterests.mul(shShares).div(100);
        loanFeatures[_id].loanBalance = loanFeatures[_id].loanBalance.sub(interestsToSend);
        address collateralToken = getCollateralTokenAddress(loanFeatures[_id].loanPair);
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
    function isShareholder(uint256 _id, address _holder) public view returns (bool) {
        return loanFeatures[_id].loanShareholdersAddress[_holder];
    }

    /**
    * @dev get a shareholder place in shareholders array
    * @param _id loan id
    * @param _holder shareholder address
    * @return uint256 shareholder place
    */
    function getShareholderPlace(uint256 _id, address _holder) public view returns (uint256) {
        return loanFeatures[_id].loanShareholdersPlace[_holder];
    }

    /**
    * @dev add shareholder in shareholders arrays
    * @param _id loan id
    * @param _newShareholder buyer address
    * @param _amount amount of shares
    * @return uint256 new status
    */
    function addLoanShareholders(uint256 _id, address _newShareholder, uint256 _amount) public returns (uint256) {
        require(!fLock, "locked");
        fLock = true;
        require(isShareholder(_id, msg.sender), "!shareholder");
        uint256 shPlace = getShareholderPlace(_id, msg.sender);
        require(shPlace > 0, "!shPlace");
        require(loanFeatures[_id].loanShareholders[shPlace].shares >= _amount, "!enoughShares");
        //before shares could be selled, interests of all shareholders must be withdrawn with old shares amount, in order to start with a new situation
        //require(block.number > loanBlocks[_id].loanActiveBlock + generalLoansParams.earlySettlementWindow, "earlyWindow");
        uint256 interestsAmount = getAccruedInterests(_id);
        for (uint8 i = 1; i <= loanFeatures[_id].loanShareholdersCounter; i++) {
            shareholderWithdrawInterests(_id, loanFeatures[_id].loanShareholders[i].holder, interestsAmount);
        }
        loanFeatures[_id].loanShareholders[shPlace].shares = loanFeatures[_id].loanShareholders[shPlace].shares.sub(_amount);
        if(!isShareholder(_id, _newShareholder)) { 
            loanFeatures[_id].loanShareholdersCounter = loanFeatures[_id].loanShareholdersCounter.add(1);
            loanFeatures[_id].loanShareholders[loanFeatures[_id].loanShareholdersCounter] = Shareholder({holder: _newShareholder, shares: _amount, ownerBlockNumber: block.number});
            loanFeatures[_id].loanShareholdersAddress[_newShareholder] = true;
            loanFeatures[_id].loanShareholdersPlace[_newShareholder] = loanFeatures[_id].loanShareholdersCounter;
        } else {
            uint256 shPlaceNew = getShareholderPlace(_id, _newShareholder);
            loanFeatures[_id].loanShareholders[shPlaceNew].shares = loanFeatures[_id].loanShareholders[shPlaceNew].shares.add(_amount);
            loanFeatures[_id].loanShareholders[shPlaceNew].ownerBlockNumber = block.number;
            emit AddShareholderShares(_id, _newShareholder, _amount);
        }
        loanBlocks[_id].lastInterestWithdrawalBlock = block.number;
        uint256 status = setLoanStatusOnCollRatio(_id);
        fLock = false;
        return status;
    }

    /**
    * @dev add shareholder in shareholders arrays in massive mode
    * @param _id loan id
    * @param _newShareholder buyer address array
    * @param _amount amount of shares array
    * @return success boolean
    */
    function addLoanShareholdersMassive(uint256 _id, address[] memory _newShareholder, uint256[] memory _amount) external returns (bool success) {
        require(_newShareholder.length <= 100, "TooMuchShareholders");
        require(_newShareholder.length == _amount.length, "!sameLength");
        require(!fLockAux, "Locked");
        fLockAux = true;
        for (uint8 j = 0; j < _newShareholder.length; j++) {
            address presentSH = _newShareholder[j];
            uint256 presentAmnt = _amount[j];
            addLoanShareholders(_id, presentSH, presentAmnt);
        }
        fLockAux = false;
        return true;
    }

    /**
    * @dev add one shareholder for multiple loans
    * @param _ids loan ids
    * @param _newShareholder shareholder address
    * @param _amounts amount of shares array
    * @return success boolean
    */
    function addShareholderToMultipleLoans(uint256[] memory _ids, address _newShareholder, uint256[] memory _amounts) external returns (bool success) {
        require(_ids.length <= 100, "TooMuchShareholders");
        require(_ids.length == _amounts.length, "JLoan: Arrays should be of the same length");
        require(!fLockAux, "Locked");
        fLockAux = true;
        for (uint8 j = 0; j < _ids.length; j++) {
            addLoanShareholders(_ids[j], _newShareholder, _amounts[j]);
        }
        fLock = false;
        return true;
    }

}
