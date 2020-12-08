require('dotenv').config();
const { deployProxy, upgradeProxy } = require('@openzeppelin/truffle-upgrades');
var myERC20 = artifacts.require("./myERC20.sol");
var JFeesCollector = artifacts.require("./JFeesCollector.sol");
var JFeesCollector2 = artifacts.require("./JFeesCollector2.sol");
var JPriceOracle = artifacts.require("./JPriceOracle.sol");
var JLoan = artifacts.require("./JLoan.sol");
var JLoanHelper = artifacts.require("./JLoanHelper.sol"); // not upgradeable

module.exports = async (deployer, network, accounts) => {
  const MYERC20_TOKEN_SUPPLY = 5000000;
  const ZERO_ADDRESS = "0x0000000000000000000000000000000000000000";
  //const daiRequest = 100 * Math.pow(10, 18);
  //const DAI_REQUEST_HEX = "0x" + daiRequest.toString(16);
  //const ethRpb = 1 * Math.pow(10, 9);
  //const ETH_RPB_HEX = "0x" + ethRpb.toString(16);

  if (network == "development") {
    const tokenOwner = accounts[0];
    const myERC20instance = await deployProxy(myERC20, [MYERC20_TOKEN_SUPPLY], { from: tokenOwner });
    console.log('myERC20 Deployed: ', myERC20instance.address);

    const factoryOwner = accounts[0];
    const JFCinstance = await deployProxy(JFeesCollector, [], { from: factoryOwner });
    const JFCinst = await JFeesCollector.at(JFCinstance.address);
    const JFCinstance2 = await upgradeProxy(JFCinst.address, JFeesCollector2, { from: factoryOwner });
    console.log('JFeesCollector Deployed: ', JFCinst.address);
    console.log('JFeesCollector2 Deployed: ', JFCinstance2.address);

    const JPOinstance = await deployProxy(JPriceOracle, [], { from: factoryOwner, unsafeAllowCustomTypes: true });
    console.log('JPriceOracle Deployed: ', JPOinstance.address);

    const JLHcontract = await deployer.deploy(JLoanHelper, JPOinstance.address, { from: factoryOwner });
    JLHinstance = await JLoanHelper.deployed();
    //const JLHinstance = await deployProxy(JLoanHelper, [JPOinstance.address], { from: factoryOwner });
    console.log('JLoanHelper Deployed: ', JLHinstance.address);
    
    const JLinstance = await deployProxy(JLoan, [JPOinstance.address, JFCinstance.address, JLHinstance.address], { from: factoryOwner, unsafeAllowCustomTypes: true });
    console.log('JLoan Deployed: ', JLinstance.address);
    console.log('JLoan Owner: ', await JLinstance.owner());
    console.log('factoryOwner: ', factoryOwner);

    // set new pairs in JFactory
    let setNewPair0 = await JPOinstance.setNewPair("ETHDAI", 32785, 2, ZERO_ADDRESS, 18, myERC20.address, 18, { from: factoryOwner });
    let setNewPair1 = await JPOinstance.setNewPair("JPTUSDC", 26563, 6, myERC20.address, 18, myERC20.address, 18, { from: factoryOwner });
  } else if (network == "kovan") {
    const accounts = await web3.eth.getAccounts();
    const factoryOwner = accounts[0];
    let { FEE_COLLECTOR_ADDRESS, PRICE_ORACLE_ADDRESS, LOAN_HELPER_ADDRESS, LOAN_ADDRESS, DAIAddress, JPTAddress, USDCAddress, AlasAddress } = process.env;
    if (process.env.IS_UPGRADE == 'true') {
      console.log('Contracts are upgrading, process started: ')
      console.log(`PRICE_ORACLE_ADDRESS=${PRICE_ORACLE_ADDRESS}`)
      console.log(`FEE_COLLECTOR_ADDRESS=${FEE_COLLECTOR_ADDRESS}`)
      console.log(`LOAN_HELPER_ADDRESS=${LOAN_HELPER_ADDRESS}`)
      console.log(`LOAN_ADDRESS=${LOAN_ADDRESS}`)

      const JFCinstance = await upgradeProxy(FEE_COLLECTOR_ADDRESS, JFeesCollector, { from: factoryOwner });
      const JPOinstance = await upgradeProxy(PRICE_ORACLE_ADDRESS, JPriceOracle, { from: factoryOwner, unsafeAllowCustomTypes: true });
      //const JLHinstance = await upgradeProxy(LOAN_HELPER_ADDRESS, JLoanHelper, { from: factoryOwner});
      const JLinstance = await upgradeProxy(LOAN_ADDRESS, JLoan, { from: factoryOwner, unsafeAllowCustomTypes: true });
      console.log('contracts are upgraded')
      console.log(`LOAN_ADDRESS=${JLinstance.address}`)
      //console.log(`LOAN_HELPER_ADDRESS=${JLHinstance.address}`)
      console.log(`PRICE_ORACLE_ADDRESS=${JPOinstance.address}`)
      console.log(`FEE_COLLECTOR_ADDRESS=${JFCinstance.address}`)

    } else {
      // deployed new contract
      const JFCinstance = await deployProxy(JFeesCollector, [], { from: factoryOwner });
      const JPOinstance = await deployProxy(JPriceOracle, [], { from: factoryOwner, unsafeAllowCustomTypes: true });
      let JLHinstance = await deployer.deploy(JLoanHelper, JPOinstance.address, { from: factoryOwner });
      JLHinstance = await JLoanHelper.deployed();
      const JLinstance = await deployProxy(JLoan, [JPOinstance.address, JFCinstance.address, JLHinstance.address], { from: factoryOwner, unsafeAllowCustomTypes: true });

      // set new pairs in JPRiceOracle
      await JPOinstance.setNewPair("ETHDAI", 47575, 2, ZERO_ADDRESS, 18, DAIAddress, 18, { from: factoryOwner });
      await JPOinstance.setNewPair("JPTUSDC", 18585, 6, JPTAddress, 18, USDCAddress, 18, { from: factoryOwner });

      // admin setup 
      await JPOinstance.addAdmin(AlasAddress, { from: factoryOwner });

      console.log(`LOAN_ADDRESS=${JLinstance.address}`)
      console.log(`FEES_COLLECTOR=${JFCinstance.address}`)
      console.log(`PRICE_ORACLE=${JPOinstance.address}`)
      console.log(`LOAN_HELPER_ADDRESS=${JLHinstance.address}`)

      console.log(`REACT_APP_LOAN_ADDRESS=${JLinstance.address}`)
      console.log(`REACT_APP_LOAN_HELPER_ADDRESS=${JLHinstance.address}`)
      console.log(`REACT_APP_FEES_COLLECTOR=${JFCinstance.address}`)
      console.log(`REACT_APP_PRICE_ORACLE=${JPOinstance.address}`)
      // For upgrade
      console.log(`LOAN_ADDRESS=${JLinstance.address}`)
      console.log(`LOAN_HELPER_ADDRESS=${JLHinstance.address}`)
      console.log(`PRICE_ORACLE_ADDRESS=${JPOinstance.address}`)
      console.log(`FEE_COLLECTOR_ADDRESS=${JFCinstance.address}`)
    }
  }

};
