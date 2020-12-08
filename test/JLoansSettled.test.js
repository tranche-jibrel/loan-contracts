const { deployProxy, upgradeProxy } = require('@openzeppelin/truffle-upgrades');
const { accounts, contract, web3 } = require('@openzeppelin/test-environment');
const { expect } = require('chai');
const {
    BN,           // Big Number support
    constants,    // Common constants, like the zero address and largest integers
    expectEvent,  // Assertions for emitted events
    expectRevert, // Assertions for transactions that should fail
    time,         // time utilities
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

const { factoryInitialization, 
  borrowersOpenLoans, 
  lendersActivateLoans, 
  borrowersAddCollateral, 
  lendersGetAccruedInterest } = require('./JLoansFunctions');

describe('JLoansSettled', function () {
  const STABLE_COIN_AMOUNT1 = 15000;
  //const STABLE_COIN_AMOUNT2 = 10000;
  const STABLE_COIN_AMOUNT3 = 1500;
  //const STABLE_COIN_AMOUNT4 = 1000;
  const GAS_PRICE = 27000000000; //Gwei = 10 ** 9 wei

  const [ tokenOwner, factoryOwner, borrower1, borrower2, borrower3, borrower4, lender1, lender2, factoryAdmin ] = accounts;

  //beforeEach(async function () {

  //});

  factoryInitialization(tokenOwner, factoryOwner, borrower3, borrower4, lender1, lender2, factoryAdmin);

  borrowersOpenLoans(factoryOwner, borrower1, borrower2, borrower3, borrower4, lender1, lender2);

  lendersActivateLoans(borrower1, borrower2, borrower3, borrower4, lender1, lender2);

  borrowersAddCollateral(borrower1, borrower2, borrower3, borrower4);

  lendersGetAccruedInterest(lender1, lender2);

  it('borrower1 settles loan0 contract', async function () {
    JFeesCollBalance = await this.JFeesCollector.getEthBalance();
    console.log(`JFeesCollector Balance: ${web3.utils.fromWei(JFeesCollBalance.toString(), "ether")} ETH`);
    tx = await this.erc20Lent1.approve(this.JLoan.address, web3.utils.toWei(STABLE_COIN_AMOUNT1.toString(),'ether'), {from: borrower1});
    console.log(tx.receipt.gasUsed);
    totcost = tx.receipt.gasUsed * GAS_PRICE;
    console.log("borrower1 approve costs: " + web3.utils.fromWei(totcost.toString(), 'ether') + " ETH");
    console.log("borrower1 Allowance: " + await this.erc20Lent1.allowance(borrower1, this.JLoan.address))
    console.log("Loan0 collateral ratio: " + await this.JLoan.getActualCollateralRatio(0));
    tx = await this.JLoan.loanClosingByBorrower(0, {from: borrower1});
    console.log(tx.receipt.gasUsed);
    totcost = tx.receipt.gasUsed * GAS_PRICE;
    console.log("borrower1 settlement costs: " + web3.utils.fromWei(totcost.toString(), 'ether') + " ETH");
    borrBal = await this.erc20Lent1.balanceOf(borrower1);
    console.log(`New borrower1 Stable coins Balance: ${web3.utils.fromWei(borrBal, "ether")} Stable coins`);
    loanStatus = await this.JLoan.getLoanStatus(0);
    console.log("Loan 0 Status:" + loanStatus);
    loanStatus = await this.JLoan.getLoanStatus(1);
    console.log("Loan 1 Status:" + loanStatus);
    JFeesCollBalance = await this.JFeesCollector.getEthBalance();
    console.log(`New JFeesCollector Balance: ${web3.utils.fromWei(JFeesCollBalance.toString(), "ether")} ETH`);
    contractBalance = await this.JLoan.getContractBalance(0);
    console.log(`Contract Balance: ${web3.utils.fromWei(contractBalance.toString(), "ether")} ETH`);
    loanBalance = await this.JLoan.getLoanBalance(0);
    console.log(`Loan 0 Balance: ${web3.utils.fromWei(loanBalance.toString(), "ether")} ETH`);
    console.log("Accrued interests loan0: " + await this.JLoan.getAccruedInterests(0));
    borrBal = await this.erc20Lent1.balanceOf(borrower1);
    console.log(`New borrower1 Stable coins Balance: ${web3.utils.fromWei(borrBal, "ether")} Stable coins`);
    expect(borrBal.toString()).to.be.equal(new BN(0).toString());
    lendBal = await this.erc20Lent1.balanceOf(lender1);
    console.log(`New lender1 Stable coins Balance: ${web3.utils.fromWei(lendBal, "ether")} Stable coins`);
    expect(lendBal.toString()).to.be.equal(web3.utils.toWei('990000', "ether"));
    console.log("New collateral ratio: " + await this.JLoan.getActualCollateralRatio(0));
  });

  it('borrower3 settles loan2 contract', async function () {
    JFeesCollBalance = await this.JFeesCollector.getTokenBalance(this.erc20Coll1.address);
    console.log(`JFeesCollector Balance: ${web3.utils.fromWei(JFeesCollBalance.toString(), "ether")} Collat. Coins`);
    tx = await this.erc20Lent2.approve(this.JLoan.address, web3.utils.toWei(STABLE_COIN_AMOUNT3.toString(),'ether'), {from: borrower3});
    console.log(tx.receipt.gasUsed);
    totcost = tx.receipt.gasUsed * GAS_PRICE;
    console.log("borrower3 approve costs: " + web3.utils.fromWei(totcost.toString(), 'ether') + " ETH");
    console.log("borrower3 Allowance: " + await this.erc20Lent2.allowance(borrower3, this.JLoan.address))
    console.log("Loan2 collateral ratio: " + await this.JLoan.getActualCollateralRatio(0));
    tx = await this.JLoan.loanClosingByBorrower(2, {from: borrower3});
    console.log(tx.receipt.gasUsed);
    totcost = tx.receipt.gasUsed * GAS_PRICE;
    console.log("borrower3 settlement costs: " + web3.utils.fromWei(totcost.toString(), 'ether') + " ETH");
    borrBal = await this.erc20Lent2.balanceOf(borrower3);
    console.log(`New borrower3 Stable coins Balance: ${web3.utils.fromWei(borrBal, "ether")} Stable coins`);
    loanStatus = await this.JLoan.getLoanStatus(2);
    console.log("Loan2 Status:" + loanStatus);
    loanStatus = await this.JLoan.getLoanStatus(3);
    console.log("Loan3 Status:" + loanStatus);
    JFeesCollBalance = await this.JFeesCollector.getTokenBalance(this.erc20Coll1.address);
    console.log(`New JFeesCollector Balance: ${web3.utils.fromWei(JFeesCollBalance.toString(), "ether")} Collat. Coins`);
    contractBalance = await this.JLoan.getContractBalance(2);
    console.log(`Contract Balance: ${web3.utils.fromWei(contractBalance.toString(), "ether")} Collat. Coins`);
    loanBalance = await this.JLoan.getLoanBalance(2);
    console.log(`Loan2 Balance: ${web3.utils.fromWei(loanBalance.toString(), "ether")} Collat. Coins`);
    console.log("Accrued interests loan2: " + await this.JLoan.getAccruedInterests(2));
    borrBal = await this.erc20Lent2.balanceOf(borrower3);
    console.log(`New borrower3 Stable coins Balance: ${web3.utils.fromWei(borrBal, "ether")} Stable coins`);
    expect(borrBal.toString()).to.be.equal(new BN(0).toString());
    lenderBal = await this.erc20Lent2.balanceOf(lender2);
    console.log(`New lender Stable coins Balance: ${web3.utils.fromWei(lenderBal, "ether")} Stable coins`);
    expect(lenderBal.toString()).to.be.equal(web3.utils.toWei('999000', "ether"));
    console.log("New collateral ratio: " + await this.JLoan.getActualCollateralRatio(2));
  });

  it('time passes...', async function () {
    let block = await web3.eth.getBlock("latest");
    console.log("Actual Block: " + block.number);
    newBlock = block.number + 50;
    await time.advanceBlockTo(newBlock);
  });

  lendersGetAccruedInterest(lender1, lender2);
  
  it('time passes...', async function () {
    let block = await web3.eth.getBlock("latest");
    console.log("Actual Block: " + block.number);
    newBlock = block.number + 50;
    await time.advanceBlockTo(newBlock);
  });

  lendersGetAccruedInterest(lender1, lender2);

});