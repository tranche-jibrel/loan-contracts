const { accounts, contract, web3 } = require('@openzeppelin/test-environment');
const { expect } = require('chai');
const {
    BN,           // Big Number support
    constants,    // Common constants, like the zero address and largest integers
    expectEvent,  // Assertions for emitted events
    expectRevert, // Assertions for transactions that should fail
  } = require('@openzeppelin/test-helpers');
//const Web3 = require('web3');

// Please choose which kind of test are you performing, with ganache UI or ganache cli
// Ganache UI on 8545
//const web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:8545"));
// ganache-cli
//const ganache = require('ganache-core');
//const web3 = new Web3(ganache.provider());

const BigNumber = web3.utils.BN;
require("chai")
  .use(require("chai-bn")(BigNumber))
  .should();

/*
const contract = require('truffle-contract');
const TokenArtifact = require('./../../build/contracts/YourToken.json');

var Token = contract(TokenArtifact);
Token.setProvider(window.web3.currentProvider);
var tokenInstance = await Token.deployed();
*/

const { factoryInitialization, borrowersOpenLoans } = require('./JLoansFunctions');

describe('JLoansCancelled', function () {
  const GAS_PRICE = 27000000000; //Gwei = 10 ** 9 wei
  
  const [ tokenOwner, factoryOwner, borrower1, borrower2, borrower3, borrower4, lender1, lender2, factoryAdmin ] = accounts;

  var collAmount = 0;
  var loanStatus = 0;

  //beforeEach(async function () {

  //});

  factoryInitialization(tokenOwner, factoryOwner, borrower3, borrower4, lender1, lender2, factoryAdmin);

  borrowersOpenLoans(factoryOwner, borrower1, borrower2, borrower3, borrower4, lender1, lender2);

  it('borrower1 cancel opened loan', async function () {
    tx = await this.loanContract.setLoanCancelled(0, {from: borrower1});
    console.log(tx.receipt.gasUsed);
    totcost = tx.receipt.gasUsed * GAS_PRICE;
    console.log("Cancellation costs: " + web3.utils.fromWei(totcost.toString(), 'ether') + " ETH");
    loanStatus = await this.loanContract.getLoanStatus(0);
    expect(loanStatus.toString()).to.be.equal(new BN(9).toString());
    contractBalance = await this.loanContract.getContractBalance(0);
    console.log(`Contract Balance: ${web3.utils.fromWei(contractBalance.toString(), "ether")} ETH`);
    loanBalance = await this.loanContract.getLoanBalance(0);
    console.log(`Loan0 Balance: ${web3.utils.fromWei(loanBalance.toString(), "ether")} ETH`);
    JFeesCollBalance = await this.JFeesCollector.getEthBalance();
    console.log(`JFeesCollector Balance: ${web3.utils.fromWei(JFeesCollBalance.toString(), "ether")} ETH`);
    var borrBal = await web3.eth.getBalance(borrower1);
    console.log(`New borrower1 Balance: ${web3.utils.fromWei(borrBal, "ether")} ETH`);
  });

  it('borrower4 cancel opened loan', async function () {
    tx = await this.loanContract.setLoanCancelled(3, {from: borrower4});
    console.log(tx.receipt.gasUsed);
    totcost = tx.receipt.gasUsed * GAS_PRICE;
    console.log("Cancellation costs: " + web3.utils.fromWei(totcost.toString(), 'ether') + " ETH");
    loanStatus = await this.loanContract.getLoanStatus(3);
    expect(loanStatus.toString()).to.be.equal(new BN(9).toString());
    contractBalance = await this.loanContract.getContractBalance(3);
    console.log(`Contract Balance: ${web3.utils.fromWei(contractBalance.toString(), "ether")} Coll. Tokens`);
    loanBalance = await this.loanContract.getLoanBalance(3);
    console.log(`Loan3 Balance: ${web3.utils.fromWei(loanBalance.toString(), "ether")} Coll. Tokens`);
    JFeesCollBalance = await this.JFeesCollector.getTokenBalance(this.erc20Coll1.address);
    console.log(`JFeesCollector Balance: ${web3.utils.fromWei(JFeesCollBalance.toString(), "ether")} Coll. Tokens`);
    var borrBal = await this.erc20Coll1.balanceOf(borrower4);
    console.log(`New borrower4 Balance: ${web3.utils.fromWei(borrBal, "ether")} Coll.Tokens`);
  });

  it('borrowers can not send any collateral to closed contract', async function () {
    collAmount = new BN(1000000000);
    await expectRevert(web3.eth.sendTransaction({from: borrower1, to: this.loanContract.address, value: collAmount}), "revert");
    await expectRevert(this.loanContract.depositEthCollateral(0, {from: borrower1, value: collAmount}), "!Status04");
    tx = await this.erc20Coll1.approve(this.loanContract.address, collAmount, {from: borrower4});
    await expectRevert(this.loanContract.depositTokenCollateral(3, this.erc20Coll1.address, collAmount, {from: borrower4}), "!Status04");
  });

  it('lender1 cannot send any stable coin to closed contract', async function () { 
    await expectRevert(this.loanContract.lenderSendStableCoins(0, this.erc20Lent1.address, {from: lender1}), "!Status0");
  });

  it('borrower2 cancel opened loan', async function () {
    tx = await this.loanContract.setLoanCancelled(1, {from: borrower2});
    console.log(tx.receipt.gasUsed);
    totcost = tx.receipt.gasUsed * GAS_PRICE;
    console.log("Cancellation costs: " + web3.utils.fromWei(totcost.toString(), 'ether') + " ETH");
    loanStatus = await this.loanContract.getLoanStatus(1);
    expect(loanStatus.toString()).to.be.equal(new BN(9).toString());
    contractBalance = await this.loanContract.getContractBalance(0);
    console.log(`Contract Balance: ${web3.utils.fromWei(contractBalance.toString(), "ether")} ETH`);
    loanBalance = await this.loanContract.getLoanBalance(0);
    console.log(`Loan0 Balance: ${web3.utils.fromWei(loanBalance.toString(), "ether")} ETH`);
    loanBalance = await this.loanContract.getLoanBalance(1);
    console.log(`Loan1 Balance: ${web3.utils.fromWei(loanBalance.toString(), "ether")} ETH`);
    loanBalance = await this.loanContract.getLoanBalance(2);
    console.log(`Loan2 Balance: ${web3.utils.fromWei(loanBalance.toString(), "ether")} Coll.Tokens`);
    loanBalance = await this.loanContract.getLoanBalance(3);
    console.log(`Loan3 Balance: ${web3.utils.fromWei(loanBalance.toString(), "ether")} Coll.Tokens`);
    JFeesCollBalance = await this.JFeesCollector.getEthBalance();
    console.log(`JFeesCollector Balance: ${web3.utils.fromWei(JFeesCollBalance.toString(), "ether")} ETH`);
    JFeesCollBalance = await this.JFeesCollector.getTokenBalance(this.erc20Coll1.address);
    console.log(`JFeesCollector Balance: ${web3.utils.fromWei(JFeesCollBalance.toString(), "ether")} Coll.Tokens`);
    borrBal = await web3.eth.getBalance(borrower1);
    console.log(`New borrower1 Balance: ${web3.utils.fromWei(borrBal, "ether")} ETH`);
    borrBal = await web3.eth.getBalance(borrower2);
    console.log(`New borrower2 Balance: ${web3.utils.fromWei(borrBal, "ether")} ETH`);
    borrBal = await this.erc20Coll1.balanceOf(borrower3);
    console.log(`New borrower3 Balance: ${web3.utils.fromWei(borrBal, "ether")} Coll.Tokens`);
    borrBal = await this.erc20Coll1.balanceOf(borrower4);
    console.log(`New borrower4 Balance: ${web3.utils.fromWei(borrBal, "ether")} Coll.Tokens`);
  });

});