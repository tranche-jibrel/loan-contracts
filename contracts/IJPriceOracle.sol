// SPDX-License-Identifier: MIT
/**
 * Created on 2020-11-09
 * @summary: JPriceOracle Interface
 * @author: Jibrel Team
 */
pragma solidity 0.6.12;

interface IJPriceOracle {
    function isAdmin(address account) external view returns (bool);
    function addAdmin(address account) external;
    function removeAdmin(address account) external;
    function renounceAdmin() external;
    function setNewPair(string calldata _pairName, uint256 _price, uint8 _pairDecimals, 
                address _baseAddress, uint8 _baseDecimals, address _quoteAddress, uint8 _quoteDecimals) external;
    function setPairValue(uint256 _pairId, uint256 _price, uint8 _pairDecimals) external;
    function setBaseQuoteDecimals(uint256 _pairId, uint8 _baseDecimals, uint8 _quoteDecimals) external;
    function getPairCounter() external view returns (uint256);
    function getPairValue(uint256 _pairId) external view returns (uint256);
    function getPairName(uint256 _pairId) external view returns (string memory);
    function getPairDecimals(uint256 _pairId) external view returns (uint8);
    function getPairBaseDecimals(uint256 _pairId) external view returns (uint8);
    function getPairQuoteDecimals(uint256 _pairId) external view returns (uint8);
    function getPairBaseAddress(uint256 _pairId) external view returns (address);
    function getPairQuoteAddress(uint256 _pairId) external view returns (address);
}