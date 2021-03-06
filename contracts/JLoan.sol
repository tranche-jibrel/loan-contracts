// SPDX-License-Identifier: MIT
/**
 * Created on 2020-11-09
 * @summary: Jibrel Loans
 * @author: Jibrel Team
 */
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts-ethereum-package/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/math/Math.sol";
import "@openzeppelin/contracts-ethereum-package/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts-ethereum-package/contracts/access/Ownable.sol";
import "./TransferHelper.sol";
import "./IJPriceOracle.sol";
import "./IJLoanHelper.sol";
import "./JLoanStorage.sol";
import "./JLoanStructs.sol";

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
    * @dev set GeneralParams
    * @param _value set new param
    */
    function setEarlySettlementWindow(uint256 _value) external onlyAdmins {
        generalLoansParams.earlySettlementWindow = _value;
    }

    /**
    * @dev set GeneralParams
    * @param _value set new param
    */
    function setForeclosureWindow(uint256 _value) external onlyAdmins {
        generalLoansParams.foreclosureWindow = _value;
    }

    function setForeclosureRatio(uint8 _value) external onlyAdmins {
        generalLoansParams.foreclosingRatio = _value;
    }

    /**
    * @dev set GeneralParams
    * @param _value set new param
    */
    function setInstantForeclosureRatio(uint8 _value) external onlyAdmins {
        generalLoansParams.instantForeclosureRatio = _value;
    }

    /**
    * @dev set GeneralParams
    * @param _value set new param
    */
    function setRequiredCollateralRatio(uint8 _value) external onlyAdmins {
        generalLoansParams.requiredCollateralRatio = _value;
    }

    /**
    * @dev set GeneralParams
    * @param _value set new param
    */
    function setFactoryFees(uint8 _value) external onlyAdmins {
        generalLoanFees.factoryFees = _value;
    }

    /**
    * @dev set GeneralParams
    * @param _value set new param
    */
    function setEarlySettlementFee(uint256 _value) external onlyAdmins {
        generalLoanFees.earlySettlementFee = _value;
    }

    /**
    * @dev set GeneralParams
    * @param _value set new param
    */
    function setUserRewardShare(uint8 _value) external onlyAdmins {
        generalLoanFees.userRewardShare = _value;
    }

    /**
    * @dev set GeneralParams
    * @param _value set new param
    */
    function setVaultShares(uint8 _value) external onlyAdmins {
        generalLoanFees.vaultRewardShare = _value;
    }

    /**
    * @dev set GeneralParams
    * @param _value set new param
    */
    function setUndercollateralizedForeclosingMultiple(uint16 _value) external onlyAdmins {
        generalLoanFees.undercollateralizedForeclosingMultiple = _value;
    }

    /**
    * @dev set GeneralParams
    * @param _value set new param
    */
    function setAtRiskForeclosedMultiple(uint16 _value) external onlyAdmins {
        generalLoanFees.atRiskForeclosedMultiple = _value;
    }

    /**
    * @dev set GeneralParams
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

    /**
    * @dev get the amount of stable coin based on a collateral amount (no fees)
    * @param _pairId number of the pair
    * @param _collAmount amount in collateral the borrower is sending to the loan
    * @return amount of stable coins the borrower could receive
    */
    function getMaxStableCoinNoFeesAmount(uint256 _pairId, uint256 _collAmount) public view returns (uint256) {
        return IJLoanHelper(loanHelperAddress).calcMaxStableCoinAmount(_pairId, _collAmount, generalLoansParams.requiredCollateralRatio);
    }

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
        loanPair[loanId] = _pairId;
        loanBorrower[loanId] = msg.sender;
        loanBalance[loanId] = collAmount;
        loanParams[loanId].rpbRate = _rpbRate;
        loanAskAmount[loanId] = _borrowedAskAmount;
        loanParams[loanId].creationBlock = block.number;
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
    function getLoansCounter() external  view returns (uint256) {
        return loanId;
    }

    //// Utility functions
    /**
    * @dev get common parameters in loan contract
    * @return param struct
    */
     function getGeneralParams() external view returns (GeneralParams memory) {
        return generalLoansParams;
    }

    /**
    * @dev get common parameters in loan contract
    * @return param struct
    */
    function getGeneralFees() external view returns (FeesParams memory) {
        return generalLoanFees;
    }

    /**
    * @dev deposit collateral
    * @param _id loan id
    */
    function depositEthCollateral(uint256 _id) external payable {
        require(!fLock, "locked");
        fLock = true;
        require(getCollateralTokenAddress(loanPair[_id]) == address(0), "!ETHLoan");
        require(loanStatus[_id] <= Status.foreclosing, "!Status04");
        loanBalance[_id] = loanBalance[_id].add(msg.value);
        loanLastDepositBlock[_id] = block.number;
        uint256 status = setLoanStatusOnCollRatio(_id);
        emit CollateralReceived(_id, loanPair[_id], msg.sender, msg.value, status);
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
        address collateralToken = getCollateralTokenAddress(loanPair[_id]);
        require(collateralToken != address(0), "!TokenLoan");
        require(loanStatus[_id] <= Status.foreclosing, "!Status04");
        require(collateralToken == address(_tok), "!collToken" );
        uint256 allowance = IERC20(collateralToken).allowance(msg.sender, address(this));
        require(allowance >= _amount, "!allowance");
        loanBalance[_id] = loanBalance[_id].add(_amount);
        loanLastDepositBlock[_id] = block.number;
        uint256 status = setLoanStatusOnCollRatio(_id);
        emit CollateralReceived(_id, loanPair[_id], msg.sender, _amount, status);
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
        require(loanBorrower[_id] == msg.sender, "!borrower");
        uint256 status = setLoanStatusOnCollRatio(_id);
        require(status <= 1, "!Status01");
        uint256 withdrawalAmount = calcDiffCollAmountForRatio(_id, generalLoansParams.limitCollRatioForWithdraw);
        require(_amount <= withdrawalAmount, "TooMuch");
        loanBalance[_id] = loanBalance[_id].sub(_amount);
        loanLastWithdrawBlock[_id] = block.number;
        emit WithdrawCollateral(_id, _amount);
        address collateralToken = getCollateralTokenAddress(loanPair[_id]);
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
        address collateralToken = getCollateralTokenAddress(loanPair[_id]);
        if (collateralToken == address(0))
            return address(this).balance;
        else
            return IERC20(collateralToken).balanceOf(address(this));
    }

    /**
    * @dev get single loan balance
    * @param _id loan id
    * @return uint256 balance of single loan
    */
    function getLoanBalance(uint256 _id) public view returns (uint256) {
        return loanBalance[_id];
    }   

    /**
    * @dev get single loan status
    * @param _id loan id
    * @return uint256 balance of single loan
    */
    function getLoanStatus(uint256 _id) external view returns (uint256) {
        return uint256(loanStatus[_id]);
    }

    /**
    * @dev set single loan status
    * @param _id loan id
    * @param _newStatus new loan status
    */
    function setNewStatus(uint256 _id, uint256 _newStatus) external onlyAdmins {
        loanStatus[_id] = JLoanStructs.Status(_newStatus);
    }

    /**
    * @dev check if loan is in early settlement period
    * @param _id loan id
    * @return boolean
    */
    function checkLoanInEarlySettlementWindow(uint256 _id) external view returns (bool) {
        uint256 lastEarlyBlock = loanActiveBlock[_id].add(generalLoansParams.earlySettlementWindow);
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

    /**
    * @dev set initial collateral ratio of the loan
    * @param _id loan id
    */
    function setInitalCollateralRatio(uint256 _id) external {
        if (loanStatus[_id] == Status.pending)
            loanParams[_id].initialCollateralRatio = getActualCollateralRatio(_id);
    }

    /**
    * @dev get the collateral ratio of the loan (subtracting the accrued interests)
    * @param _id loanId
    * @return newCollRatio collateral ratio
    */
    function getActualCollateralRatio(uint256 _id) public view returns (uint256 newCollRatio) {
        uint256 borrAmnt = loanAskAmount[_id];
        uint256 loanBalanceId;
        if (loanStatus[_id] == Status.pending)
            loanBalanceId = getLoanBalance(_id);
        else
            loanBalanceId = getLoanBalance(_id).sub(getAccruedInterests(_id));
        newCollRatio = IJLoanHelper(loanHelperAddress).getCollateralRatio(loanPair[_id], borrAmnt, loanBalanceId);
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
        uint256 borrAmnt = loanAskAmount[_id];
        uint256 loanBalanceId = getLoanBalance(_id);
        ratio = IJLoanHelper(loanHelperAddress).collateralAdjustingRatio(loanPair[_id], borrAmnt, loanBalanceId, _amount, _adding);
        return ratio;
    }

    /**
    * @dev calc how much collateral amount has to be added to have a ratio
    * @param _id loanId
    * @param _ratio ratio to reach, percentage with no decimals (180 means 180%)
    * @return collDiff collateral amount to add or to subtract to reach that ratio
    */
    function calcDiffCollAmountForRatio(uint256 _id, uint256 _ratio) public view returns (uint256 collDiff) {
        uint256 borrAmnt = loanAskAmount[_id];
        uint256 loanBalanceId = getLoanBalance(_id);
        collDiff = IJLoanHelper(loanHelperAddress).ratioDiffCollAmount(loanPair[_id], _ratio, borrAmnt, loanBalanceId);
        return collDiff;
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
        address collateralToken = getCollateralTokenAddress(loanPair[_id]);
        address lentToken = getLentTokenAddress(loanPair[_id]);
        require(_stableAddr == lentToken, "!TokenOk");
        require(loanStatus[_id] == Status.pending, "!Status0");
        uint256 actualRatio = getActualCollateralRatio(_id);
        require(actualRatio >= generalLoansParams.limitCollRatioForWithdraw, "!EnoughCollateral");
        uint256 allowance = IERC20(lentToken).allowance(msg.sender, address(this));
        require(allowance >= loanAskAmount[_id], "!allowance");
        shareholdersCounter[_id] = 1;
        loanShareholders[_id][shareholdersCounter[_id]] = Shareholder({holder: msg.sender, shares: 100, ownerBlockNumber: loanActiveBlock[_id]});
        loanShareholdersAddress[_id][msg.sender] = true;
        loanShareholdersPlace[_id][msg.sender] = shareholdersCounter[_id];
        loanStatus[_id] = Status.active;
        loanActiveBlock[_id] = block.number;
        lastInterestWithdrawalBlock[_id] = block.number;
        // move factory fees only when loan becomes active
        uint256 minCollateral = getMinCollateralNoFeesAmount(loanPair[_id], loanAskAmount[_id]);
        uint256 fees4Factory = getCollFeesOnActivation(minCollateral);
        loanBalance[_id] = loanBalance[_id].sub(fees4Factory);
        emit LoanStatusChanged(_id, 0, uint256(loanStatus[_id]), fees4Factory, 0);
        TransferHelper.safeTransferFrom(lentToken, msg.sender, loanBorrower[_id], loanAskAmount[_id]);
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
        uint256 newCollRatio = getActualCollateralRatio(_id); // (i.e. 180 means 180%)
        uint256 oldStatus = uint256(loanStatus[_id]);
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
        emit LoanStatusChanged(_id, oldStatus, uint256(loanStatus[_id]), 0, 0);
        return uint256(loanStatus[_id]);
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
            reward = uint256(generalLoanFees.undercollateralizedForeclosingMultiple).mul(loanParams[_id].rpbRate);
            setLoanForeclosing(_id);
        } else {
            reward = uint256(generalLoanFees.atRiskForeclosedMultiple).mul(loanParams[_id].rpbRate);
            setLoanForeclosed(_id);
        }
        uint256 bal = loanBalance[_id];
        if (bal == 0) {
            setLoanClosed(_id);
            fLock = false;
        }
        require(uint256(loanStatus[_id]) < 8, "LoanClosedOrCancelled");
        loanInitiateForecloseBlock[_id] = block.number;
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
        loanBalance[_id] = loanBalance[_id].sub(userReward).sub(vaultReward);
        emit LoanStatusChanged(_id, status, uint256(loanStatus[_id]), vaultReward, userReward);
        address collateralToken = getCollateralTokenAddress(loanPair[_id]);
        if (collateralToken == address(0)) {
            TransferHelper.safeTransferETH(msg.sender, userReward);
            TransferHelper.safeTransferETH(payable(feesCollectorAddress), vaultReward);
        } else {
            TransferHelper.safeTransfer(collateralToken, msg.sender, userReward);
            TransferHelper.safeTransfer(collateralToken, feesCollectorAddress, vaultReward);
        }
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
        loanForeclosingBlock[_id] = block.number;
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
        if (loanForeclosingBlock[_id] != 0) {
            uint256 bal = loanBalance[_id];
            if (bal == 0) {
                setLoanClosed(_id);
                fLock = false;
            }
            require(uint256(loanStatus[_id]) < 8, "LoanClosedOrCancelled");
            uint256 newCollRatio = getActualCollateralRatio(_id);
            uint256 reward = uint256(generalLoanFees.atRiskForeclosedMultiple).mul(loanParams[_id].rpbRate);
            uint256 userReward;
            uint256 vaultReward;
            if ( newCollRatio < generalLoansParams.instantForeclosureRatio || block.number >= loanForeclosingBlock[_id].add(generalLoansParams.foreclosureWindow) ) {
                if (bal >= reward) {
                    userReward = reward.mul(generalLoanFees.userRewardShare).div(100);
                    vaultReward = reward.mul(generalLoanFees.vaultRewardShare).div(100);
                    setLoanForeclosed(_id);
                } else {
                    userReward = bal.mul(generalLoanFees.userRewardShare).div(100);
                    vaultReward = bal.sub(userReward);
                    setLoanClosed(_id);
                }
                loanBalance[_id] = loanBalance[_id].sub(userReward).sub(vaultReward);
                result = true;
                emit LoanStatusChanged(_id, 4, uint256(loanStatus[_id]), vaultReward, userReward);
                address collateralToken = getCollateralTokenAddress(loanPair[_id]);
                if (collateralToken == address(0)) {
                    TransferHelper.safeTransferETH(msg.sender, userReward);
                    TransferHelper.safeTransferETH(payable(feesCollectorAddress), vaultReward);
                } else {
                    TransferHelper.safeTransfer(collateralToken, msg.sender, userReward);
                    TransferHelper.safeTransfer(collateralToken, feesCollectorAddress, vaultReward);
                }
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
        loanForeclosedBlock[_id] = block.number;
        loanStatus[_id] = Status.foreclosed;
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
        if (lastInterestWithdrawalBlock[_id] != 0) {
            blockAlreadyUsed = lastInterestWithdrawalBlock[_id].sub(loanActiveBlock[_id]);
            remainingBlock = (generalLoansParams.earlySettlementWindow).sub(blockAlreadyUsed);
        }
        uint256 balanceRequested = ( remainingBlock.sub(blockAlreadyUsed) ).mul(loanParams[_id].rpbRate);
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
        require(loanBorrower[_id] == msg.sender, "!borrower");
        uint256 status = setLoanStatusOnCollRatio(_id);
        require(status > 0 && status <= 3, "!Status13");
        // check that borrower gives back the loaned stable coin amount and transfer collateral to borrower
        address lentToken = getLentTokenAddress(loanPair[_id]);
        address collateralToken = getCollateralTokenAddress(loanPair[_id]);
        uint256 allowance = IERC20(lentToken).allowance(msg.sender, address(this));
        require(allowance >= loanAskAmount[_id], "!allowanceSettle");
        uint256 balanceRequested;
        if (block.number < loanActiveBlock[_id] + generalLoansParams.earlySettlementWindow)
            balanceRequested = loanEarlyClosing(_id);
        else
            balanceRequested = getAccruedInterests(_id);
        uint256 feesAmount = 0;
        if (loanStatus[_id] == Status.earlyClosing) 
            feesAmount = (generalLoanFees.earlySettlementFee).mul(loanParams[_id].rpbRate);
        
        uint256 bal = loanBalance[_id];
        uint256 requestedAmount = balanceRequested.add(feesAmount);
        loanClosingBlock[_id] = block.number;
        loanStatus[_id] = Status.closing;
        uint256 withdrawalBalance = 0;
        // check if there are enough collateral
        if (bal >= requestedAmount) {
            // borrower receives back collateral
            withdrawalBalance = bal.sub(requestedAmount); 
        }
        borrowerSendBackLentToken(_id);
        loanBalance[_id] = loanBalance[_id].sub(withdrawalBalance).sub(feesAmount);
        emit LoanStatusChanged(_id, status, uint256(loanStatus[_id]), feesAmount, withdrawalBalance);
        if (collateralToken == address(0)) {
            TransferHelper.safeTransferETH(msg.sender, withdrawalBalance);
            TransferHelper.safeTransferETH(payable(feesCollectorAddress), feesAmount);
        } else {
            TransferHelper.safeTransfer(collateralToken, msg.sender, withdrawalBalance);
            TransferHelper.safeTransfer(collateralToken, feesCollectorAddress, feesAmount);
        }
        fLock = false;
    }

    /**
    * @dev internal function to allow borrower to send back lent tokens to shareholders
    * @param _id loan id
    */
    function borrowerSendBackLentToken(uint256 _id) internal {
        address lentToken = getLentTokenAddress(loanPair[_id]);
        uint256 loanAmount = loanAskAmount[_id];
        for (uint8 i = 1; i <= shareholdersCounter[_id]; i++) {
            address shAddress = loanShareholders[_id][i].holder;
            uint256 shPlace = getShareholderPlace(_id, loanShareholders[_id][i].holder);
            uint256 shShares = loanShareholders[_id][shPlace].shares;
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
        loanClosedBlock[_id] = block.number;
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
        require(loanBorrower[_id] == msg.sender, "!borrower");
        require(uint256(loanStatus[_id]) == 0, "!Status0");
        uint256 bal = loanBalance[_id];
        uint256 feeCanc = bal.mul(generalLoanFees.cancellationFees).div(100);
        uint256 withdrawalBalance = bal.sub(feeCanc);
        loanStatus[_id] = Status.cancelled;
        loanBalance[_id] = loanBalance[_id].sub(withdrawalBalance).sub(feeCanc);
        emit LoanStatusChanged(_id, 0, uint256(loanStatus[_id]), feeCanc, withdrawalBalance);
        address collateralToken = getCollateralTokenAddress(loanPair[_id]);
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
    * @dev calculate accrued interests of the contract
    * @param _id loan id
    * @param _calcBlk block number
    * @return uint256 accrued interests
    */
    function calculatingAccruedInterests(uint256 _id, uint256 _calcBlk) public view returns (uint256) {
        require(_calcBlk >= lastInterestWithdrawalBlock[_id], "!validBlockNumber");
        return _calcBlk.sub(lastInterestWithdrawalBlock[_id]).mul(loanParams[_id].rpbRate);  
    }

    /**
    * @dev get accrued interests of the contract
    * @param _id loan id
    * @return accruedInterests total accrued interests
    */
    function getAccruedInterests(uint256 _id) public view returns (uint256 accruedInterests) {
        if (uint256(loanStatus[_id]) > 0 && uint256(loanStatus[_id]) < 8) {
            uint256 lastEarlyBlock = loanActiveBlock[_id].add(generalLoansParams.earlySettlementWindow);
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
    * @return uint256 new status
    */
    function withdrawInterests(uint256 _id) public returns (uint256) {
        require(!fLock, "locked");
        fLock = true;
        // interests of all shareholders must be withdrawn with their shares amount
        require(uint256(loanStatus[_id]) > 0 && uint256(loanStatus[_id]) < 8, "!Status17" );
        uint256 bal = loanBalance[_id];
        if (bal == 0) {
            setLoanClosed(_id);
            fLock = false;
        }
        require(uint256(loanStatus[_id]) < 8, "LoanClosedOrCancelled");
        uint256 status = uint256(loanStatus[_id]);
        uint256 accruedTotalInterests = getAccruedInterests(_id);
        if (bal >= accruedTotalInterests) {
            for (uint8 i = 1; i <= shareholdersCounter[_id]; i++) {
                shareholderWithdrawInterests(_id, loanShareholders[_id][i].holder, accruedTotalInterests);
            }
            lastInterestWithdrawalBlock[_id] = block.number;
            if (status <= 4)
                status = setLoanStatusOnCollRatio(_id);
        } else {
            for (uint8 i = 1; i <= shareholdersCounter[_id]; i++) {
                shareholderWithdrawInterests(_id, loanShareholders[_id][i].holder, bal);
            }
            lastInterestWithdrawalBlock[_id] = block.number;
            loanClosedBlock[_id] = block.number;
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
        uint256 shShares = loanShareholders[_id][shPlace].shares;
        uint256 interestsToSend = _accruedTotalInterests.mul(shShares).div(100);
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
    function isShareholder(uint256 _id, address _holder) public view returns (bool) {
        return loanShareholdersAddress[_id][_holder];
    }

    /**
    * @dev get a shareholder place in shareholders array
    * @param _id loan id
    * @param _holder shareholder address
    * @return uint256 shareholder place
    */
    function getShareholderPlace(uint256 _id, address _holder) public view returns (uint256) {
        return loanShareholdersPlace[_id][_holder];
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
        require(loanShareholders[_id][shPlace].shares >= _amount, "!enoughShares");
        //before shares could be selled, interests of all shareholders must be withdrawn with old shares amount, in order to start with a new situation
        //require(block.number > loanActiveBlock[_id] + generalLoansParams.earlySettlementWindow, "earlyWindow");
        uint256 interestsAmount = getAccruedInterests(_id);
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
            uint256 shPlaceNew = getShareholderPlace(_id, _newShareholder);
            loanShareholders[_id][shPlaceNew].shares = loanShareholders[_id][shPlaceNew].shares.add(_amount);
            loanShareholders[_id][shPlaceNew].ownerBlockNumber = block.number;
            emit AddShareholderShares(_id, _newShareholder, _amount);
        }
        lastInterestWithdrawalBlock[_id] = block.number;
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
