// SPDX-License-Identifier: MIT
/**
 * Created on 2020-11-09
 * @summary: Jibrel Loans Factory
 * @author: Jibrel Team
 */
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "./IJLoanCommons.sol";
import "./IJLoanDeployer.sol";
import "./IJLoan.sol";
import "./IJPriceOracle.sol";
import "./IJFactory.sol";

contract JFactory is Ownable, ReentrancyGuard, IJLoanCommons, IJFactory { 
    using SafeMath for uint256;

    IJLoanDeployer public loanDeplContract;
    IJPriceOracle public priceOracleContract;

    mapping(uint => address) internal deployedLoans;
    uint public loanCounter;

    mapping (address => bool) private _Admins;
 
    uint public pairNumber;

    GeneralParams public generalParams;
    FeesParams public generalFees;

    uint public factoryDeployBlock;

    event AdminAdded(address account);
    event AdminRemoved(address account);
    event NewLoanContractCreated(address indexed newLoan, uint counter);
    event SetNewStatus(uint idx, uint loanId, uint oldStatus, uint newStatus);
    
    constructor(address _loanDepl, address _priceOracle) public {
        generalParams.earlySettlementWindow = 540000;
        generalParams.foreclosureWindow = 18000;
        generalParams.requiredCollateralRatio = 200;
        generalParams.foreclosingRatio = 150;
        generalParams.instantForeclosureRatio = 120;
        generalParams.limitCollRatioForWithdraw = 160;
        generalParams.loanDeployerAddress = _loanDepl;
        loanDeplContract = IJLoanDeployer(_loanDepl);
        generalParams.priceOracleAddress = _priceOracle;
        priceOracleContract = IJPriceOracle(_priceOracle);
        generalParams.factoryAddress = address(this);
        generalFees.factoryFees = 5;
        generalFees.earlySettlementFee = 1080000; 
        generalFees.userRewardShare = 80;
        generalFees.vaultRewardShare = 20;
        generalFees.undercollateralizedForeclosingMultiple = 1000;
        generalFees.atRiskForeclosedMultiple = 3000;
        generalFees.cancellationFees = 3;
        _Admins[msg.sender] = true;
        factoryDeployBlock = block.number;
    }

    /* Modifiers */
    modifier onlyAdmins() {
        require(isAdmin(msg.sender), "Not an Admin!");
        _;
    }

    /*   Admins Roles Mngmt  */
    function _addAdmin(address account) internal {
        _Admins[account] = true;
        emit AdminAdded(account);
    }

    function _removeAdmin(address account) internal {
        _Admins[account] = false;
        emit AdminRemoved(account);
    }

    function isAdmin(address account) public override view returns (bool) {
        return _Admins[account];
    }

    function addAdmin(address account) external override onlyAdmins {
        require(account != address(0), "Not a valid address!");
        require(!isAdmin(account), " Address already Administrator");
        _addAdmin(account);
    }

    function removeAdmin(address account) external override onlyAdmins {
        _removeAdmin(account);
    }

    function renounceAdmin() external override onlyAdmins {
        _removeAdmin(msg.sender);
    }

    /**
    * @dev set a new address for pair loan deployer contract
    * @param _loanDepl new address
    */
    function setLoanDeployerAddress(address _loanDepl) external override onlyAdmins {
        require(_loanDepl != generalParams.loanDeployerAddress, "new address is the same as the old one");
        generalParams.loanDeployerAddress = _loanDepl;
        loanDeplContract = IJLoanDeployer(_loanDepl);
    }

    /**
    * @dev set a new address for pair price oracle contract
    * @param _priceOracle new address
    */
    function setPriceOracleAddress(address _priceOracle) external override onlyAdmins {
        require(_priceOracle != generalParams.priceOracleAddress, "new address is the same as the old one");
        generalParams.priceOracleAddress = _priceOracle;
        priceOracleContract = IJPriceOracle(_priceOracle);
    }

    /**
    * @dev math round up
    * @param numerator numerator
    * @param denominator denominator
    * @param precision precision
    * @return number of quote currency decimals
    */
    function roundUp(uint numerator, uint denominator, uint precision) internal pure returns (uint) {
        uint _numerator  = numerator.mul(10 ** (precision.add(1)));
        uint _quotient =  ((_numerator.div(denominator)).add(5)).div(10);
        return _quotient;
    }

    /**
    * @dev calculate fees on collateral amount
    * @param _collAmount collateral amount
    * @return amount of collateral fees
    */
    function calculateCollFeesOnActivation(uint _collAmount) public override view returns (uint) {
        return roundUp(_collAmount.mul(generalFees.factoryFees), 1000, 0);
    }

    /**
    * @dev get the amount of collateral needed to have stable coin amount (no fees)
    * @param _pairId number of the pair
    * @param _askAmount amount in stable coin the borrower would like to receive
    * @return amount of collateral the borrower needs to send
    */
    function calcMinCollateralAmount(uint _pairId, uint _askAmount) public override view returns (uint) {
        uint price = priceOracleContract.getPairValue(_pairId);
        uint pairDecimals = uint(priceOracleContract.getPairDecimals(_pairId));
        uint minCollEthAmount = roundUp(_askAmount.mul(generalParams.requiredCollateralRatio).mul(10 ** pairDecimals).div(100), price, 0);
        uint baseDecimals = uint(priceOracleContract.getPairBaseDecimals(_pairId));
        uint quoteDecimals = uint(priceOracleContract.getPairQuoteDecimals(_pairId));
        if (baseDecimals >= quoteDecimals) {
            uint diffBaseQuoteDecimals = baseDecimals.sub(quoteDecimals);
            minCollEthAmount = minCollEthAmount.mul(10 ** diffBaseQuoteDecimals).add(5); //add 5 to be sure evrything is ok
        } else {
            uint diffBaseQuoteDecimals = quoteDecimals.sub(baseDecimals);
            minCollEthAmount = minCollEthAmount.div(10 ** diffBaseQuoteDecimals).add(5); //add 5 to be sure evrything is ok
        }
        return minCollEthAmount;
    }

    /**
    * @dev get the amount of collateral needed to have stable coin amount, with fees
    * @param _pairId number of the pair
    * @param _askAmount amount in stable coin the borrower would like to receive
    * @return amount of collateral the borrower needs to send
    */
    function calcMinCollateralWithFeesAmount(uint _pairId, uint _askAmount) external override view returns (uint) {
        uint minCollEthAmount = calcMinCollateralAmount(_pairId, _askAmount);
        uint feesCollAmount = calculateCollFeesOnActivation(minCollEthAmount);
        uint totalCollAmountWithFees = minCollEthAmount.add(feesCollAmount);
        return totalCollAmountWithFees;
    }

    /**
    * @dev set GeneralParams
    * @param _value set new param
    */
    function setEarlySettlementWindow(uint _value) external override onlyOwner {
        generalParams.earlySettlementWindow = _value;
    }

    /**
    * @dev set GeneralParams
    * @param _value set new param
    */
    function setForeclosureWindow(uint _value) external override onlyOwner {
        generalParams.foreclosureWindow = _value;
    }

    function setForeclosureRatio(uint8 _value) external override onlyOwner {
        generalParams.foreclosingRatio = _value;
    }

    /**
    * @dev set GeneralParams
    * @param _value set new param
    */
    function setInstantForeclosureRatio(uint8 _value) external override onlyOwner {
        generalParams.instantForeclosureRatio = _value;
    }

    /**
    * @dev set GeneralParams
    * @param _value set new param
    */
    function setRequiredCollateralRatio(uint8 _value) external override onlyOwner {
        generalParams.requiredCollateralRatio = _value;
    }

    /**
    * @dev set GeneralParams
    * @param _value set new param
    */
    function setFactoryFees(uint8 _value) external override onlyOwner {
        generalFees.factoryFees = _value;
    }

    /**
    * @dev set GeneralParams
    * @param _value set new param
    */
    function setEarlySettlementFee(uint _value) external override onlyOwner {
        generalFees.earlySettlementFee = _value;
    }

    /**
    * @dev set GeneralParams
    * @param _value set new param
    */
    function setUserRewardShare(uint8 _value) external override onlyOwner {
        generalFees.userRewardShare = _value;
    }

    /**
    * @dev set GeneralParams
    * @param _value set new param
    */
    function setVaultShares(uint8 _value) external override onlyOwner {
        generalFees.vaultRewardShare = _value;
    }

    /**
    * @dev set GeneralParams
    * @param _value set new param
    */
    function setUndercollateralizedForeclosingMultiple(uint16 _value) external override onlyOwner {
        generalFees.undercollateralizedForeclosingMultiple = _value;
    }

    /**
    * @dev set GeneralParams
    * @param _value set new param
    */
    function setAtRiskForeclosedMultiple(uint16 _value) external override onlyOwner {
        generalFees.atRiskForeclosedMultiple = _value;
    }

    /**
    * @dev set GeneralParams
    * @param _value set new param
    */
    function setCancellationFees(uint8 _value) external override onlyOwner {
        generalFees.cancellationFees = _value;
    }

    /**
    * @dev get all general GeneralParams
    * @return param struct
    */
    function getGeneralParams() external override view returns (GeneralParams memory) {
        return generalParams;
    }

    /**
    * @dev get all general GeneralParams
    * @return param struct
    */
    function getGeneralFees() external override view returns (FeesParams memory) {
        return generalFees;
    }

    /**
    * @dev create a new loan contract and set the address in the mapping
    * @return address of the new contract
    */
    function createNewLoanContract() external override nonReentrant onlyAdmins returns (address) {
        address newTokenLoan = loanDeplContract.deployNewLoanContract(address(this));
        deployedLoans[loanCounter] = newTokenLoan;
        emit NewLoanContractCreated(newTokenLoan, loanCounter);
        loanCounter = loanCounter.add(1);
        return newTokenLoan;
    }

    /**
    * @dev get all deployers addresses
    * @return addresses of the deployer
    */
    function getLoanDeployer() external override view returns(address) {
        return address(loanDeplContract);
    }

    /**
    * @dev get a single loan address deployed by the factory
    * @param _idx deployed loan index
    * @return loan contract address
    */
    function getDeployedLoan(uint _idx) external override view returns (address) {
        return deployedLoans[_idx];
    }

        /**
    * @dev set new common GeneralParams in single eth loans contract
    * @param _idx, index of the loan pair contract
    */
    function setLoanGeneralParamsInContract(uint _idx) external override onlyOwner {
        IJLoan(deployedLoans[_idx]).setNewGeneralLoansParams();
    }

    /**
    * @dev set new fees GeneralParams in single eth loans contract
    * @param _idx, index of the loan pair contract
    */
    function setLoanFeesParamsInContract(uint _idx) external override onlyOwner {
        IJLoan(deployedLoans[_idx]).setNewFeesParams();
    }

        /**
    * @dev set new status in single eth loans contract
    * @param _idx, index of the loan contract
    * @param _loanId loan id
    * @param _newStatus, new status
    */
    function setStatusInLoan (uint _idx, uint _loanId, uint _newStatus) external override nonReentrant onlyOwner {
        require(_newStatus <= 7, "!Status07");
        IJLoan jContract = IJLoan(deployedLoans[_idx]);
        uint oldStatus = jContract.getLoanStatus(_loanId);
        require(_newStatus != oldStatus, "!newStatus");
        jContract.setNewStatus(_loanId, _newStatus);
        uint newStatus = jContract.getLoanStatus(_loanId);
        emit SetNewStatus(_idx, _loanId, oldStatus, newStatus);
    }

    /**
    * @dev adjust for decimals in tokens pair for ratio
    * @param _pairId pair Id
    * @param _numerator numerator
    * @param _quotient quotient
    * @return result of operation
    */
    function adjustDecimalsRatio(uint _pairId, uint _numerator, uint _quotient) internal view returns (uint result) {
        uint collDecimals = uint(priceOracleContract.getPairBaseDecimals(_pairId));
        uint lendDecimals = uint(priceOracleContract.getPairQuoteDecimals(_pairId));
        if (collDecimals >= lendDecimals) {
            uint diffBaseQuoteDecimals = collDecimals.sub(lendDecimals);
            result = _numerator.mul(10 ** diffBaseQuoteDecimals).div(_quotient);
        } else {
            uint diffBaseQuoteDecimals = lendDecimals.sub(collDecimals);
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
    function adjustDecimalsCollateral(uint _pairId, uint _numerator, uint _quotient) public override view returns (uint result) {
        uint collDecimals = uint(priceOracleContract.getPairBaseDecimals(_pairId));
        uint lendDecimals = uint(priceOracleContract.getPairQuoteDecimals(_pairId));
        if (collDecimals >= lendDecimals) {
            uint diffBaseQuoteDecimals = collDecimals.sub(lendDecimals);
            result = _numerator.div(_quotient).div(10 ** diffBaseQuoteDecimals);
        } else {
            uint diffBaseQuoteDecimals = lendDecimals.sub(collDecimals);
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
    function ratioDiffCollAmount(uint _pairId, uint _ratio, uint _borrAmount, uint _balance) external override view returns (uint collDiff) {
        uint price = priceOracleContract.getPairValue(_pairId);
        uint pairDecimals = uint(priceOracleContract.getPairDecimals(_pairId));
        uint numerator = _borrAmount.mul(_ratio).mul(10 ** pairDecimals);
        uint quotient = price.mul(100);
        uint newBal = adjustDecimalsRatio(_pairId, numerator, quotient);
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
    function collateralAdjustingRatio(uint _pairId, uint _borrAmount, uint _balance, uint _newAmount, bool _adding) external override view returns (uint ratio) {
        uint actualPrice = priceOracleContract.getPairValue(_pairId);
        uint pairDecimals = uint(priceOracleContract.getPairDecimals(_pairId));
        uint newLoanBal;
        if (_adding)
            newLoanBal = _balance.add(_newAmount);
        else {
            if (_newAmount < _balance)
                newLoanBal = _balance.sub(_newAmount);
            else 
                return 0;
        }
        uint numerator = newLoanBal.mul(actualPrice).mul(100);
        uint quotient = _borrAmount.mul(10 ** pairDecimals);
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
    function getCollateralRatio(uint _pairId, uint _borrAmount, uint _balance) external override view returns (uint newCollRatio) {
        uint newPrice = priceOracleContract.getPairValue(_pairId);
        uint pairDecimals = uint(priceOracleContract.getPairDecimals(_pairId));
        uint numerator = _balance.mul(newPrice).mul(100);
        uint quotient = _borrAmount.mul(10 ** pairDecimals);
        newCollRatio = adjustDecimalsCollateral(_pairId, numerator, quotient);
        return newCollRatio;
    }
    
}
