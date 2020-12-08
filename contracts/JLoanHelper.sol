// SPDX-License-Identifier: MIT
/**
 * Created on 2020-11-23
 * @summary: JLoanHelper
 * @author: Jibrel Team
 */
pragma solidity 0.6.12;

import "@openzeppelin/contracts-ethereum-package/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./IJPriceOracle.sol";
import "./IJLoanHelper.sol";

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