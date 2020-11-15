// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";


contract myERC20 is ERC20 {
    using SafeMath for uint256;

    constructor(uint _initialSupply) ERC20("NewJNT", "NJNT") public {
        _mint(msg.sender, _initialSupply.mul(10 ** 18));
    }
}
