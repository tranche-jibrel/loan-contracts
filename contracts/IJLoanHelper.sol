// SPDX-License-Identifier: MIT
/**
 * Created on 2020-11-09
 * @summary: JLoanHelper Interface
 * @author: Jibrel Team
 */
pragma solidity 0.6.12;

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