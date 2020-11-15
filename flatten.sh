#!/usr/bin/env zsh

# This scripts can be used to create flat files which can be directly imported on Remix if needed.
echo "Clearing existing flats"
if [ -d dist ]; then
    rm -rf dist
fi

mkdir dist
# TO-DO: Comments (author, summary, Created On) should be handled better.
# JFactory
echo "Flattening # JFactory contract"
npx truffle-flattener ./contracts/JFactory.sol | awk '/SPDX-License-Identifier/&&c++>0 {next} 1' | awk '/pragma experimental ABIEncoderV2;/&&c++>0 {next} 1' | awk '/pragma solidity/&&c++>0 {next} 1' | awk '/author/&&c++>0 {next} 1' | awk '/summary/&&c++>0 {next} 1' | awk '/Created on/&&c++>0 {next} 1' | sed '/^[[:blank:]]*\/\/ File/d;s/#.*//' >./dist/JFactory.sol

# JFeesCollector
echo "Flattening # JFeesCollector contract"
npx truffle-flattener ./contracts/JFeesCollector.sol | awk '/SPDX-License-Identifier/&&c++>0 {next} 1' | awk '/pragma experimental ABIEncoderV2;/&&c++>0 {next} 1' | awk '/pragma solidity/&&c++>0 {next} 1' | awk '/author/&&c++>0 {next} 1' | awk '/summary/&&c++>0 {next} 1' | awk '/Created on/&&c++>0 {next}  1' | sed '/^[[:blank:]]*\/\/ File/d;s/#.*//' >./dist/JFeesCollector.sol

# JLoanDeployer
echo "Flattening # JLoanDeployer contract"
npx truffle-flattener ./contracts/JLoanDeployer.sol | awk '/SPDX-License-Identifier/&&c++>0 {next} 1' | awk '/pragma experimental ABIEncoderV2;/&&c++>0 {next} 1' | awk '/pragma solidity/&&c++>0 {next} 1' | awk '/author/&&c++>0 {next} 1' | awk '/summary/&&c++>0 {next} 1' | awk '/Created on/&&c++>0 {next} 1' | sed '/^[[:blank:]]*\/\/ File/d;s/#.*//' >./dist/JLoanDeployer.sol

# JPriceOracle
echo "Flattening # JPriceOracle contract"
npx truffle-flattener ./contracts/JPriceOracle.sol | awk '/SPDX-License-Identifier/&&c++>0 {next} 1' | awk '/pragma experimental ABIEncoderV2;/&&c++>0 {next} 1' | awk '/pragma solidity/&&c++>0 {next} 1' | awk '/author/&&c++>0 {next} 1' | awk '/summary/&&c++>0 {next} 1' | awk '/Created on/&&c++>0 {next} 1' | sed '/^[[:blank:]]*\/\/ File/d;s/#.*//' >./dist/JPriceOracle.sol

# myERC20
echo "Flattening # myERC20 contract"
npx truffle-flattener ./contracts/myERC20.sol | awk '/SPDX-License-Identifier/&&c++>0 {next} 1' | awk '/pragma experimental ABIEncoderV2;/&&c++>0 {next} 1' | awk '/pragma solidity/&&c++>0 {next} 1' | awk '/author/&&c++>0 {next} 1' | awk '/summary/&&c++>0 {next} 1' | awk '/Created on/&&c++>0 {next} 1' | sed '/^[[:blank:]]*\/\/ File/d;s/#.*//' >./dist/myERC20.sol
