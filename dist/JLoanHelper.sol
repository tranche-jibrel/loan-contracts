// SPDX-License-Identifier: MIT
/**
 * Created on 2020-11-23
 * @summary: JLoanHelper
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


interface IJPriceOracle {
    function isAdmin(address account) external view returns (bool);
    function addAdmin(address account) external;
    function removeAdmin(address account) external;
    function renounceAdmin() external;
    function setNewPair(string calldata _pairName, uint256 _price, uint8 _pairDecimals, 
                address _baseAddress, uint8 _baseDecimals, address _quoteAddress, uint8 _quoteDecimals) external;
    function setPairValue(uint256 _pairId, uint256 _price, uint8 _pairDecimals) external;
    function setBaseQuoteDecimals(uint256 _pairId, uint8 _baseDecimals, uint8 _quoteDecimals) external;
    function getPairCounter() external view returns (uint256);
    function getPairValue(uint256 _pairId) external view returns (uint256);
    function getPairName(uint256 _pairId) external view returns (string memory);
    function getPairDecimals(uint256 _pairId) external view returns (uint8);
    function getPairBaseDecimals(uint256 _pairId) external view returns (uint8);
    function getPairQuoteDecimals(uint256 _pairId) external view returns (uint8);
    function getPairBaseAddress(uint256 _pairId) external view returns (address);
    function getPairQuoteAddress(uint256 _pairId) external view returns (address);
}


interface IJLoanHelper {
    function calculateCollFeesOnActivation(uint256 _collAmount, uint8 factoryFees) external view returns (uint256);
    function calcMinCollateralAmount(uint256 _pairId, uint256 _askAmount, uint8 requiredCollateralRatio) external view returns (uint256);
    function calcMinCollateralWithFeesAmount(uint256 _pairId, uint256 _askAmount, uint8 requiredCollateralRatio, uint8 _factoryFees) external view returns (uint256);
    function calcMaxStableCoinAmount(uint256 _pairId, uint256 _collAmount, uint8 requiredCollateralRatio) external view returns (uint256);
    function calcMaxStableCoinWithFeesAmount(uint256 _pairId, uint256 _collAmount, uint8 requiredCollateralRatio, uint8 _factoryFees) external view returns (uint256);
    function adjustDecimalsCollateral(uint _pairId, uint _numerator, uint _quotient) external view returns (uint result);
    function ratioDiffCollAmount(uint _pairId, uint _ratio, uint _amount, uint _balance) external view returns (uint collDiff);
    function collateralAdjustingRatio(uint _pairId, uint _borrAmount, uint _balance, uint _newAmount, bool _adding) external view returns (uint ratio);
    function getCollateralRatio(uint _pairId, uint _borrAmount, uint _balance) external view returns (uint newCollRatio);
}


contract JLoanHelper is Ownable, IJLoanHelper {
    using SafeMath for uint256;

    address public priceOracleAddress;

    constructor(address _priceOracle) public {
        priceOracleAddress = _priceOracle;
    }

    modifier onlyAdmins() {
        require(IJPriceOracle(priceOracleAddress).isAdmin(msg.sender), "!Admin");
        _;
    }

    /**
    * @dev math round up
    * @param numerator numerator
    * @param denominator denominator
    * @param precision precision
    * @return number of quote currency decimals
    */
    function roundUp(uint256 numerator, uint256 denominator, uint256 precision) internal pure returns (uint256) {
        uint256 _numerator  = numerator.mul(10 ** (precision.add(1)));
        uint256 _quotient =  ((_numerator.div(denominator)).add(5)).div(10);
        return _quotient;
    }
    
    /**
    * @dev math round down
    * @param numerator numerator
    * @param denominator denominator
    * @param precision precision
    * @return number of quote currency decimals
    */
    function roundDn(uint256 numerator, uint256 denominator, uint256 precision) internal pure returns (uint256) {
        uint256 _numerator  = numerator.mul(10 ** (precision.add(1)));
        uint256 _quotient =  (_numerator.div(denominator).sub(5)).div(10);
        return _quotient;
    }

    /**
    * @dev calculate fees on collateral amount
    * @param _collAmount collateral amount
    * @return amount of collateral fees
    */
    function calculateCollFeesOnActivation(uint256 _collAmount, uint8 _factoryFees) public override view returns (uint256) {
        return roundUp(_collAmount.mul(uint256(_factoryFees)), 1000, 0);
    }

    /**
    * @dev get the amount of collateral needed to have stable coin amount (no fees)
    * @param _pairId number of the pair
    * @param _askAmount amount in stable coin the borrower would like to receive
    * @param _requiredCollateralRatio required collateral ratio
    * @return amount of collateral the borrower needs to send
    */
    function calcMinCollateralAmount(uint256 _pairId, uint256 _askAmount, uint8 _requiredCollateralRatio) public override view returns (uint256) {
        uint256 price = IJPriceOracle(priceOracleAddress).getPairValue(_pairId);
        uint256 pairDecimals = uint256(IJPriceOracle(priceOracleAddress).getPairDecimals(_pairId));
        uint256 minCollAmount = roundUp(_askAmount.mul(uint256(_requiredCollateralRatio)).mul(10 ** pairDecimals).div(100), price, 0);
        uint256 baseDecimals = uint256(IJPriceOracle(priceOracleAddress).getPairBaseDecimals(_pairId));
        uint256 quoteDecimals = uint256(IJPriceOracle(priceOracleAddress).getPairQuoteDecimals(_pairId));
        if (baseDecimals >= quoteDecimals) {
            uint256 diffBaseQuoteDecimals = baseDecimals.sub(quoteDecimals);
            minCollAmount = minCollAmount.mul(10 ** diffBaseQuoteDecimals).add(5); //add 5 to be sure evrything is ok
        } else {
            uint256 diffBaseQuoteDecimals = quoteDecimals.sub(baseDecimals);
            minCollAmount = minCollAmount.div(10 ** diffBaseQuoteDecimals).add(5); //add 5 to be sure evrything is ok
        }
        return minCollAmount;
    }

    /**
    * @dev get the amount of collateral needed to have stable coin amount, with fees
    * @param _pairId number of the pair
    * @param _askAmount amount in stable coin the borrower would like to receive
    * @param _requiredCollateralRatio required collateral ratio
    * @return amount of collateral the borrower needs to send
    */
    function calcMinCollateralWithFeesAmount(uint256 _pairId, uint256 _askAmount, uint8 _requiredCollateralRatio, uint8 _factoryFees) public override view returns (uint256) {
        uint256 minCollAmount = calcMinCollateralAmount(_pairId, _askAmount, _requiredCollateralRatio);
        uint256 feesCollAmount = calculateCollFeesOnActivation(minCollAmount, _factoryFees);
        uint256 totalCollAmountWithFees = minCollAmount.add(feesCollAmount);
        return totalCollAmountWithFees;
    }
    
    /**
    * @dev get the amount of stable coin that a borrower could receive in front of a collateral amount (no fees)
    * @param _pairId number of the pair
    * @param _collAmount amount in collateral unit the borrower could receive with that aount of collateral
    * @param _requiredCollateralRatio required collateral ratio
    * @return amount of stable coins the borrower could receive
    */
    function calcMaxStableCoinAmount(uint256 _pairId, uint256 _collAmount, uint8 _requiredCollateralRatio) public override view returns (uint256) {
        uint256 price = IJPriceOracle(priceOracleAddress).getPairValue(_pairId);
        uint256 pairDecimals = uint256(IJPriceOracle(priceOracleAddress).getPairDecimals(_pairId));
        uint256 askAmount = roundDn(_collAmount.mul(100).mul(price).div(uint256(_requiredCollateralRatio)), 10 ** pairDecimals, 0);
        uint256 baseDecimals = uint256(IJPriceOracle(priceOracleAddress).getPairBaseDecimals(_pairId));
        uint256 quoteDecimals = uint256(IJPriceOracle(priceOracleAddress).getPairQuoteDecimals(_pairId));
        if (baseDecimals >= quoteDecimals) {
            uint256 diffBaseQuoteDecimals = baseDecimals.sub(quoteDecimals);
            askAmount = askAmount.div(10 ** diffBaseQuoteDecimals).sub(5); //subtract 5 to be sure everything is ok
        } else {
            uint256 diffBaseQuoteDecimals = baseDecimals.sub(quoteDecimals);
            askAmount = askAmount.mul(10 ** diffBaseQuoteDecimals).sub(5); //subtract 5 to be sure everything is ok
        }
        return askAmount;
    }

    /**
    * @dev get the amount of stable coin that a borrower could receive in front of a collateral amount wiht activation fees
    * @param _pairId number of the pair
    * @param _collAmount amount in collateral unit the borrower could receive with that aount of collateral
    * @param _requiredCollateralRatio required collateral ratio
    * @return amount of stable coins the borrower could receive subtracting fees
    */
    function calcMaxStableCoinWithFeesAmount(uint256 _pairId, uint256 _collAmount, uint8 _requiredCollateralRatio, uint8 _factoryFees) external override view returns (uint256) {
        uint256 feesCollAmount = calculateCollFeesOnActivation(_collAmount, _factoryFees); 
        uint256 collAmountWithFees = _collAmount.sub(feesCollAmount);
        uint256 askAmountWithFees = calcMaxStableCoinAmount(_pairId, collAmountWithFees, _requiredCollateralRatio);
        return askAmountWithFees;
    }

/**
    * @dev adjust for decimals in tokens pair for ratio
    * @param _pairId pair Id
    * @param _numerator numerator
    * @param _quotient quotient
    * @return result of operation
    */
    function adjustDecimalsRatio(uint256 _pairId, uint256 _numerator, uint256 _quotient) internal view returns (uint256 result) {
        uint256 collDecimals = uint256(IJPriceOracle(priceOracleAddress).getPairBaseDecimals(_pairId));
        uint256 lendDecimals = uint256(IJPriceOracle(priceOracleAddress).getPairQuoteDecimals(_pairId));
        if (collDecimals >= lendDecimals) {
            uint256 diffBaseQuoteDecimals = collDecimals.sub(lendDecimals);
            result = _numerator.mul(10 ** diffBaseQuoteDecimals).div(_quotient);
        } else {
            uint256 diffBaseQuoteDecimals = lendDecimals.sub(collDecimals);
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
    function adjustDecimalsCollateral(uint256 _pairId, uint256 _numerator, uint256 _quotient) public override view returns (uint256 result) {
        uint256 collDecimals = uint256(IJPriceOracle(priceOracleAddress).getPairBaseDecimals(_pairId));
        uint256 lendDecimals = uint256(IJPriceOracle(priceOracleAddress).getPairQuoteDecimals(_pairId));
        if (collDecimals >= lendDecimals) {
            uint256 diffBaseQuoteDecimals = collDecimals.sub(lendDecimals);
            result = _numerator.div(_quotient).div(10 ** diffBaseQuoteDecimals);
        } else {
            uint256 diffBaseQuoteDecimals = lendDecimals.sub(collDecimals);
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
    function ratioDiffCollAmount(uint256 _pairId, uint256 _ratio, uint256 _borrAmount, uint256 _balance) external override view returns (uint256 collDiff) {
        uint256 price = IJPriceOracle(priceOracleAddress).getPairValue(_pairId);
        uint256 pairDecimals = uint256(IJPriceOracle(priceOracleAddress).getPairDecimals(_pairId));
        uint256 numerator = _borrAmount.mul(_ratio).mul(10 ** pairDecimals);
        uint256 quotient = price.mul(100);
        uint256 newBal = adjustDecimalsRatio(_pairId, numerator, quotient);
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
    function collateralAdjustingRatio(uint256 _pairId, uint256 _borrAmount, uint256 _balance, uint256 _newAmount, bool _adding) external override view returns (uint256 ratio) {
        uint256 actualPrice = IJPriceOracle(priceOracleAddress).getPairValue(_pairId);
        uint256 pairDecimals = uint256(IJPriceOracle(priceOracleAddress).getPairDecimals(_pairId));
        uint256 newLoanBal;
        if (_adding)
            newLoanBal = _balance.add(_newAmount);
        else {
            if (_newAmount < _balance)
                newLoanBal = _balance.sub(_newAmount);
            else 
                return 0;
        }
        uint256 numerator = newLoanBal.mul(actualPrice).mul(100);
        uint256 quotient = _borrAmount.mul(10 ** pairDecimals);
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
    function getCollateralRatio(uint256 _pairId, uint256 _borrAmount, uint256 _balance) external override view returns (uint256 newCollRatio) {
        uint256 newPrice = IJPriceOracle(priceOracleAddress).getPairValue(_pairId);
        uint256 pairDecimals = uint256(IJPriceOracle(priceOracleAddress).getPairDecimals(_pairId));
        uint256 numerator = _balance.mul(newPrice).mul(100);
        uint256 quotient = _borrAmount.mul(10 ** pairDecimals);
        newCollRatio = adjustDecimalsCollateral(_pairId, numerator, quotient);
        return newCollRatio;
    }
   

}
