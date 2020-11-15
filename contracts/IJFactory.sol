// SPDX-License-Identifier: MIT
/**
 * Created on 2020-11-09
 * @summary: JFactory Interface
 * @author: Jibrel Team
 */
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "./IJLoanCommons.sol";


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
