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
  lendersGetAccruedInterest,
  priceDownfor150,
  firstForeclosing } = require('./JLoansFunctions');

describe('JLoansMultipleWithdraws', function () {

  const STABLE_COIN_AMOUNT1 = 15000;
  //const STABLE_COIN_AMOUNT2 = 10000;
  const STABLE_COIN_AMOUNT3 = 1500;
  //const STABLE_COIN_AMOUNT4 = 1000;
  const GAS_PRICE = 20000000000; //Gwei = 10 ** 9 wei

  const [ tokenOwner, factoryOwner, borrower1, borrower2, borrower3, borrower4, lender1, lender2, factoryAdmin, lender3 ] = accounts;

  var loanStatus = 0;

  //beforeEach(async function () {

  //});

  factoryInitialization(tokenOwner, factoryOwner, borrower3, borrower4, lender1, lender2, factoryAdmin);

  borrowersOpenLoans(factoryOwner, borrower1, borrower2, borrower3, borrower4, lender1, lender2);

  lendersActivateLoans(borrower1, borrower2, borrower3, borrower4, lender1, lender2);

  borrowersAddCollateral(borrower1, borrower2, borrower3, borrower4);

  it('lenders can have accrued interests from contracts as per RPB calling single function', async function () {
    let block = await web3.eth.getBlock("latest");
    console.log("Actual Block: " + block.number);
    newBlock = block.number + 50;
    await time.advanceBlockTo(newBlock);
    lenderBal = await web3.eth.getBalance(lender1);
    console.log(`Lender1 ETH Balance: ${web3.utils.fromWei(lenderBal, "ether")} ETH`)
    lenderCollBal = await this.erc20Coll1.balanceOf(lender2);
    console.log(`Lender2 Coll.Token Balance: ${web3.utils.fromWei(lenderCollBal, "ether")} Coll.Token`)
    console.log("Accrued interests loan0: " + await this.loanContract.getAccruedInterests(0));
    console.log("Accrued interests loan1: " + await this.loanContract.getAccruedInterests(1));
    console.log("Accrued interests loan2: " + await this.loanContract.getAccruedInterests(2));
    console.log("Accrued interests loan3: " + await this.loanContract.getAccruedInterests(3));
    contractBalanceEth = await this.loanContract.getContractBalance(0);
    console.log(`Contract ETH Balance: ${web3.utils.fromWei(contractBalanceEth.toString(), "ether")} ETH`);
    contractBalanceTok = await this.loanContract.getContractBalance(2);
    console.log(`Contract Coll. Token Balance: ${web3.utils.fromWei(contractBalanceTok.toString(), "ether")} Coll.Tokens`);
    tx = await this.loanContract.withdrawInterestsMassive([0, 1], {from: lender1});
    console.log(tx.receipt.gasUsed);
    totcost = tx.receipt.gasUsed * GAS_PRICE;
    console.log("Lender1 withdraw interests from loans costs: " + web3.utils.fromWei(totcost.toString(), 'ether') + " ETH");
    lenderBalTx = lenderBal - totcost;
    console.log("Lender1 balance after tx1: " + web3.utils.fromWei(lenderBalTx.toString(), "ether") + " ETH");
    tx = await this.loanContract.withdrawInterestsMassive([2, 3], {from: lender2});
    console.log(tx.receipt.gasUsed);
    totcost = tx.receipt.gasUsed * GAS_PRICE;
    console.log("Lender2 withdraw interests from loans costs: " + web3.utils.fromWei(totcost.toString(), 'ether') + " ETH");
    contractBalanceEthTx = await this.loanContract.getContractBalance(0);
    console.log(`Contract ETH Balance: ${web3.utils.fromWei(contractBalanceEthTx.toString(), "ether")} ETH`);
    diff = contractBalanceEth - contractBalanceEthTx;
    console.log(`Contract ETH Balance diff: ${web3.utils.fromWei(diff.toString(), "ether")} ETH`);
    contractBalanceTokTx = await this.loanContract.getContractBalance(2);
    console.log(`Contract Coll. Token Balance: ${web3.utils.fromWei(contractBalanceTokTx.toString(), "ether")} Coll.Tokens`);
    diff = contractBalanceTok - contractBalanceTokTx;
    console.log(`Contract Token Balance diff: ${web3.utils.fromWei(diff.toString(), "ether")} Coll.Toekns`);
    loanBalance = await this.loanContract.getLoanBalance(0);
    console.log(`Loan0 Balance: ${web3.utils.fromWei(loanBalance.toString(), "ether")} ETH`);
    loanBalance = await this.loanContract.getLoanBalance(1);
    console.log(`Loan1 Balance: ${web3.utils.fromWei(loanBalance.toString(), "ether")} ETH`);
    console.log("New collateral ratio loan0: " + await this.loanContract.getActualCollateralRatio(0));
    console.log("New collateral ratio loan1: " + await this.loanContract.getActualCollateralRatio(1));
    lenderBal = await web3.eth.getBalance(lender1);
    console.log(`New lender1 ETH Balance: ${web3.utils.fromWei(lenderBal, "ether")} ETH`);
    loanBalance = await this.loanContract.getLoanBalance(2);
    console.log(`Loan2 Balance: ${web3.utils.fromWei(loanBalance.toString(), "ether")} ETH`);
    loanBalance = await this.loanContract.getLoanBalance(3);
    console.log(`Loan3 Balance: ${web3.utils.fromWei(loanBalance.toString(), "ether")} ETH`);
    console.log("New collateral ratio loan2: " + await this.loanContract.getActualCollateralRatio(2));
    console.log("New collateral ratio loan3: " + await this.loanContract.getActualCollateralRatio(3));
    lenderBal = await this.erc20Coll1.balanceOf(lender2);
    console.log(`New lender2 Coll.Token Balance: ${web3.utils.fromWei(lenderBal, "ether")} Coll.Token`);
  });

  it('borrower1 settles loan0 (eth)', async function () {
    JFeesCollBalance = await this.JFeesCollector.getEthBalance();
    console.log(`JFeesCollector Balance: ${web3.utils.fromWei(JFeesCollBalance.toString(), "ether")} ETH`);
    tx = await this.erc20Lent1.approve(this.loanContract.address, web3.utils.toWei(STABLE_COIN_AMOUNT1.toString(),'ether'), {from: borrower1});
    console.log(tx.receipt.gasUsed);
    totcost = tx.receipt.gasUsed * GAS_PRICE;
    console.log("borrower1 approve costs: " + web3.utils.fromWei(totcost.toString(), 'ether') + " ETH");
    console.log("borrower1 Allowance: " + await this.erc20Lent1.allowance(borrower1, this.loanContract.address))
    console.log("Loan0 collateral ratio: " + await this.loanContract.getActualCollateralRatio(0));
    tx = await this.loanContract.loanClosingByBorrower(0, {from: borrower1});
    console.log(tx.receipt.gasUsed);
    totcost = tx.receipt.gasUsed * GAS_PRICE;
    console.log("borrower1 settlement costs: " + web3.utils.fromWei(totcost.toString(), 'ether') + " ETH");
    borrBal = await this.erc20Lent1.balanceOf(borrower1);
    console.log(`New borrower1 Stable coins Balance: ${web3.utils.fromWei(borrBal, "ether")} Stable coins`);
    loanStatus = await this.loanContract.getLoanStatus(0);
    console.log("Loan0 Status:" + loanStatus);
    loanStatus = await this.loanContract.getLoanStatus(1);
    console.log("Loan1 Status:" + loanStatus);
    JFeesCollBalance = await this.JFeesCollector.getEthBalance();
    console.log(`JFeesCollector Balance: ${web3.utils.fromWei(JFeesCollBalance.toString(), "ether")} ETH`);
    contractBalance = await this.loanContract.getContractBalance(0);
    console.log(`Contract Balance: ${web3.utils.fromWei(contractBalance.toString(), "ether")} ETH`);
    loanBalance = await this.loanContract.getLoanBalance(0);
    console.log(`Loan0 Balance: ${web3.utils.fromWei(loanBalance.toString(), "ether")} ETH`);
    console.log("Accrued interests loan0: " + await this.loanContract.getAccruedInterests(0));
    borrBal = await this.erc20Lent1.balanceOf(borrower1);
    console.log(`New borrower1 Stable coins Balance: ${web3.utils.fromWei(borrBal, "ether")} Stable coins`)
    borrBal = await this.erc20Lent1.balanceOf(lender1);
    console.log(`New lender1 Stable coins Balance: ${web3.utils.fromWei(borrBal, "ether")} Stable coins`)
    console.log("New collateral ratio loan0: " + await this.loanContract.getActualCollateralRatio(0));
  });

  it('borrower3 settles loan2 (token)', async function () {
    JFeesCollBalance = await this.JFeesCollector.getTokenBalance(this.erc20Coll1.address);
    console.log(`JFeesCollector Balance: ${web3.utils.fromWei(JFeesCollBalance.toString(), "ether")} Collat. Coins`);
    tx = await this.erc20Lent2.approve(this.loanContract.address, web3.utils.toWei(STABLE_COIN_AMOUNT3.toString(),'ether'), {from: borrower3});
    console.log(tx.receipt.gasUsed);
    totcost = tx.receipt.gasUsed * GAS_PRICE;
    console.log("borrower3 approve costs: " + web3.utils.fromWei(totcost.toString(), 'ether') + " ETH");
    console.log("borrower3 Allowance: " + await this.erc20Lent2.allowance(borrower3, this.loanContract.address))
    console.log("Loan2 collateral ratio: " + await this.loanContract.getActualCollateralRatio(2));
    tx = await this.loanContract.loanClosingByBorrower(2, {from: borrower3});
    console.log(tx.receipt.gasUsed);
    totcost = tx.receipt.gasUsed * GAS_PRICE;
    console.log("borrower3 settlement costs: " + web3.utils.fromWei(totcost.toString(), 'ether') + " ETH");
    borrBal = await this.erc20Lent2.balanceOf(borrower3);
    console.log(`New borrower3 Stable coins Balance: ${web3.utils.fromWei(borrBal, "ether")} Stable coins`);
    loanStatus = await this.loanContract.getLoanStatus(2);
    console.log("Loan2 Status:" + loanStatus);
    loanStatus = await this.loanContract.getLoanStatus(3);
    console.log("Loan3 Status:" + loanStatus);
    JFeesCollBalance = await this.JFeesCollector.getTokenBalance(this.erc20Coll1.address);
    console.log(`New JFeesCollector Balance: ${web3.utils.fromWei(JFeesCollBalance.toString(), "ether")} Collat. Coins`);
    contractBalance = await this.loanContract.getContractBalance(2);
    console.log(`Contract Balance: ${web3.utils.fromWei(contractBalance.toString(), "ether")} Collat. Coins`);
    loanBalance = await this.loanContract.getLoanBalance(2);
    console.log(`Loan2 Balance: ${web3.utils.fromWei(loanBalance.toString(), "ether")} Collat. Coins`);
    console.log("Accrued interests loan2: " + await this.loanContract.getAccruedInterests(0));
    borrBal = await this.erc20Lent2.balanceOf(borrower3);
    console.log(`New borrower3 Stable coins Balance: ${web3.utils.fromWei(borrBal, "ether")} Stable coins`)
    borrBal = await this.erc20Lent2.balanceOf(lender2);
    console.log(`New lender2 Stable coins Balance: ${web3.utils.fromWei(borrBal, "ether")} Stable coins`)
    console.log("New collateral ratio loan0: " + await this.loanContract.getActualCollateralRatio(2));
  });

  it('lender1 can continue to have accrued interests from loan0 and loan1 as per RPB', async function () {
    let block = await web3.eth.getBlock("latest");
    console.log("Actual Block: " + block.number);
    newBlock = block.number + 50;
    await time.advanceBlockTo(newBlock);
    //await time.increase(time.duration.days(2));
    lenderBal = await web3.eth.getBalance(lender1); 
    console.log(`Lender ETH Balance: ${web3.utils.fromWei(lenderBal, "ether")} ETH`)
    console.log("Accrued interests loan0: " + await this.loanContract.getAccruedInterests(0));
    console.log("Accrued interests loan1: " + await this.loanContract.getAccruedInterests(1));
    contractBalance = await this.loanContract.getContractBalance(0);
    console.log(`Contract Balance: ${web3.utils.fromWei(contractBalance.toString(), "ether")} ETH`);
    loanBalance = await this.loanContract.getLoanBalance(0);
    console.log(`Loan 0 Balance: ${web3.utils.fromWei(loanBalance.toString(), "ether")} ETH`);
    loanBalance = await this.loanContract.getLoanBalance(1);
    console.log(`Loan 1 Balance: ${web3.utils.fromWei(loanBalance.toString(), "ether")} ETH`);
    tx = await this.loanContract.withdrawInterests(0, {from: lender1});
    console.log(tx.receipt.gasUsed);
    totcost = tx.receipt.gasUsed * GAS_PRICE;
    console.log("Lender withdraw interests loan0 costs: " + web3.utils.fromWei(totcost.toString(), 'ether') + " ETH");
    tx = await this.loanContract.withdrawInterests(1, {from: lender1});
    console.log(tx.receipt.gasUsed);
    totcost = tx.receipt.gasUsed * GAS_PRICE;
    console.log("Lender withdraw interests loan1 costs: " + web3.utils.fromWei(totcost.toString(), 'ether') + " ETH");
    block = await web3.eth.getBlock("latest");
    console.log("New Block: " + block.number);
    contractBalance = await this.loanContract.getContractBalance(0);
    console.log(`Contract Balance: ${web3.utils.fromWei(contractBalance.toString(), "ether")} ETH`);
    loanBalance = await this.loanContract.getLoanBalance(0);
    console.log(`Loan 0 Balance: ${web3.utils.fromWei(loanBalance.toString(), "ether")} ETH`);
    loanBalance = await this.loanContract.getLoanBalance(1);
    console.log(`Loan 1 Balance: ${web3.utils.fromWei(loanBalance.toString(), "ether")} ETH`);
    lenderBal = await web3.eth.getBalance(lender1); 
    console.log(`New lender1 ETH Balance: ${web3.utils.fromWei(lenderBal, "ether")} ETH`)
  });

  it('lender1 add more shareholders to loan0', async function () {
    tx = await this.loanContract.addLoanShareholdersMassive(0, [lender2, lender3], [20, 30], {from: lender1});
    //console.log(tx);
    console.log(tx.receipt.gasUsed);
    totcost = tx.receipt.gasUsed * GAS_PRICE;
    console.log("lender1 settlement costs: " + web3.utils.fromWei(totcost.toString(), 'ether') + " ETH");
  });

  it('lenders can have accrued interests from contracts as per RPB calling single function', async function () {
    let block = await web3.eth.getBlock("latest");
    console.log("Actual Block: " + block.number);
    newBlock = block.number + 50;
    await time.advanceBlockTo(newBlock);
    lenderBal = await web3.eth.getBalance(lender1);
    console.log(`Lender1 ETH Balance: ${web3.utils.fromWei(lenderBal, "ether")} ETH`)
    lenderCollBal = await this.erc20Coll1.balanceOf(lender2);
    console.log(`Lender2 Coll.Token Balance: ${web3.utils.fromWei(lenderCollBal, "ether")} Coll.Token`)
    console.log("Accrued interests loan0: " + await this.loanContract.getAccruedInterests(0));
    console.log("Accrued interests loan1: " + await this.loanContract.getAccruedInterests(1));
    console.log("Accrued interests loan2: " + await this.loanContract.getAccruedInterests(2));
    console.log("Accrued interests loan3: " + await this.loanContract.getAccruedInterests(3));
    contractBalanceEth = await this.loanContract.getContractBalance(0);
    console.log(`Contract ETH Balance: ${web3.utils.fromWei(contractBalanceEth.toString(), "ether")} ETH`);
    contractBalanceTok = await this.loanContract.getContractBalance(2);
    console.log(`Contract Coll. Token Balance: ${web3.utils.fromWei(contractBalanceTok.toString(), "ether")} Coll.Tokens`);
    tx = await this.loanContract.withdrawInterestsMassive([0, 1], {from: lender1});
    console.log(tx.receipt.gasUsed);
    totcost = tx.receipt.gasUsed * GAS_PRICE;
    console.log("Lender1 withdraw interests from loans costs: " + web3.utils.fromWei(totcost.toString(), 'ether') + " ETH");
    lenderBalTx = lenderBal - totcost;
    console.log("Lender1 balance after tx1: " + web3.utils.fromWei(lenderBalTx.toString(), "ether") + " ETH");
    tx = await this.loanContract.withdrawInterestsMassive([2, 3], {from: lender2});
    console.log(tx.receipt.gasUsed);
    totcost = tx.receipt.gasUsed * GAS_PRICE;
    console.log("Lender2 withdraw interests from loans costs: " + web3.utils.fromWei(totcost.toString(), 'ether') + " ETH");
    contractBalanceEthTx = await this.loanContract.getContractBalance(0);
    console.log(`Contract ETH Balance: ${web3.utils.fromWei(contractBalanceEthTx.toString(), "ether")} ETH`);
    diff = contractBalanceEth - contractBalanceEthTx;
    console.log(`Contract ETH Balance diff: ${web3.utils.fromWei(diff.toString(), "ether")} ETH`);
    contractBalanceTokTx = await this.loanContract.getContractBalance(2);
    console.log(`Contract Coll. Token Balance: ${web3.utils.fromWei(contractBalanceTokTx.toString(), "ether")} Coll.Tokens`);
    diff = contractBalanceTok - contractBalanceTokTx;
    console.log(`Contract Token Balance diff: ${web3.utils.fromWei(diff.toString(), "ether")} Coll.Toekns`);
    loanBalance = await this.loanContract.getLoanBalance(0);
    console.log(`Loan0 Balance: ${web3.utils.fromWei(loanBalance.toString(), "ether")} ETH`);
    loanBalance = await this.loanContract.getLoanBalance(1);
    console.log(`Loan1 Balance: ${web3.utils.fromWei(loanBalance.toString(), "ether")} ETH`);
    console.log("New collateral ratio loan0: " + await this.loanContract.getActualCollateralRatio(0));
    console.log("New collateral ratio loan1: " + await this.loanContract.getActualCollateralRatio(1));
    lenderBal = await web3.eth.getBalance(lender1);
    console.log(`New lender1 ETH Balance: ${web3.utils.fromWei(lenderBal, "ether")} ETH`);
    lenderBal = await web3.eth.getBalance(lender2);
    console.log(`New lender2 ETH Balance: ${web3.utils.fromWei(lenderBal, "ether")} ETH`);
    lenderBal = await web3.eth.getBalance(lender3);
    console.log(`New lender3 ETH Balance: ${web3.utils.fromWei(lenderBal, "ether")} ETH`);
    loanBalance = await this.loanContract.getLoanBalance(2);
    console.log(`Loan2 Balance: ${web3.utils.fromWei(loanBalance.toString(), "ether")} ETH`);
    loanBalance = await this.loanContract.getLoanBalance(3);
    console.log(`Loan3 Balance: ${web3.utils.fromWei(loanBalance.toString(), "ether")} ETH`);
    console.log("New collateral ratio loan2: " + await this.loanContract.getActualCollateralRatio(2));
    console.log("New collateral ratio loan3: " + await this.loanContract.getActualCollateralRatio(3));
    lenderBal = await this.erc20Coll1.balanceOf(lender2);
    console.log(`New lender2 Coll.Token Balance: ${web3.utils.fromWei(lenderBal, "ether")} Coll.Token`);
  });


});