// SPDX-License-Identifier: MIT
/**
 * Created on 2020-11-09
 * @summary: Jibrel Loans
 * @author: Jibrel Team
 */
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts-ethereum-package/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts-ethereum-package/contracts/math/Math.sol";
import "@openzeppelin/contracts-ethereum-package/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts-ethereum-package/contracts/access/Ownable.sol";
import "./IJLoanCommons.sol";
import "./IJLoan.sol";
import "./IJFactory.sol";
import "./TransferHelper.sol";
import "./IJPriceOracle.sol";

contract JLoan is OwnableUpgradeSafe, IJLoanCommons, IJLoan {
    using SafeMath for uint;

    address public feesCollector;
    
    mapping(address => bool) public borrowers;
    mapping(uint => address) public loanBorrower;
    mapping(uint => uint) public loanPair;
    mapping(uint => uint) public loanBalance;
    mapping(uint => uint) public loanAskAmount;

    uint public loanId;
    bool public fLock;
    bool public fLockAux;

    GeneralParams public generalLoansParams;
    FeesParams public loanFees;
    mapping (uint => ContractParams) public loanParams;
    mapping (uint => Status) public loanStatus;
    
    mapping(uint => uint) public loanActiveBlock;
    mapping(uint => uint) public loanLastDepositBlock;
    mapping(uint => uint) public loanLastWithdrawBlock;
    mapping(uint => uint) public loanInitiateForecloseBlock;
    mapping(uint => uint) public loanClosingBlock;
    mapping(uint => uint) public loanClosedBlock;
    mapping(uint => uint) public lastInterestWithdrawalBlock;
    mapping(uint => uint) public loanForeclosingBlock;
    mapping(uint => uint) public loanForeclosedBlock;

    struct Shareholder {
        address holder;
        uint shares;
        uint ownerBlockNumber;
    }

    mapping(uint => mapping(uint => Shareholder)) public loanShareholders;
    mapping(uint => mapping(address => bool)) public loanShareholdersAddress;
    mapping(uint => mapping(address => uint)) public loanShareholdersPlace;
    mapping(uint => uint) public shareholdersCounter;

    event CollateralReceived(uint id, uint pairId, address sender, uint value, uint status);
    event WithdrawCollateral(uint id, uint amount);
    event LoanStatusChanged(uint id, uint oldStatus, uint newStatus, uint collectorAmnt, uint userAmnt);
    event AddShareholderShares(uint id, address indexed sharesBuyer, uint indexed amount);
    event InterestsWithdrawed(uint id, uint accruedInterests);

    function initialize(address _factoryAddress, address _feesCollector) public initializer() {
        OwnableUpgradeSafe.__Ownable_init();
        generalLoansParams = IJFactory(_factoryAddress).getGeneralParams();
        loanFees = IJFactory(_factoryAddress).getGeneralFees();
        feesCollector = payable(_feesCollector);
    }

    modifier onlyLoanFactory() {
        require(msg.sender == generalLoansParams.factoryAddress, "!factory");
        _;
    }

    fallback() external { // cannot deposit eth
        revert("ETH not accepted!");
    }

    /**
    * @dev get collateral token address, reading them from price oracle
    * @param _pairId pairId
    * @return address of the collateral token
    */
    function getCollateralTokenAddress(uint _pairId) public override view returns (address) {
        return IJPriceOracle(generalLoansParams.priceOracleAddress).getPairBaseAddress(_pairId);
    }

    /**
    * @dev get lent token address, reading them from price oracle
    * @param _pairId pairId
    * @return address of the lent token
    */
    function getLentTokenAddress(uint _pairId) public override view returns (address) {
        return IJPriceOracle(generalLoansParams.priceOracleAddress).getPairQuoteAddress(_pairId);
    }

    /**
    * @dev open a new eth loan with msg.value amount of collateral
    * @param _pairId pair Id
    * @param _borrowedAskAmount ERC20 address
    * @param _rpbRate token amount
    */
    function openNewLoan(uint _pairId, uint _borrowedAskAmount, uint _rpbRate) external override payable {
        require(!fLock, "locked");
        fLock = true;
        require(msg.sender!=address(0), "_senderZeroAddress");
        uint256 totalCollateralRequest = IJFactory(generalLoansParams.factoryAddress).calcMinCollateralWithFeesAmount(_pairId, _borrowedAskAmount);
        uint collAmount;
        uint allowance = 0;
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
        emit CollateralReceived(loanId, _pairId, msg.sender, collAmount, uint(loanStatus[loanId]));
        loanId = loanId.add(1);
        if (collateralToken != address(0))
            TransferHelper.safeTransferFrom(collateralToken, msg.sender, address(this), totalCollateralRequest);
        fLock = false;
    }

    /**
    * @dev get loan id conuter
    * @return uint loan counter
    */
    function getLoansCounter() external override view returns (uint) {
        return loanId;
    }

    //// Utility functions
    /**
    * @dev set common parameters in loan contract, reading them from factory
    */
    function setNewGeneralLoansParams() external override onlyLoanFactory {
        generalLoansParams = IJFactory(generalLoansParams.factoryAddress).getGeneralParams();
    }

    /**
    * @dev set common parameters in loan contract, reading them from factory
    */
    function setNewFeesParams() external override onlyLoanFactory {
        loanFees = IJFactory(generalLoansParams.factoryAddress).getGeneralFees();
    }

    /**
    * @dev deposit collateral
    * @param _id loan id
    */
    function depositEthCollateral(uint _id) external override payable {
        require(!fLock, "locked");
        fLock = true;
        require(getCollateralTokenAddress(loanPair[_id]) == address(0), "!ETHLoan");
        require(loanStatus[_id] <= Status.foreclosing, "!Status04");
        loanBalance[_id] = loanBalance[_id].add(msg.value);
        loanLastDepositBlock[_id] = block.number;
        uint status = setLoanStatusOnCollRatio(_id);
        emit CollateralReceived(_id, loanPair[_id], msg.sender, msg.value, status);
        fLock = false;
    }

    /**
    * @dev deposit collateral tokens
    * @param _id loan id
    * @param _tok ERC20 address
    * @param _amount token amount
    */
    function depositTokenCollateral(uint _id, address _tok, uint _amount) external override {
        require(!fLock, "locked");
        fLock = true;
        address collateralToken = getCollateralTokenAddress(loanPair[_id]);
        require(collateralToken != address(0), "!TokenLoan");
        require(loanStatus[_id] <= Status.foreclosing, "!Status04");
        require(collateralToken == address(_tok), "!collToken" );
        uint allowance = IERC20(collateralToken).allowance(msg.sender, address(this));
        require(allowance >= _amount, "!allowance");
        loanBalance[_id] = loanBalance[_id].add(_amount);
        loanLastDepositBlock[_id] = block.number;
        uint status = setLoanStatusOnCollRatio(_id);
        emit CollateralReceived(_id, loanPair[_id], msg.sender, _amount, status);
        TransferHelper.safeTransferFrom(_tok, msg.sender, address(this), _amount);
        fLock = false;
    }

    /**
    * @dev withdraw ethers from contract
    * @param _id loan id
    * @param _amount eth amount
    */
    function withdrawCollateral(uint _id, uint _amount) external override {
        require(!fLock, "locked");
        fLock = true;
        require(loanBorrower[_id] == msg.sender, "!borrower");
        uint status = setLoanStatusOnCollRatio(_id);
        require(status <= 1, "!Status01");
        uint withdrawalAmount = calcDiffCollAmountForRatio(_id, generalLoansParams.limitCollRatioForWithdraw);
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
    function getContractBalance(uint _id) external override view returns (uint) {
        address collateralToken = getCollateralTokenAddress(loanPair[_id]);
        if (collateralToken == address(0))
            return address(this).balance;
        else
            return IERC20(collateralToken).balanceOf(address(this));
    }

    /**
    * @dev get single loan balance
    * @param _id loan id
    * @return uint balance of single loan
    */
    function getLoanBalance(uint _id) public override view returns (uint) {
        return loanBalance[_id];
    }   

    /**
    * @dev get single loan status
    * @param _id loan id
    * @return uint balance of single loan
    */
    function getLoanStatus(uint _id) external override view returns (uint) {
        return uint(loanStatus[_id]);
    }

    /**
    * @dev set single loan status
    * @param _id loan id
    * @param _newStatus new loan status
    */
    function setNewStatus(uint _id, uint _newStatus) external override onlyLoanFactory {
        loanStatus[_id] = IJLoanCommons.Status(_newStatus);
    }

    /**
    * @dev check if loan is in early settlement period
    * @param _id loan id
    * @return boolean
    */
    function checkLoanInEarlySettlementWindow(uint _id) external override view returns (bool) {
        uint lastEarlyBlock = loanActiveBlock[_id].add(generalLoansParams.earlySettlementWindow);
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
    function checkEarlySettledLoan(uint _id) external override view returns (bool) {
        return loanStatus[_id] == Status.earlyClosing;
    }

    /**
    * @dev set initial collateral ratio of the loan
    * @param _id loan id
    */
    function setInitalCollateralRatio(uint _id) external override {
        if (loanStatus[_id] == Status.pending)
            loanParams[_id].initialCollateralRatio = getActualCollateralRatio(_id);
    }

    /**
    * @dev get the collateral ratio of the loan (subtracting the accrued interests)
    * @param _id loanId
    * @return newCollRatio collateral ratio
    */
    function getActualCollateralRatio(uint _id) public override view returns (uint newCollRatio) {
        uint borrAmnt = loanAskAmount[_id];
        uint loanBalanceId;
        if (loanStatus[_id] == Status.pending)
            loanBalanceId = getLoanBalance(_id);
        else
            loanBalanceId = getLoanBalance(_id).sub(getAccruedInterests(_id));
        newCollRatio = IJFactory(generalLoansParams.factoryAddress).getCollateralRatio(loanPair[_id], borrAmnt, loanBalanceId);
        return newCollRatio;
    }

    /**
    * @dev calc a new ratio if collateral amount has added to contract balance
    * @param _id loanId
    * @param _amount collateral amount to add
    * @param _adding bool, true if _amount is added, false if amount is removed to loan
    * @return ratio new collateral ratio, percentage with no decimals
    */
    function calcRatioAdjustingCollateral(uint _id, uint _amount, bool _adding) external override view returns (uint ratio) {
        uint borrAmnt = loanAskAmount[_id];
        uint loanBalanceId = getLoanBalance(_id);
        ratio = IJFactory(generalLoansParams.factoryAddress).collateralAdjustingRatio(loanPair[_id], borrAmnt, loanBalanceId, _amount, _adding);
        return ratio;
    }

    /**
    * @dev calc how much collateral amount has to be added to have a ratio
    * @param _id loanId
    * @param _ratio ratio to reach, percentage with no decimals (180 means 180%)
    * @return collDiff collateral amount to add or to subtract to reach that ratio
    */
    function calcDiffCollAmountForRatio(uint _id, uint _ratio) public override view returns (uint collDiff) {
        uint borrAmnt = loanAskAmount[_id];
        uint loanBalanceId = getLoanBalance(_id);
        collDiff = IJFactory(generalLoansParams.factoryAddress).ratioDiffCollAmount(loanPair[_id], _ratio, borrAmnt, loanBalanceId);
        return collDiff;
    }

    //// Status 0 -> 1
    /**
    * @dev lender sends required stable coins to borrower and set the initial lender as a stakeholder (100%)
    * @param _id loan id
    * @param _stableAddr, address of the stabl coin address
    */
    function lenderSendStableCoins(uint _id, address _stableAddr) external override {
        require(!fLock, "locked");
        fLock = true;
        address collateralToken = getCollateralTokenAddress(loanPair[_id]);
        address lentToken = getLentTokenAddress(loanPair[_id]);
        require(_stableAddr == lentToken, "!TokenOk");
        require(loanStatus[_id] == Status.pending, "!Status0");
        uint actualRatio = getActualCollateralRatio(_id);
        require(actualRatio >= generalLoansParams.limitCollRatioForWithdraw, "!EnoughCollateral");
        uint allowance = IERC20(lentToken).allowance(msg.sender, address(this));
        require(allowance >= loanAskAmount[_id], "!allowance");
        shareholdersCounter[_id] = 1;
        loanShareholders[_id][shareholdersCounter[_id]] = Shareholder({holder: msg.sender, shares: 100, ownerBlockNumber: loanActiveBlock[_id]});
        loanShareholdersAddress[_id][msg.sender] = true;
        loanShareholdersPlace[_id][msg.sender] = shareholdersCounter[_id];
        loanStatus[_id] = Status.active;
        loanActiveBlock[_id] = block.number;
        lastInterestWithdrawalBlock[_id] = block.number;
        // move factory fees only when loan becomes active
        uint minCollateral = IJFactory(generalLoansParams.factoryAddress).calcMinCollateralAmount(loanPair[_id], loanAskAmount[_id]);
        uint fees4Factory = IJFactory(generalLoansParams.factoryAddress).calculateCollFeesOnActivation(minCollateral); // 5/1000 = 0,5%
        loanBalance[_id] = loanBalance[_id].sub(fees4Factory);
        emit LoanStatusChanged(_id, 0, uint(loanStatus[_id]), fees4Factory, 0);
        TransferHelper.safeTransferFrom(lentToken, msg.sender, loanBorrower[_id], loanAskAmount[_id]);
        if (collateralToken == address(0))
            TransferHelper.safeTransferETH(payable(feesCollector), fees4Factory);
        else
            TransferHelper.safeTransfer(collateralToken, feesCollector, fees4Factory);
        fLock = false;
    }

    //// Status 1 or 2 or 3 or 4, based on collateral ratio
    /**
    * @dev set the status of the loan based on collateral ratio, applied only in states allowed 
    * @param _id loan id
    * @return loan status
    */
    function setLoanStatusOnCollRatio(uint _id) public override returns (uint) {
        uint newCollRatio = getActualCollateralRatio(_id); // (i.e. 180 means 180%)
        uint oldStatus = uint(loanStatus[_id]);
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
        emit LoanStatusChanged(_id, oldStatus, uint(loanStatus[_id]), 0, 0);
        return uint(loanStatus[_id]);
    }

    //// Status 4 or 5, starting from 2 or 3, depending on collateral ratio
    /**
    * @dev set the loan in foreclosure state for undercollateralized loans
    * @param _id loan id
    */
    function initiateLoanForeclose(uint _id) external override {
        require(!fLock, "locked");
        fLock = true;
        uint status = setLoanStatusOnCollRatio(_id);
        require(status == 2 || status == 3, "!Status23");
        uint reward;
        if (status == 2) {
            reward = uint(loanFees.undercollateralizedForeclosingMultiple).mul(loanParams[_id].rpbRate);
            setLoanForeclosing(_id);
        } else {
            reward = uint(loanFees.atRiskForeclosedMultiple).mul(loanParams[_id].rpbRate);
            setLoanForeclosed(_id);
        }
        uint bal = loanBalance[_id];
        loanInitiateForecloseBlock[_id] = block.number;
        uint userReward;
        uint vaultReward;
        if (bal >= reward) {
            userReward = reward.mul(loanFees.userRewardShare).div(100);
            vaultReward = reward.mul(loanFees.vaultRewardShare).div(100);
        } else {
            userReward = bal.mul(loanFees.userRewardShare).div(100);
            vaultReward = bal.sub(userReward);
            setLoanClosed(_id);
        }
        loanBalance[_id] = loanBalance[_id].sub(userReward).sub(vaultReward);
        emit LoanStatusChanged(_id, status, uint(loanStatus[_id]), vaultReward, userReward);
        address collateralToken = getCollateralTokenAddress(loanPair[_id]);
        if (collateralToken == address(0)) {
            TransferHelper.safeTransferETH(msg.sender, userReward);
            TransferHelper.safeTransferETH(payable(feesCollector), vaultReward);
        } else {
            TransferHelper.safeTransfer(collateralToken, msg.sender, userReward);
            TransferHelper.safeTransfer(collateralToken, feesCollector, vaultReward);
        }
        fLock = false;
    }

    //// Status 2 -> 4
    /**
    * @dev set the loan in foreclosure state for undercollateralized loans
    * @param _id loan id
    */
    function setLoanForeclosing(uint _id) internal {
        loanStatus[_id] = Status.foreclosing;
        // get the block to calculate time to set it in foreclosed if no actions from the borrower
        loanForeclosingBlock[_id] = block.number;
    }

    /**
    * @dev set the loan in foreclosed state when foreclosureWindow time passed or collateral ratio is at risk
    * @param _id loan id
    * @return bool 
    */
    function setLoanToForeclosed(uint _id) external override returns (bool) {
        require(!fLock, "locked");
        fLock = true;
        require(uint(loanStatus[_id]) == 4, "!Status4");
        bool result = false;
        if (loanForeclosingBlock[_id] != 0) {
            uint newCollRatio = getActualCollateralRatio(_id);
            uint reward = uint(loanFees.atRiskForeclosedMultiple).mul(loanParams[_id].rpbRate);
            uint bal = loanBalance[_id];
            uint userReward;
            uint vaultReward;
            if ( newCollRatio < generalLoansParams.instantForeclosureRatio || block.number >= loanForeclosingBlock[_id].add(generalLoansParams.foreclosureWindow) ) {
                if (bal >= reward) {
                    userReward = reward.mul(loanFees.userRewardShare).div(100);
                    vaultReward = reward.mul(loanFees.vaultRewardShare).div(100);
                    setLoanForeclosed(_id);
                } else {
                    userReward = bal.mul(loanFees.userRewardShare).div(100);
                    vaultReward = bal.sub(userReward);
                    setLoanClosed(_id);
                }
                loanBalance[_id] = loanBalance[_id].sub(userReward).sub(vaultReward);
                result = true;
                emit LoanStatusChanged(_id, 4, uint(loanStatus[_id]), vaultReward, userReward);
                address collateralToken = getCollateralTokenAddress(loanPair[_id]);
                if (collateralToken == address(0)) {
                    TransferHelper.safeTransferETH(msg.sender, userReward);
                    TransferHelper.safeTransferETH(payable(feesCollector), vaultReward);
                } else {
                    TransferHelper.safeTransfer(collateralToken, msg.sender, userReward);
                    TransferHelper.safeTransfer(collateralToken, feesCollector, vaultReward);
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
    function setLoanForeclosed(uint _id) internal {
        loanForeclosedBlock[_id] = block.number;
        loanStatus[_id] = Status.foreclosed;
    }

    //// Status = 6
    /**
    * @dev set the loan in early closing state
    * @param _id loan id
    * @return uint requested balance
    */
    function loanEarlyClosing(uint _id) internal returns (uint) {
        loanStatus[_id] = Status.earlyClosing;
        uint remainingBlock = generalLoansParams.earlySettlementWindow;
        uint blockAlreadyUsed = 0;
        if (lastInterestWithdrawalBlock[_id] != 0) {
            blockAlreadyUsed = lastInterestWithdrawalBlock[_id].sub(loanActiveBlock[_id]);
            remainingBlock = (generalLoansParams.earlySettlementWindow).sub(blockAlreadyUsed);
        }
        uint balanceRequested = ( remainingBlock.sub(blockAlreadyUsed) ).mul(loanParams[_id].rpbRate);
        return balanceRequested;
    }

    //// Status = 7
    /**
    * @dev settle the loan in normal closing state by borrower
    * @param _id loan id
    */
    function loanClosingByBorrower(uint _id) external override {
        require(!fLock, "locked");
        fLock = true;
        require(loanBorrower[_id] == msg.sender, "!borrower");
        uint status = setLoanStatusOnCollRatio(_id);
        require(status > 0 && status <= 3, "!Status13");
        // check that borrower gives back the loaned stable coin amount and transfer collateral to borrower
        address lentToken = getLentTokenAddress(loanPair[_id]);
        address collateralToken = getCollateralTokenAddress(loanPair[_id]);
        uint allowance = IERC20(lentToken).allowance(msg.sender, address(this));
        require(allowance >= loanAskAmount[_id], "!allowanceSettle");
        uint balanceRequested;
        if (block.number < loanActiveBlock[_id] + generalLoansParams.earlySettlementWindow)
            balanceRequested = loanEarlyClosing(_id);
        else
            balanceRequested = getAccruedInterests(_id);
        uint feesAmount = 0;
        if (loanStatus[_id] == Status.earlyClosing) 
            feesAmount = (loanFees.earlySettlementFee).mul(loanParams[_id].rpbRate);
        
        uint bal = loanBalance[_id];
        uint requestedAmount = balanceRequested.add(feesAmount);
        loanClosingBlock[_id] = block.number;
        loanStatus[_id] = Status.closing;
        uint withdrawalBalance = 0;
        // check if there are enough collateral
        if (bal >= requestedAmount) {
            // borrower receives back collateral
            withdrawalBalance = bal.sub(requestedAmount); 
        }
        borrowerSendBackLentToken(_id);
        loanBalance[_id] = loanBalance[_id].sub(withdrawalBalance).sub(feesAmount);
        emit LoanStatusChanged(_id, status, uint(loanStatus[_id]), feesAmount, withdrawalBalance);
        if (collateralToken == address(0)) {
            TransferHelper.safeTransferETH(msg.sender, withdrawalBalance);
            TransferHelper.safeTransferETH(payable(feesCollector), feesAmount);
        } else {
            TransferHelper.safeTransfer(collateralToken, msg.sender, withdrawalBalance);
            TransferHelper.safeTransfer(collateralToken, feesCollector, feesAmount);
        }
        fLock = false;
    }

    /**
    * @dev internal function to allow borrower to send back lent tokens to shareholders
    * @param _id loan id
    */
    function borrowerSendBackLentToken(uint _id) internal {
        address lentToken = getLentTokenAddress(loanPair[_id]);
        uint loanAmount = loanAskAmount[_id];
        for (uint8 i = 1; i <= shareholdersCounter[_id]; i++) {
            address shAddress = loanShareholders[_id][i].holder;
            uint shPlace = getShareholderPlace(_id, loanShareholders[_id][i].holder);
            uint shShares = loanShareholders[_id][shPlace].shares;
            uint shAmount = loanAmount.mul(shShares).div(100);
            TransferHelper.safeTransferFrom(lentToken, msg.sender, shAddress, shAmount);
        }
    }

    //// Status = 8
    /**
    * @dev set the loan in closed state, let shareholders to withdraw the stable coins back
    * @param _id loan id
    */
    function setLoanClosed(uint _id) internal {
        loanClosedBlock[_id] = block.number;
        loanStatus[_id] = Status.closed;
    }

    //// Status = 9
    /**
    * @dev set the loan in cancelled state (only if pending)
    * @param _id loan id
    */
    function setLoanCancelled(uint _id) external override {
        require(!fLock, "locked");
        fLock = true;
        require(loanBorrower[_id] == msg.sender, "!borrower");
        require(uint(loanStatus[_id]) == 0, "!Status0");
        uint bal = loanBalance[_id];
        uint feeCanc = bal.mul(loanFees.cancellationFees).div(100);
        uint withdrawalBalance = bal.sub(feeCanc);
        loanStatus[_id] = Status.cancelled;
        loanBalance[_id] = loanBalance[_id].sub(withdrawalBalance).sub(feeCanc);
        emit LoanStatusChanged(_id, 0, uint(loanStatus[_id]), feeCanc, withdrawalBalance);
        address collateralToken = getCollateralTokenAddress(loanPair[_id]);
        if (collateralToken == address(0)) {
            TransferHelper.safeTransferETH(payable(feesCollector), feeCanc);
            TransferHelper.safeTransferETH(msg.sender, withdrawalBalance);
        } else {
            TransferHelper.safeTransfer(collateralToken, feesCollector, feeCanc);
            TransferHelper.safeTransfer(collateralToken, msg.sender, withdrawalBalance);
        }
        fLock = false;
    }


    //// Calculating interests functions
    /**
    * @dev calculate accrued interests of the contract
    * @param _id loan id
    * @param _calcBlk block number
    * @return uint accrued interests
    */
    function calculatingAccruedInterests(uint _id, uint _calcBlk) public override view returns (uint) {
        require(_calcBlk >= lastInterestWithdrawalBlock[_id], "!validBlockNumber");
        return _calcBlk.sub(lastInterestWithdrawalBlock[_id]).mul(loanParams[_id].rpbRate);  
    }

    /**
    * @dev get accrued interests of the contract
    * @param _id loan id
    * @return accruedInterests total accrued interests
    */
    function getAccruedInterests(uint _id) public override view returns (uint accruedInterests) {
        if (uint(loanStatus[_id]) > 0 && uint(loanStatus[_id]) < 8) {
            uint lastEarlyBlock = loanActiveBlock[_id].add(generalLoansParams.earlySettlementWindow);
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
    * @return uint new status
    */
    function withdrawInterests(uint _id) public override returns (uint) {
        require(!fLock, "locked");
        fLock = true;
        // interests of all shareholders must be withdrawn with their shares amount
        require(uint(loanStatus[_id]) > 0 && uint(loanStatus[_id]) < 8, "!Status17" );
        uint status = uint(loanStatus[_id]);
        uint bal = loanBalance[_id];
        uint accruedTotalInterests = getAccruedInterests(_id);
        if (bal >= accruedTotalInterests) {
            for (uint8 i = 1; i <= shareholdersCounter[_id]; i++) {
                shareholderWithdrawInterests(_id, loanShareholders[_id][i].holder, accruedTotalInterests);
            }
            lastInterestWithdrawalBlock[_id] = block.number;
            if (status <= 4)
                status = setLoanStatusOnCollRatio(_id);
        } else if (bal == 0 && isShareholder(_id, msg.sender)) {
            setLoanClosed(_id);
        } else {
            for (uint8 i = 1; i <= shareholdersCounter[_id]; i++) {
                shareholderWithdrawInterests(_id, loanShareholders[_id][i].holder, bal);
            }
            lastInterestWithdrawalBlock[_id] = block.number;
            loanClosedBlock[_id] = block.number;
            loanStatus[_id] = Status.closed;
            status = uint(loanStatus[_id]);
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
    function withdrawInterestsMassive(uint[] memory _id) external override returns (bool success) {
        require(_id.length <= 100, "TooMuchLoans");
        require(!fLockAux, "Locked");
        fLockAux = true;
        for (uint8 j = 0; j < _id.length; j++) {
            uint presentId = _id[j];
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
    function shareholderWithdrawInterests(uint _id, address _shareholder, uint _accruedTotalInterests) internal {
        require(isShareholder(_id, _shareholder), "!shareholder"); 
        uint shPlace = getShareholderPlace(_id, _shareholder);
        uint shShares = loanShareholders[_id][shPlace].shares;
        uint interestsToSend = _accruedTotalInterests.mul(shShares).div(100);
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
    function isShareholder(uint _id, address _holder) public override view returns (bool) {
        return loanShareholdersAddress[_id][_holder];
    }

    /**
    * @dev get a shareholder place in shareholders array
    * @param _id loan id
    * @param _holder shareholder address
    * @return uint shareholder place
    */
    function getShareholderPlace(uint _id, address _holder) public override view returns (uint) {
        return loanShareholdersPlace[_id][_holder];
    }

    /**
    * @dev add shareholder in shareholders arrays
    * @param _id loan id
    * @param _newShareholder buyer address
    * @param _amount amount of shares
    * @return uint new status
    */
    function addLoanShareholders(uint _id, address _newShareholder, uint _amount) public override returns (uint) {
        require(!fLock, "locked");
        fLock = true;
        require(isShareholder(_id, msg.sender), "!shareholder");
        uint shPlace = getShareholderPlace(_id, msg.sender);
        require(shPlace > 0, "!shPlace");
        require(loanShareholders[_id][shPlace].shares >= _amount, "!enoughShares");
        //before shares could be selled, interests of all shareholders must be withdrawn with old shares amount, in order to start with a new situation
        //require(block.number > loanActiveBlock[_id] + generalLoansParams.earlySettlementWindow, "earlyWindow");
        uint interestsAmount = getAccruedInterests(_id);
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
            uint shPlaceNew = getShareholderPlace(_id, _newShareholder);
            loanShareholders[_id][shPlaceNew].shares = loanShareholders[_id][shPlaceNew].shares.add(_amount);
            loanShareholders[_id][shPlaceNew].ownerBlockNumber = block.number;
            emit AddShareholderShares(_id, _newShareholder, _amount);
        }
        lastInterestWithdrawalBlock[_id] = block.number;
        uint status = setLoanStatusOnCollRatio(_id);
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
    function addLoanShareholdersMassive(uint _id, address[] memory _newShareholder, uint[] memory _amount) external override returns (bool success) {
        require(_newShareholder.length <= 100, "TooMuchShareholders");
        require(_newShareholder.length == _amount.length, "!sameLength");
        require(!fLockAux, "Locked");
        fLockAux = true;
        for (uint8 j = 0; j < _newShareholder.length; j++) {
            address presentSH = _newShareholder[j];
            uint presentAmnt = _amount[j];
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
    function addShareholderToMultipleLoans(uint[] memory _ids, address _newShareholder, uint[] memory _amounts) external override returns (bool success) {
        require(_newShareholder.length <= 100, "TooMuchShareholders");
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
