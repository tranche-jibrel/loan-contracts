// SPDX-License-Identifier: MIT
/**
 * Created on 2020-11-09
 * @summary: JLoanCommons Interface
 * @author: Jibrel Team
 */
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;


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
