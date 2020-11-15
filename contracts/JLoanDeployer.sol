// SPDX-License-Identifier: MIT
/**
 * Created on 2020-11-09
 * @summary: Jibrel Loan Deployer
 * @author: Jibrel Team
 */
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./IJFactory.sol";
import "./IJLoanCommons.sol";
import "./JLoan.sol";
import "./IJLoanDeployer.sol";

contract JLoanDeployer is Ownable, IJLoanDeployer {
    address private feesCollector;

    IJLoanCommons.GeneralParams public loanParams;

    constructor() public { }

    modifier onlyLoanFactory() {
        require(msg.sender == loanParams.factoryAddress, "!factory");
        _;
    }

    /**
    * @dev set loan factory contract address
    * @param _factAddr, address of loan factory contract to add
    */
    function setLoanFactory(address _factAddr) external override onlyOwner {
        loanParams.factoryAddress = _factAddr;
    }

     /**
    * @dev deploy a new eth loan contract, add its address to internal variables
    * @param _factAddr, factory address
    * @return address of new pair contract
    */              
    function deployNewLoanContract(address _factAddr) external override onlyLoanFactory returns (address) {
        address newLoanContract = address(new JLoan(_factAddr, feesCollector));
        return newLoanContract;
    }

    /**
    * @dev set the fee collector contract address
    * @param _feeColl fees collectro address
    */
    function setFeesCollector(address _feeColl) external override onlyOwner {
        feesCollector = _feeColl;
    }

    /**
    * @dev get the fee collector contract address
    * @return fee collector address
    */
    function getFeesCollector() external override view returns(address) {
        return feesCollector;
    }

}
