// SPDX-License-Identifier: MIT
/**
 * Created on 2020-11-09
 * @summary: JLoanEthDeployer Interface
 * @author: Jibrel Team
 */
pragma solidity 0.6.12;


interface IJLoanDeployer {
    function setLoanFactory(address _factAddr) external;
    function deployNewLoanContract(address _factAddr) external returns (address);
    function setFeesCollector(address _feeColl) external;
    function getFeesCollector() external view returns(address);
}
