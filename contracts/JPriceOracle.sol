// SPDX-License-Identifier: MIT
/**
 * Created on 2020-11-09
 * @summary: Jibrel Price Oracle
 * @author: Jibrel Team
 */
pragma solidity 0.6.12;

import "@openzeppelin/contracts-ethereum-package/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts-ethereum-package/contracts/access/Ownable.sol";
import "./IJPriceOracle.sol";

contract JPriceOracle is OwnableUpgradeSafe, IJPriceOracle { 
    using SafeMath for uint256;

    mapping (address => bool) private _Admins;

    uint256 public contractVersion;

    struct Pair {
        string pairName;
        uint256 pairValue;
        address baseAddress;
        address quoteAddress;
        uint8 pairDecimals;
        uint8 baseDecimals;
        uint8 quoteDecimals;
    }
    mapping(uint256 => Pair) public pairs;
    uint256 public pairCounter;

    event AdminAdded(address account);
    event AdminRemoved(address account);
    event NewPair(uint256 indexed _pairId, string _pairName);
    event NewPrice(uint256 indexed pairId, string indexed pairName, uint256 pairValue, uint8 pairDecimals);
    event NewPairDecimals(uint256 indexed pairId, string indexed pairName, uint8 baseDecimals, uint8 quoteDecimals);
    event NewPairAddresses(uint256 indexed pairId, string indexed pairName, address baseAddress , address quoteAddress);

    function initialize() public initializer() {
        OwnableUpgradeSafe.__Ownable_init();
        _Admins[msg.sender] = true;
        contractVersion = 1;
    }

    modifier onlyAdmins() {
        require(isAdmin(msg.sender), "!Admin");
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
    * @dev update contract version
    * @param _ver new version
    */
    function updateVersion(uint256 _ver) external onlyAdmins {
        require(_ver > contractVersion, "!NewVersion");
        contractVersion = _ver;
    }

    /**
    * @dev set a new pair
    * @param _pairName string describing the pair (i.e. ETHDAI)
    * @param _price price of the pair
    * @param _pairDecimals number of decimals for pair
    * @param _baseAddress base address token
    * @param _baseDecimals base decimals token
    * @param _quoteAddress quote address token
    * @param _quoteDecimals quote decimals token
    */
    function setNewPair(string memory _pairName, uint256 _price, uint8 _pairDecimals, 
                address _baseAddress, uint8 _baseDecimals, address _quoteAddress, uint8 _quoteDecimals) external override onlyAdmins {
        pairs[pairCounter] = Pair({pairName: _pairName, pairValue: _price, pairDecimals: _pairDecimals, 
                baseAddress: _baseAddress, baseDecimals: _baseDecimals, quoteAddress: _quoteAddress, quoteDecimals: _quoteDecimals});
        emit NewPair(pairCounter, _pairName);
        pairCounter = pairCounter.add(1);
    }

    /**
    * @dev set a price for the specified pair
    * @param _pairId number of the pair
    * @param _price price of the pair
    * @param _pairDecimals number of decimals for pair
    */
    function setPairValue(uint256 _pairId, uint256 _price, uint8 _pairDecimals) external override onlyAdmins {
        require(_pairId < pairCounter, "pair does not exists");
        pairs[_pairId].pairValue = _price;
        pairs[_pairId].pairDecimals = _pairDecimals;
        emit NewPrice(_pairId, pairs[_pairId].pairName, pairs[_pairId].pairValue, pairs[_pairId].pairDecimals);
    }

    /**
    * @dev set a base and quote decimals for the specified pair
    * @param _pairId number of the pair
    * @param _baseDecimals base decimals of the pair
    * @param _quoteDecimals quote decimals for pair
    */
    function setBaseQuoteDecimals(uint256 _pairId, uint8 _baseDecimals, uint8 _quoteDecimals) external override onlyAdmins {
        require(_pairId < pairCounter, "pair does not exists");
        pairs[_pairId].baseDecimals = _baseDecimals;
        pairs[_pairId].quoteDecimals = _quoteDecimals;
        emit NewPairDecimals(_pairId, pairs[_pairId].pairName, pairs[_pairId].baseDecimals, pairs[_pairId].quoteDecimals);
    }

    /**
    * @dev get a pair price
    * @return pairs counter
    */
    function getPairCounter() external override view returns (uint256) {
        return pairCounter;
    }

    /**
    * @dev get a pair price
    * @param _pairId number of the pair
    * @return price of the pair
    */
    function getPairValue(uint256 _pairId) external override view returns (uint256) {
        require(_pairId < pairCounter, "pair does not exists");
        return pairs[_pairId].pairValue;
    }

    /**
    * @dev get a pair name
    * @param _pairId number of the pair
    * @return name of the pair
    */
    function getPairName(uint256 _pairId) external override view returns (string memory) {
        require(_pairId < pairCounter, "pair does not exists");
        return pairs[_pairId].pairName;
    }

    /**
    * @dev get a pair decimals
    * @param _pairId number of the pair
    * @return decimals of the pair
    */
    function getPairDecimals(uint256 _pairId) external override view returns (uint8) {
        require(_pairId < pairCounter, "pair does not exists");
        return pairs[_pairId].pairDecimals;
    }

    /**
    * @dev get a pair base decimals
    * @param _pairId number of the pair
    * @return number of base currency decimals
    */
    function getPairBaseDecimals(uint256 _pairId) external override view returns (uint8) {
        require(_pairId < pairCounter, "pair does not exists");
        return pairs[_pairId].baseDecimals;
    }

    /**
    * @dev get a pair quote decimals
    * @param _pairId number of the pair
    * @return number of quote currency decimals
    */
    function getPairQuoteDecimals(uint256 _pairId) external override view returns (uint8) {
        require(_pairId < pairCounter, "pair does not exists");
        return pairs[_pairId].quoteDecimals;
    }

    /**
    * @dev get a pair base decimals
    * @param _pairId number of the pair
    * @return address of base currency decimals
    */
    function getPairBaseAddress(uint256 _pairId) external override view returns (address) {
        require(_pairId < pairCounter, "pair does not exists");
        return pairs[_pairId].baseAddress;
    }

    /**
    * @dev get a pair quote decimals
    * @param _pairId number of the pair
    * @return address of quote currency decimals
    */
    function getPairQuoteAddress(uint256 _pairId) external override view returns (address) {
        require(_pairId < pairCounter, "pair does not exists");
        return pairs[_pairId].quoteAddress;
    }
}