// SPDX-License-Identifier: MIT
/**
 * Created on 2020-11-09
 * @summary: JPriceOracle Interface
 * @author: Jibrel Team
 */
pragma solidity 0.6.12;


interface IJPriceOracle {
    function setFactoryAddress(address _factoryAddress) external;
    function setNewPair(string calldata _pairName, uint _price, uint8 _pairDecimals, 
                address _baseAddress, uint8 _baseDecimals, address _quoteAddress, uint8 _quoteDecimals) external;
    function setPairValue(uint _pairId, uint _price, uint8 _pairDecimals) external;
    function setBaseQuoteDecimals(uint _pairId, uint8 _baseDecimals, uint8 _quoteDecimals) external;
    function getPairCounter() external view returns (uint);
    function getPairValue(uint _pairId) external view returns (uint);
    function getPairName(uint _pairId) external view returns (string memory);
    function getPairDecimals(uint _pairId) external view returns (uint8);
    function getPairBaseDecimals(uint _pairId) external view returns (uint8);
    function getPairQuoteDecimals(uint _pairId) external view returns (uint8);
    function getPairBaseAddress(uint _pairId) external view returns (address);
    function getPairQuoteAddress(uint _pairId) external view returns (address);
}