require('dotenv').config();
const { deployProxy } = require('@openzeppelin/truffle-upgrades');
var myERC20 = artifacts.require("./myERC20.sol");
var JFeesCollector = artifacts.require("./JFeesCollector.sol");
var JLoanDeployer = artifacts.require("./JLoanDeployer.sol");
var JFactory = artifacts.require("./JFactory.sol");
var JPriceOracle = artifacts.require("./JPriceOracle.sol");

module.exports = async (deployer, network, accounts) => {
  const MYERC20_TOKEN_SUPPLY = 5000000; 
  const ZERO_ADDRESS = "0x0000000000000000000000000000000000000000";
  const daiRequest = 100 * Math.pow(10, 18);
  //const DAI_REQUEST_HEX = "0x" + daiRequest.toString(16);
  //const ethRpb = 1 * Math.pow(10, 9);
  //const ETH_RPB_HEX = "0x" + ethRpb.toString(16);

  if (network == "development") {
    const tokenOwner = accounts[0];
    const myERC20instance = await deployProxy(myERC20, [MYERC20_TOKEN_SUPPLY], { from: tokenOwner });
    console.log('myERC20 Deployed: ', myERC20instance.address);
    /*let myERC20Address = await deployer.deploy(myERC20, MYERC20_TOKEN_SUPPLY, { from: tokenOwner });
    contractMyERC20 = await myERC20.deployed();*/

    const factoryOwner = accounts[0];
    const JFCinstance = await deployProxy(JFeesCollector, [], { from: factoryOwner });
    console.log('JFeesCollector Deployed: ', JFCinstance.address);
    /*let JFCAddress = await deployer.deploy(JFeesCollector, {from: factoryOwner});
    contractJFC = await JFeesCollector.deployed();
    await contractJFC.initialize({ from: factoryOwner });*/

    const JLDinstance = await deployProxy(JLoanDeployer, [], { from: factoryOwner });
    console.log('JLoanDeployer Deployed: ', JLDinstance.address);
    /*let JLDAddress = await deployer.deploy(JLoanDeployer, {from: factoryOwner});
    contractJLD = await JLoanDeployer.deployed();
    await contractJLD.initialize({ from: factoryOwner });*/

    const JPOinstance = await deployProxy(JPriceOracle, [], { from: factoryOwner, unsafeAllowCustomTypes: true });
    console.log('JPriceOracle Deployed: ', JPOinstance.address);
    /*let JPOAddress = await deployer.deploy(JPriceOracle, {from: factoryOwner});
    contractJPO = await JPriceOracle.deployed();
    await contractJPO.initialize({ from: factoryOwner });*/

    const JFinstance = await deployProxy(JFactory, [JLDinstance.address, JPOinstance.address], { from: factoryOwner , unsafeAllowCustomTypes: true });
    console.log('JPriceOracle Deployed: ', JFinstance.address);
    console.log('JPriceOracle Owner: ', await JFinstance.owner());
    console.log('factoryOwner: ', factoryOwner);
    /*let JFAddress = await deployer.deploy(JFactory, {from: factoryOwner});
    contractJF = await JFactory.deployed();
    await contractJF.initialize(JLoanDeployer.address, JPriceOracle.address, { from: factoryOwner });*/

    let setPOFactoryAddress = await JPOinstance.setFactoryAddress(JFinstance.address, {from: factoryOwner});
    let setDeplFactoryAddress = await JLDinstance.setLoanFactory(JFinstance.address, {from: factoryOwner});
    let setDeplFCAddress = await JLDinstance.setFeesCollector(JFCinstance.address, {from: factoryOwner});
    // set new pairs in JFactory
    let setNewPair0 = await JPOinstance.setNewPair("ETHDAI", 32785, 2, ZERO_ADDRESS, 18, myERC20.address, 18, {from: factoryOwner});
    let setNewPair1 = await JPOinstance.setNewPair("JPTUSDC", 26563, 6, myERC20.address, 18, myERC20.address, 18, {from: factoryOwner});
  }
  else if (network == "kovan"){
    const accounts = await web3.eth.getAccounts();

    let JFCAddress = await deployer.deploy(JFeesCollector, {from: accounts[0]});
    contractJFC = await JFeesCollector.deployed();
    await contractJFC.initialize({ from: accounts[0] });

    let JLDAddress = await deployer.deploy(JLoanDeployer, {from: accounts[0]});
    contractJLD = await JLoanDeployer.deployed();
    await contractJLD.initialize({ from: accounts[0] });

    let JPOAddress = await deployer.deploy(JPriceOracle, {from: accounts[0]});
    contractJPO = await JPriceOracle.deployed();
    await contractJPO.initialize({ from: accounts[0] });

    let JFAddress = await deployer.deploy(JFactory, JLoanDeployer.address, JPriceOracle.address, {from: accounts[0]});
    contractJF = await JFactory.deployed();
    await contractJF.initialize(JLoanDeployer.address, JPriceOracle.address, { from: accounts[0] });

    let setPOFactoryAddress = await contractJPO.setFactoryAddress(JFactory.address, {from: accounts[0]});
    let setDeplFactoryAddress = await contractJLD.setLoanFactory(JFactory.address, {from: accounts[0]});
    let setDeplFCAddress = await contractJLD.setFeesCollector(JFeesCollector.address, {from: accounts[0]});
    // set new pairs in JFactory
    let setNewPair0 = await contractJPO.setNewPair("ETHDAI", 35858, 2, ZERO_ADDRESS, 18, process.env.DAIAddress, 18, {from: accounts[0]});
    let setNewPair1 = await contractJPO.setNewPair("JPTUSDC", 18585, 6, process.env.JPTAddress, 18, process.env.USDCAddress, 18, {from: accounts[0]});
    await contractJF.createNewPairContract(0, {from: accounts[0]});
    await contractJF.createNewPairContract(1, {from: accounts[0]});
    const Pair0Address = await contractJF.getDeployedLoan(0, {from: accounts[0]});
    const Pair1Address = await contractJF.getDeployedLoan(1, {from: accounts[0]});
    await contractJF.addAdmin(process.env.AlasAddress, {from: accounts[0]});
    console.log(`FACTORY_ADDRESS=${JFactory.address}`)
    console.log(`FEES_COLLECTOR=${JFeesCollector.address}`)
    console.log(`PRICE_ORACLE=${JPriceOracle.address}`)
    console.log(`TOKEN_ADDRESS=${Pair0Address},${Pair1Address}`)
    console.log(`REACT_APP_FACTORY_ADDRESS=${JFactory.address}`)
    console.log(`REACT_APP_LOAN_DEPLOYER_ADDRESS=${JLoanDeployer.address}`)
    console.log(`REACT_APP_FEES_COLLECTOR=${JFeesCollector.address}`)
    console.log(`REACT_APP_PRICE_ORACLE=${JPriceOracle.address}`)
    console.log(`REACT_APP_PAIR_0=${Pair0Address}`)
    console.log(`REACT_APP_PAIR_1=${Pair1Address}`)
  }
};
