// SPDX-License-Identifier: MIT
/**
 * Created on 2020-11-09
 * @summary: Jibrel Price Oracle
 * @author: Jibrel Team
 */
pragma solidity 0.6.12;

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


contract JPriceOracle is Ownable, IJPriceOracle { 
    using SafeMath for uint256;

    address public factoryAddress;

    struct Pair {
        string pairName;
        uint pairValue;
        uint8 pairDecimals;
        address baseAddress;
        uint8 baseDecimals;
        address quoteAddress;
        uint8 quoteDecimals;
    }
    mapping(uint => Pair) public pairs;
    uint public pairCounter;

    event NewPair(uint indexed _pairId, string _pairName);
    event NewPrice(uint indexed pairId, string indexed pairName, uint pairValue, uint8 pairDecimals);
    event NewPairDecimals(uint indexed pairId, string indexed pairName, uint8 baseDecimals, uint8 quoteDecimals);
    event NewPairAddresses(uint indexed pairId, string indexed pairName, address baseAddress , address quoteAddress);

    constructor () public { }

    modifier onlyAdmins() {
        require(IJFactory(factoryAddress).isAdmin(msg.sender), "!Admin");
        _;
    }

    /**
    * @dev set factory address
    * @param _factoryAddress factory address
    */
    function setFactoryAddress(address _factoryAddress) external override onlyOwner {
        require(_factoryAddress != address(0), "!validAddress");
        factoryAddress = _factoryAddress;
    }

    /**
    * @dev set a new pair
    * @param _pairName string describing the pair (i.e. ETHDAI)
    * @param _price price of the pair
    * @param _pairDecimals number of decimals for pair
    * @param _baseAddress base address token
    * @param _baseDecimals base decimals token
    * @param _quoteAddress quote address token
    * @param _quoteDecimals quote decimals token
    */
    function setNewPair(string memory _pairName, uint _price, uint8 _pairDecimals, 
                address _baseAddress, uint8 _baseDecimals, address _quoteAddress, uint8 _quoteDecimals) external override onlyAdmins {
        pairs[pairCounter] = Pair({pairName: _pairName, pairValue: _price, pairDecimals: _pairDecimals, 
                baseAddress: _baseAddress, baseDecimals: _baseDecimals, quoteAddress: _quoteAddress, quoteDecimals: _quoteDecimals});
        emit NewPair(pairCounter, _pairName);
        pairCounter = pairCounter.add(1);
    }

    /**
    * @dev set a price for the specified pair
    * @param _pairId number of the pair
    * @param _price price of the pair
    * @param _pairDecimals number of decimals for pair
    */
    function setPairValue(uint _pairId, uint _price, uint8 _pairDecimals) external override onlyAdmins {
        require(_pairId < pairCounter, "pair does not exists");
        pairs[_pairId].pairValue = _price;
        pairs[_pairId].pairDecimals = _pairDecimals;
        emit NewPrice(_pairId, pairs[_pairId].pairName, pairs[_pairId].pairValue, pairs[_pairId].pairDecimals);
    }

    /**
    * @dev set a base and quote decimals for the specified pair
    * @param _pairId number of the pair
    * @param _baseDecimals base decimals of the pair
    * @param _quoteDecimals quote decimals for pair
    */
    function setBaseQuoteDecimals(uint _pairId, uint8 _baseDecimals, uint8 _quoteDecimals) external override onlyAdmins {
        require(_pairId < pairCounter, "pair does not exists");
        pairs[_pairId].baseDecimals = _baseDecimals;
        pairs[_pairId].quoteDecimals = _quoteDecimals;
        emit NewPairDecimals(_pairId, pairs[_pairId].pairName, pairs[_pairId].baseDecimals, pairs[_pairId].quoteDecimals);
    }

    /**
    * @dev get a pair price
    * @return pairs counter
    */
    function getPairCounter() external override view returns (uint) {
        return pairCounter;
    }

    /**
    * @dev get a pair price
    * @param _pairId number of the pair
    * @return price of the pair
    */
    function getPairValue(uint _pairId) external override view returns (uint) {
        require(_pairId < pairCounter, "pair does not exists");
        return pairs[_pairId].pairValue;
    }

    /**
    * @dev get a pair name
    * @param _pairId number of the pair
    * @return name of the pair
    */
    function getPairName(uint _pairId) external override view returns (string memory) {
        require(_pairId < pairCounter, "pair does not exists");
        return pairs[_pairId].pairName;
    }

    /**
    * @dev get a pair decimals
    * @param _pairId number of the pair
    * @return decimals of the pair
    */
    function getPairDecimals(uint _pairId) external override view returns (uint8) {
        require(_pairId < pairCounter, "pair does not exists");
        return pairs[_pairId].pairDecimals;
    }

    /**
    * @dev get a pair base decimals
    * @param _pairId number of the pair
    * @return number of base currency decimals
    */
    function getPairBaseDecimals(uint _pairId) external override view returns (uint8) {
        require(_pairId < pairCounter, "pair does not exists");
        return pairs[_pairId].baseDecimals;
    }

    /**
    * @dev get a pair quote decimals
    * @param _pairId number of the pair
    * @return number of quote currency decimals
    */
    function getPairQuoteDecimals(uint _pairId) external override view returns (uint8) {
        require(_pairId < pairCounter, "pair does not exists");
        return pairs[_pairId].quoteDecimals;
    }

    /**
    * @dev get a pair base decimals
    * @param _pairId number of the pair
    * @return address of base currency decimals
    */
    function getPairBaseAddress(uint _pairId) external override view returns (address) {
        require(_pairId < pairCounter, "pair does not exists");
        return pairs[_pairId].baseAddress;
    }

    /**
    * @dev get a pair quote decimals
    * @param _pairId number of the pair
    * @return address of quote currency decimals
    */
    function getPairQuoteAddress(uint _pairId) external override view returns (address) {
        require(_pairId < pairCounter, "pair does not exists");
        return pairs[_pairId].quoteAddress;
    }
}
