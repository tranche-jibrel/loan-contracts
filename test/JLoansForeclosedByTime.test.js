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

describe('JLoansForeclosedByTime', function () {

  const GAS_PRICE = 27000000000; //Gwei = 10 ** 9 wei

  const [ tokenOwner, factoryOwner, borrower1, borrower2, borrower3, borrower4, lender1, lender2, factoryAdmin, foreclosureAgent ] = accounts;

  //beforeEach(async function () {

  //});

  factoryInitialization(tokenOwner, factoryOwner, borrower3, borrower4, lender1, lender2, factoryAdmin);

  borrowersOpenLoans(factoryOwner, borrower1, borrower2, borrower3, borrower4, lender1, lender2);

  lendersActivateLoans(borrower1, borrower2, borrower3, borrower4, lender1, lender2);

  borrowersAddCollateral(borrower1, borrower2, borrower3, borrower4);

  lendersGetAccruedInterest(lender1, lender2);

  priceDownfor150(factoryAdmin);

  firstForeclosing(foreclosureAgent);

  it('borrower2 can send collateral to set loan1 back in active state', async function () {
    console.log("Loan1 collateral ratio: " + await this.JLoan.getActualCollateralRatio(1));
    collToAdd = await this.JLoan.calcDiffCollAmountForRatio(1, 155);
    console.log("Collateral to add to raise ratio to 155%: " + collToAdd);
    tx = await this.JLoan.depositEthCollateral(1, {from: borrower2, value: collToAdd})
    console.log(tx.receipt.gasUsed);
    totcost = tx.receipt.gasUsed * GAS_PRICE;
    console.log("Borrower2 adding collateral costs: " + web3.utils.fromWei(totcost.toString(), 'ether') + " ETH");
    contractBalance = await this.JLoan.getContractBalance(1);
    console.log(`Contract Balance: ${web3.utils.fromWei(contractBalance.toString(), "ether")} ETH`);
    loanBalance = await this.JLoan.getLoanBalance(0);
    console.log(`Loan0 Balance: ${web3.utils.fromWei(loanBalance.toString(), "ether")} ETH`);
    loanBalance = await this.JLoan.getLoanBalance(1);
    console.log(`Loan1 Balance: ${web3.utils.fromWei(loanBalance.toString(), "ether")} ETH`);
    console.log("New collateral ratio loan0: " + await this.JLoan.getActualCollateralRatio(0));
    console.log("New collateral ratio loan1: " + await this.JLoan.getActualCollateralRatio(1));
    loanStatus0 = await this.JLoan.getLoanStatus(0);
    console.log("Loan0 Status:" + loanStatus0);
    loanStatus1 = await this.JLoan.getLoanStatus(1);
    console.log("Loan1 Status:" + loanStatus1);
    expect(loanStatus0).to.be.bignumber.equal(new BN(4).toString());
    expect(loanStatus1).to.be.bignumber.equal(new BN(1).toString());
  });

  it('borrower1 can send collateral to set loan0 back in active state, but not enough Eth', async function () {
    console.log("Loan0 collateral ratio: " + await this.JLoan.getActualCollateralRatio(0));
    collToAdd = await this.JLoan.calcDiffCollAmountForRatio(0, 155);
    console.log("Collateral to add to raise ratio to 155%: " + collToAdd);
    await expectRevert(this.JLoan.depositEthCollateral(0, {from: borrower1, value: collToAdd}), "Returned error: sender doesn't have enough funds to send tx. The upfront cost is: 9852944210179369276 and the sender's account only has: 5973322053170266123");
    contractBalance = await this.JLoan.getContractBalance(0);
    console.log(`Contract Balance: ${web3.utils.fromWei(contractBalance.toString(), "ether")} ETH`);
    loanBalance = await this.JLoan.getLoanBalance(0);
    console.log(`Loan0 Balance: ${web3.utils.fromWei(loanBalance.toString(), "ether")} ETH`);
    loanBalance = await this.JLoan.getLoanBalance(1);
    console.log(`Loan1 Balance: ${web3.utils.fromWei(loanBalance.toString(), "ether")} ETH`);
    console.log("New collateral ratio loan0: " + await this.JLoan.getActualCollateralRatio(0));
    console.log("New collateral ratio loan1: " + await this.JLoan.getActualCollateralRatio(1));
    loanStatus0 = await this.JLoan.getLoanStatus(0);
    console.log("Loan0 Status:" + loanStatus0);
    loanStatus1 = await this.JLoan.getLoanStatus(1);
    console.log("Loan1 Status:" + loanStatus1);
    expect(loanStatus0).to.be.bignumber.equal(new BN(4).toString());
    expect(loanStatus1).to.be.bignumber.equal(new BN(1).toString());
  });

  it('borrower4 can send collateral to set loan3 back in active state', async function () {
    console.log("Loan3 collateral ratio: " + await this.JLoan.getActualCollateralRatio(3));
    collToAdd = await this.JLoan.calcDiffCollAmountForRatio(3, 155);
    console.log("Collateral to add to raise ratio to 155%: " + collToAdd);
    tx = await this.erc20Coll1.approve(this.JLoan.address, collToAdd, {from: borrower4});
    console.log(tx.receipt.gasUsed);
    totcost = tx.receipt.gasUsed * GAS_PRICE;
    console.log("borrower4 approve costs: " + web3.utils.fromWei(totcost.toString(), 'ether') + " ETH");
    tx = await this.JLoan.depositTokenCollateral(3, this.erc20Coll1.address, collToAdd, {from: borrower4});
    console.log(tx.receipt.gasUsed);
    totcost = tx.receipt.gasUsed * GAS_PRICE;
    console.log("borrower4 adding collateral costs: " + web3.utils.fromWei(totcost.toString(), 'ether') + " ETH");
    contractBalance = await this.JLoan.getContractBalance(3);
    console.log(`Contract Balance: ${web3.utils.fromWei(contractBalance.toString(), "ether")} ETH`);
    loanBalance = await this.JLoan.getLoanBalance(2);
    console.log(`Loan2 Balance: ${web3.utils.fromWei(loanBalance.toString(), "ether")} ETH`);
    loanBalance = await this.JLoan.getLoanBalance(3);
    console.log(`Loan3 Balance: ${web3.utils.fromWei(loanBalance.toString(), "ether")} ETH`);
    console.log("New collateral ratio loan0: " + await this.JLoan.getActualCollateralRatio(2));
    console.log("New collateral ratio loan1: " + await this.JLoan.getActualCollateralRatio(3));
    loanStatus2 = await this.JLoan.getLoanStatus(2);
    console.log("Loan0 Status:" + loanStatus2);
    loanStatus3 = await this.JLoan.getLoanStatus(3);
    console.log("Loan1 Status:" + loanStatus3);
    expect(loanStatus2).to.be.bignumber.equal(new BN(4).toString());
    expect(loanStatus3).to.be.bignumber.equal(new BN(1).toString());
  });

  it('pair price goes down again, collateral under 150%, foreclosing', async function () {
    console.log("Pair price: " + await this.JPriceOracle.getPairValue(0));
    tx = await this.JPriceOracle.setPairValue(0, 19000, 2, {from: factoryOwner});
    console.log(tx.receipt.gasUsed);
    totcost = tx.receipt.gasUsed * GAS_PRICE;
    console.log("Pair0 price costs: " + web3.utils.fromWei(totcost.toString(), 'ether') + " ETH");
    pair = await this.JPriceOracle.pairs(0);
    newPrice = await this.JPriceOracle.getPairValue(0);
    expect(newPrice).to.be.bignumber.equal(pair.pairValue);
    console.log("New pair0 price: " + await this.JPriceOracle.getPairValue(0));
    tx = await this.JPriceOracle.setPairValue(1, 8585, 6, {from: factoryOwner});
    console.log(tx.receipt.gasUsed);
    totcost = tx.receipt.gasUsed * GAS_PRICE;
    console.log("Pair1 price costs: " + web3.utils.fromWei(totcost.toString(), 'ether') + " ETH");
    pair = await this.JPriceOracle.pairs(1);
    newPrice = await this.JPriceOracle.getPairValue(1);
    expect(newPrice).to.be.bignumber.equal(pair.pairValue);
    console.log("New pair1 price: " + await this.JPriceOracle.getPairValue(1));
    console.log("Loan0 collateral ratio: " + await this.JLoan.getActualCollateralRatio(0));
    console.log("Loan1 collateral ratio: " + await this.JLoan.getActualCollateralRatio(1));
    console.log("Loan2 collateral ratio: " + await this.JLoan.getActualCollateralRatio(2));
    console.log("Loan3 collateral ratio: " + await this.JLoan.getActualCollateralRatio(3));
    loanStatus0 = await this.JLoan.getLoanStatus(0);
    console.log("Loan0 Status:" + loanStatus0);
    loanStatus1 = await this.JLoan.getLoanStatus(1);
    console.log("Loan1 Status:" + loanStatus1);
    loanStatus2 = await this.JLoan.getLoanStatus(2);
    console.log("Loan2 Status:" + loanStatus2);
    loanStatus3 = await this.JLoan.getLoanStatus(3);
    console.log("Loan3 Status:" + loanStatus3);
    expect(loanStatus0).to.be.bignumber.equal(new BN(4).toString());
    expect(loanStatus1).to.be.bignumber.equal(new BN(1).toString());
    expect(loanStatus2).to.be.bignumber.equal(new BN(4).toString());
    expect(loanStatus3).to.be.bignumber.equal(new BN(1).toString());
  });

  it('initiate foreclosure procedures for collateral under 150%, status from 1 to 4 for loan1, from 4 to 5 loan0', async function () {
    agentBal = await web3.eth.getBalance(foreclosureAgent);
    console.log(`foreclosureAgent Balance: ${web3.utils.fromWei(agentBal, "ether")} ETH`);
    tx = await this.JLoan.setLoanToForeclosed(0, {from: foreclosureAgent});
    console.log(tx.receipt.gasUsed);
    totcost = tx.receipt.gasUsed * GAS_PRICE;
    console.log("Initiate Loan0 Foreclose costs: " + web3.utils.fromWei(totcost.toString(), 'ether') + " ETH");
    agentBal = await web3.eth.getBalance(foreclosureAgent);
    console.log(`foreclosureAgent Balance: ${web3.utils.fromWei(agentBal, "ether")} ETH`);
    loanStatus0 = await this.JLoan.getLoanStatus(0);
    console.log("Loan0 Status:" + loanStatus0);
    expect(loanStatus0).to.be.bignumber.equal(new BN(5).toString());
    tx = await this.JLoan.initiateLoanForeclose(1, {from: foreclosureAgent});
    console.log(tx.receipt.gasUsed);
    totcost = tx.receipt.gasUsed * GAS_PRICE;
    console.log("Initiate Loan1 Foreclose costs: " + web3.utils.fromWei(totcost.toString(), 'ether') + " ETH");
    agentBal = await web3.eth.getBalance(foreclosureAgent);
    console.log(`foreclosureAgent Balance: ${web3.utils.fromWei(agentBal, "ether")} ETH`);
    loanStatus = await this.JLoan.getLoanStatus(0);
    console.log("Loan0 Status:" + loanStatus);
    expect(loanStatus).to.be.bignumber.equal(new BN(5).toString());
    loanStatus = await this.JLoan.getLoanStatus(1);
    console.log("Loan1 Status:" + loanStatus);
    expect(loanStatus).to.be.bignumber.equal(new BN(4).toString());
    JFeesCollBalance = await this.JFeesCollector.getEthBalance();
    console.log(`JFeesCollector Balance: ${web3.utils.fromWei(JFeesCollBalance.toString(), "ether")} ETH`);
    console.log("Loan0 collateral ratio: " + await this.JLoan.getActualCollateralRatio(0));
    console.log("Loan1 collateral ratio: " + await this.JLoan.getActualCollateralRatio(1));
    console.log("Loan0 Foreclosing Block:" + await this.JLoan.loanForeclosingBlock(0));
    console.log("Loan1 Foreclosing Block:" + await this.JLoan.loanForeclosingBlock(1));
  });

  it('initiate again foreclosure procedures for collateral under 150% for loan0 and loan1', async function () {
    await expectRevert(this.JLoan.initiateLoanForeclose(0, {from: foreclosureAgent}), "!Status23");
    await expectRevert(this.JLoan.initiateLoanForeclose(1, {from: foreclosureAgent}), "!Status23");
  });

  it('initiate foreclosure procedures for collateral under 150%, status from 1 to 4 for loan3, from 4 to 5 loan2', async function () {
    agentBal = await web3.eth.getBalance(foreclosureAgent);
    console.log(`foreclosureAgent Balance: ${web3.utils.fromWei(agentBal, "ether")} ETH`);
    tx = await this.JLoan.setLoanToForeclosed(2, {from: foreclosureAgent});
    console.log(tx.receipt.gasUsed);
    totcost = tx.receipt.gasUsed * GAS_PRICE;
    console.log("Initiate Loan2 Foreclose costs: " + web3.utils.fromWei(totcost.toString(), 'ether') + " ETH");
    agentBal = await web3.eth.getBalance(foreclosureAgent);
    console.log(`foreclosureAgent Balance: ${web3.utils.fromWei(agentBal, "ether")} ETH`);
    loanStatus2 = await this.JLoan.getLoanStatus(2);
    console.log("Loan2 Status:" + loanStatus2);
    expect(loanStatus2).to.be.bignumber.equal(new BN(5).toString());
    loanStatus3 = await this.JLoan.getLoanStatus(3);
    console.log("Loan3 Status:" + loanStatus3);
    tx = await this.JLoan.initiateLoanForeclose(3, {from: foreclosureAgent});
    console.log(tx.receipt.gasUsed);
    totcost = tx.receipt.gasUsed * GAS_PRICE;
    console.log("Initiate Loan3 Foreclose costs: " + web3.utils.fromWei(totcost.toString(), 'ether') + " ETH");
    agentBal = await web3.eth.getBalance(foreclosureAgent);
    console.log(`foreclosureAgent Balance: ${web3.utils.fromWei(agentBal, "ether")} ETH`);
    loanStatus = await this.JLoan.getLoanStatus(2);
    console.log("Loan2 Status:" + loanStatus);
    expect(loanStatus).to.be.bignumber.equal(new BN(5).toString());
    loanStatus = await this.JLoan.getLoanStatus(3);
    console.log("Loan3 Status:" + loanStatus);
    expect(loanStatus).to.be.bignumber.equal(new BN(4).toString());
    JFeesCollBalance = await this.JFeesCollector.getTokenBalance(this.erc20Coll1.address);
    console.log(`JFeesCollector Balance: ${web3.utils.fromWei(JFeesCollBalance.toString(), "ether")} Coll.Token`);
    console.log("Loan2 collateral ratio: " + await this.JLoan.getActualCollateralRatio(2));
    console.log("Loan3 collateral ratio: " + await this.JLoan.getActualCollateralRatio(3));
    console.log("Loan2 Foreclosing Block:" + await this.JLoan.loanForeclosingBlock(2));
    console.log("Loan3 Foreclosing Block:" + await this.JLoan.loanForeclosingBlock(3));
  });

  it('initiate again foreclosure procedures for collateral under 150% for loan2 and loan3', async function () {
    await expectRevert(this.JLoan.initiateLoanForeclose(2, {from: foreclosureAgent}), "!Status23");
    await expectRevert(this.JLoan.initiateLoanForeclose(3, {from: foreclosureAgent}), "!Status23");
  });

  it ("factory owner change ForeclosureWindow", async function () {
    let block = await web3.eth.getBlock("latest");
    console.log("Actual Block: " + block.number);
    genParams = await this.JLoan.getGeneralParams();
    console.log("Foreclosure Window: " + genParams.foreclosureWindow);
    tx = await this.JLoan.setForeclosureWindow(50, {from: factoryOwner});
    console.log(tx.receipt.gasUsed);
    totcost = tx.receipt.gasUsed * GAS_PRICE;
    console.log("Foreclosure Window change costs: " + web3.utils.fromWei(totcost.toString(), 'ether') + " ETH");
    genParams = await this.JLoan.getGeneralParams();
    console.log("New Foreclosure Window: " + genParams.foreclosureWindow);
    genLoanParams = await this.JLoan.generalLoansParams();
    console.log("Get loans params: " + genLoanParams.foreclosureWindow);
    newBlock = block.number + 50;
    await time.advanceBlockTo(newBlock);
    block = await web3.eth.getBlock("latest");
    console.log("New Actual Block: " + block.number);
  });

  it ("foreclosure agent call foreclosed by time function", async function () {
    loanStatus = await this.JLoan.getLoanStatus(0);
    console.log("Loan0 Status:" + loanStatus);
    loanStatus = await this.JLoan.getLoanStatus(1);
    console.log("Loan1 Status:" + loanStatus);
    agentBal = await web3.eth.getBalance(foreclosureAgent);
    console.log(`foreclosureAgent Balance: ${web3.utils.fromWei(agentBal, "ether")} ETH`);
    await expectRevert(this.JLoan.setLoanToForeclosed(0, {from: foreclosureAgent}), "!Status4");
    agentBal = await web3.eth.getBalance(foreclosureAgent);
    console.log(`foreclosureAgent Balance: ${web3.utils.fromWei(agentBal, "ether")} ETH`);
    tx = await this.JLoan.setLoanToForeclosed(1, {from: foreclosureAgent});
    console.log(tx.receipt.gasUsed);
    totcost = tx.receipt.gasUsed * GAS_PRICE;
    console.log("Foreclosure by time loan1 costs: " + web3.utils.fromWei(totcost.toString(), 'ether') + " ETH");
    await expectRevert(this.JLoan.setLoanToForeclosed(2, {from: foreclosureAgent}), "!Status4");
    agentBal = await web3.eth.getBalance(foreclosureAgent);
    console.log(`foreclosureAgent Balance: ${web3.utils.fromWei(agentBal, "ether")} ETH`);
    tx = await this.JLoan.setLoanToForeclosed(3, {from: foreclosureAgent});
    console.log(tx.receipt.gasUsed);
    totcost = tx.receipt.gasUsed * GAS_PRICE;
    console.log("Foreclosure by time loan3 costs: " + web3.utils.fromWei(totcost.toString(), 'ether') + " ETH");
    JFeesCollBalance = await this.JFeesCollector.getEthBalance();
    console.log(`JFeesCollector Balance: ${web3.utils.fromWei(JFeesCollBalance.toString(), "ether")} ETH`);
    JFeesCollBalance = await this.JFeesCollector.getTokenBalance(this.erc20Coll1.address);
    console.log(`JFeesCollector Balance: ${web3.utils.fromWei(JFeesCollBalance.toString(), "ether")} Coll.Token`);
    console.log("Loan0 collateral ratio: " + await this.JLoan.getActualCollateralRatio(0));
    console.log("Loan1 collateral ratio: " + await this.JLoan.getActualCollateralRatio(1));
    console.log("Loan2 collateral ratio: " + await this.JLoan.getActualCollateralRatio(2));
    console.log("Loan3 collateral ratio: " + await this.JLoan.getActualCollateralRatio(3));
    loanStatus = await this.JLoan.getLoanStatus(0);
    console.log("Loan0 Status:" + loanStatus);
    expect(loanStatus).to.be.bignumber.equal(new BN(5).toString());
    loanStatus = await this.JLoan.getLoanStatus(1);
    console.log("Loan1 Status:" + loanStatus);
    expect(loanStatus).to.be.bignumber.equal(new BN(5).toString());
    loanStatus = await this.JLoan.getLoanStatus(2);
    console.log("Loan2 Status:" + loanStatus);
    expect(loanStatus).to.be.bignumber.equal(new BN(5).toString());
    loanStatus = await this.JLoan.getLoanStatus(3);
    console.log("Loan3 Status:" + loanStatus);
    expect(loanStatus).to.be.bignumber.equal(new BN(5).toString());
    console.log("Loan0 Foreclosed Block:" + await this.JLoan.loanForeclosedBlock(0));
    console.log("Loan1 Foreclosed Block:" + await this.JLoan.loanForeclosedBlock(1));
    console.log("Loan2 Foreclosed Block:" + await this.JLoan.loanForeclosedBlock(2));
    console.log("Loan3 Foreclosed Block:" + await this.JLoan.loanForeclosedBlock(3));
  });

  it('initiate again foreclosure procedures for collateral under 120% for loans', async function () {
    await expectRevert(this.JLoan.initiateLoanForeclose(0, {from: foreclosureAgent}), "!Status23");
    await expectRevert(this.JLoan.initiateLoanForeclose(1, {from: foreclosureAgent}), "!Status23");
    await expectRevert(this.JLoan.initiateLoanForeclose(2, {from: foreclosureAgent}), "!Status23");
    await expectRevert(this.JLoan.initiateLoanForeclose(3, {from: foreclosureAgent}), "!Status23");
  });

  it('borrowers cannot send any collateral to foreclosed contract', async function () {
    one_eth = web3.utils.toWei('1', "ether");
    await expectRevert(web3.eth.sendTransaction({from: borrower1, to: this.JLoan.address, value: one_eth}), "revert");
    await expectRevert(this.JLoan.depositEthCollateral(0, {from: borrower1, value: one_eth}), "!Status04");
    await expectRevert(this.JLoan.depositEthCollateral(1, {from: borrower2, value: one_eth}), "!Status04");
  });

  it('time passes...', async function () {
    let block = await web3.eth.getBlock("latest");
    console.log("Actual Block: " + block.number);
    newBlock = block.number + 50;
    await time.advanceBlockTo(newBlock);
  });

  lendersGetAccruedInterest(lender1, lender2);

});