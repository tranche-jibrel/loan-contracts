// SPDX-License-Identifier: MIT
/**
 * Created on 2020-11-09
 * @summary: Jibrel Price Oracle
 * @author: Jibrel Team
 */
pragma solidity 0.6.12;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}


/**
 * @title Initializable
 *
 * @dev Helper contract to support initializer functions. To use it, replace
 * the constructor with a function that has the `initializer` modifier.
 * WARNING: Unlike constructors, initializer functions must be manually
 * invoked. This applies both to deploying an Initializable contract, as well
 * as extending an Initializable contract via inheritance.
 * WARNING: When used with inheritance, manual care must be taken to not invoke
 * a parent initializer twice, or ensure that all initializers are idempotent,
 * because this is not dealt with automatically as with constructors.
 */
contract Initializable {

  /**
   * @dev Indicates that the contract has been initialized.
   */
  bool private initialized;

  /**
   * @dev Indicates that the contract is in the process of being initialized.
   */
  bool private initializing;

  /**
   * @dev Modifier to use in the initializer function of a contract.
   */
  modifier initializer() {
    require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

    bool isTopLevelCall = !initializing;
    if (isTopLevelCall) {
      initializing = true;
      initialized = true;
    }

    _;

    if (isTopLevelCall) {
      initializing = false;
    }
  }

  /// @dev Returns true if and only if the function is running in the constructor
  function isConstructor() private view returns (bool) {
    // extcodesize checks the size of the code stored in an address, and
    // address returns the current address. Since the code is still not
    // deployed when running a constructor, any checks on its code size will
    // yield zero, making it an effective way to detect if a contract is
    // under construction or not.
    address self = address(this);
    uint256 cs;
    assembly { cs := extcodesize(self) }
    return cs == 0;
  }

  // Reserved storage space to allow for layout changes in the future.
  uint256[50] private ______gap;
}


/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
contract ContextUpgradeSafe is Initializable {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.

    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {


    }


    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }

    uint256[50] private __gap;
}


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract OwnableUpgradeSafe is Initializable, ContextUpgradeSafe {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */

    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {


        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);

    }


    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    uint256[49] private __gap;
}


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
