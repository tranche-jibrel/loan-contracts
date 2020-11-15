// SPDX-License-Identifier: MIT
/**
 * Created on 2020-11-09
 * @summary: JLoanEth Interface
 * @author: Jibrel Team
 */
pragma solidity 0.6.12;


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
    function addLoanShareholdersMassive(uint _id, address[] calldata _newShareholder, uint[] calldata _amount) external returns (bool success);
    function addShareholderToMultipleLoans(uint[] calldata _ids, address _newShareholder, uint[] calldata _amounts) external returns (bool success);
}
