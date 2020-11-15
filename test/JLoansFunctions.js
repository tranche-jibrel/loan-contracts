const { accounts, contract, web3 } = require('@openzeppelin/test-environment');
const { BN, constants, expectEvent, expectRevert } = require('@openzeppelin/test-helpers');
const { expect } = require('chai');
const { ZERO_ADDRESS } = constants;

const myERC20 = contract.fromArtifact("myERC20");
const JFeesCollector = contract.fromArtifact("JFeesCollector");
const JLoanDeployer = contract.fromArtifact('JLoanDeployer');
const JPriceOracle = contract.fromArtifact('JPriceOracle');
const JLoan = contract.fromArtifact('JLoan');
const JFactory = contract.fromArtifact("JFactory");

const MYERC20_TOKEN_SUPPLY = 5000000; 
const GAS_PRICE = 27000000000;
const LOAN_RPB_RATE = 1000000000;
const STABLE_COIN_AMOUNT1 = 15000;
const STABLE_COIN_AMOUNT2 = 10000;
const STABLE_COIN_AMOUNT3 = 1500;
const STABLE_COIN_AMOUNT4 = 1000;

function factoryInitialization (tokenOwner, factoryOwner, borrower3, borrower4, lender1, lender2, factoryAdmin) {
  it('deploys collateral erc20Coll', async function () {
    //gasPrice = await web3.eth.getGasPrice();
    //console.log("Gas price: " + gasPrice);
    this.erc20Coll1 = await myERC20.new(MYERC20_TOKEN_SUPPLY, { from: tokenOwner });
    expect(this.erc20Coll1.address).to.be.not.equal(ZERO_ADDRESS);
    expect(this.erc20Coll1.address).to.match(/0x[0-9a-fA-F]{40}/);
    console.log(`Coll Token Address: ${this.erc20Coll1.address}`);
    const tx = await web3.eth.getTransactionReceipt(this.erc20Coll1.transactionHash);
    console.log("ERC20 Coll deploy Gas: " + tx.gasUsed);
    totcost = tx.gasUsed * GAS_PRICE;
    console.log("ERC20 Coll deploy costs: " + web3.utils.fromWei(totcost.toString(), 'ether') + " ETH");
  });

  it('deploys collateral erc20Lent1', async function () {
    //gasPrice = await web3.eth.getGasPrice();
    //console.log("Gas price: " + gasPrice);
    this.erc20Lent1 = await myERC20.new(MYERC20_TOKEN_SUPPLY, { from: tokenOwner });
    expect(this.erc20Lent1.address).to.be.not.equal(ZERO_ADDRESS);
    expect(this.erc20Lent1.address).to.match(/0x[0-9a-fA-F]{40}/);
    console.log(`Stable coin1 Token1 Address: ${this.erc20Lent1.address}`);
    const tx = await web3.eth.getTransactionReceipt(this.erc20Lent1.transactionHash);
    console.log("ERC20 Lent1 deploy Gas: " + tx.gasUsed);
    totcost = tx.gasUsed * GAS_PRICE;
    console.log("ERC20 Lent1 deploy costs: " + web3.utils.fromWei(totcost.toString(), 'ether') + " ETH");
  });

  it('deploys lent erc20Lent2', async function () {
    this.erc20Lent2 = await myERC20.new(MYERC20_TOKEN_SUPPLY, { from: tokenOwner });
    expect(this.erc20Lent2.address).to.be.not.equal(ZERO_ADDRESS);
    expect(this.erc20Lent2.address).to.match(/0x[0-9a-fA-F]{40}/);
    console.log(`Stable coin2 Address: ${this.erc20Lent2.address}`);
    const tx = await web3.eth.getTransactionReceipt(this.erc20Lent2.transactionHash);
    console.log("ERC20 Lent2 deploy Gas: " + tx.gasUsed);
    totcost = tx.gasUsed * GAS_PRICE;
    console.log("ERC20 Lent2 deploy costs: " + web3.utils.fromWei(totcost.toString(), 'ether') + " ETH");
  });

  it('send some collateral tokens to borrower3', async function () {
    tx = await this.erc20Coll1.transfer(borrower3, web3.utils.toWei('1000000','ether'), { from: tokenOwner });
    console.log("Gas to transfer tokens to borrower3: " + tx.receipt.gasUsed);
    totcost = tx.receipt.gasUsed * GAS_PRICE;
    console.log("transfer token costs: " + web3.utils.fromWei(totcost.toString(), 'ether') + " ETH");
    borrBal = await this.erc20Coll1.balanceOf(borrower3);
    console.log(`borrower3 Collateral Balance: ${web3.utils.fromWei(borrBal, "ether")} Coll Tokens`);
    expect(web3.utils.fromWei(borrBal, "ether")).to.be.equal(new BN(1000000).toString());
  });

  it('send some collateral tokens to borrower4', async function () {
    tx = await this.erc20Coll1.transfer(borrower4, web3.utils.toWei('1500000','ether'), { from: tokenOwner });
    console.log("Gas to transfer tokens to borrower4: " + tx.receipt.gasUsed);
    totcost = tx.receipt.gasUsed * GAS_PRICE;
    console.log("transfer token costs: " + web3.utils.fromWei(totcost.toString(), 'ether') + " ETH");
    borrBal = await this.erc20Coll1.balanceOf(borrower4);
    console.log(`borrower4 Collateral Balance: ${web3.utils.fromWei(borrBal, "ether")} Coll Tokens`);
    expect(web3.utils.fromWei(borrBal, "ether")).to.be.equal(new BN(1500000).toString());
  });

  it('send some stable coin1 tokens to lender1', async function () {
    tx = await this.erc20Lent1.transfer(lender1, web3.utils.toWei('1000000','ether'), { from: tokenOwner });
    console.log("Gas to transfer tokens to lender1: " + tx.receipt.gasUsed);
    totcost = tx.receipt.gasUsed * GAS_PRICE;
    console.log("transfer token costs: " + web3.utils.fromWei(totcost.toString(), 'ether') + " ETH");
    lenderBal = await this.erc20Lent1.balanceOf(lender1);
    console.log(`Lender1 Stable Coin Balance: ${web3.utils.fromWei(lenderBal, "ether")} Stable Coin1 Tokens`)
    expect(web3.utils.fromWei(lenderBal, "ether")).to.be.equal(new BN(1000000).toString());
  });

  it('send some stable coin2 tokens to lender2', async function () {
    tx = await this.erc20Lent2.transfer(lender2, web3.utils.toWei('1000000','ether'), { from: tokenOwner });
    console.log("Gas to transfer tokens to lender2: " + tx.receipt.gasUsed);
    totcost = tx.receipt.gasUsed * GAS_PRICE;
    console.log("transfer token costs: " + web3.utils.fromWei(totcost.toString(), 'ether') + " ETH");
    lenderBal = await this.erc20Lent2.balanceOf(lender2);
    console.log(`Lender2 Stable Coin Balance: ${web3.utils.fromWei(lenderBal, "ether")} Stable Coin2 Tokens`)
    expect(web3.utils.fromWei(lenderBal, "ether")).to.be.equal(new BN(1000000).toString());
  });

  it('deploys JFeeCollector', async function () {
    this.JFeesCollector = await JFeesCollector.new({ from: factoryOwner })
    const tx = await web3.eth.getTransactionReceipt(this.JFeesCollector.transactionHash);
    expect(this.JFeesCollector.transactionHash).to.match(/0x[0-9a-fA-F]{64}/);
    console.log("JFeesCollector deploy Gas: " + tx.gasUsed);
    totcost = tx.gasUsed * GAS_PRICE;
    console.log("JFeesCollector deploy costs: " + web3.utils.fromWei(totcost.toString(), 'ether') + " ETH");
    expect(this.JFeesCollector.address).to.be.not.equal(ZERO_ADDRESS);
    expect(this.JFeesCollector.address).to.match(/0x[0-9a-fA-F]{40}/);
  });

  it('deploys JLoanDeployer', async function () {
    this.JLoanDeployer = await JLoanDeployer.new({ from: factoryOwner });
    const tx = await web3.eth.getTransactionReceipt(this.JLoanDeployer.transactionHash);
    expect(this.JLoanDeployer.transactionHash).to.match(/0x[0-9a-fA-F]{64}/);
    console.log("JLoanDeployer deploy Gas: " + tx.gasUsed);
    totcost = tx.gasUsed * GAS_PRICE;
    console.log("JLoanDeployer deploy costs: " + web3.utils.fromWei(totcost.toString(), 'ether') + " ETH");
    expect(this.JLoanDeployer.address).to.be.not.equal(ZERO_ADDRESS);
    expect(this.JLoanDeployer.address).to.match(/0x[0-9a-fA-F]{40}/);
  });

  it('deploys JPriceOracle', async function () {
    this.JPriceOracle = await JPriceOracle.new({ from: factoryOwner });
    const tx = await web3.eth.getTransactionReceipt(this.JPriceOracle.transactionHash);
    expect(this.JPriceOracle.transactionHash).to.match(/0x[0-9a-fA-F]{64}/);
    console.log("JPriceOracle deploy Gas: " + tx.gasUsed);
    totcost = tx.gasUsed * GAS_PRICE;
    console.log("JPriceOracle deploy costs: " + web3.utils.fromWei(totcost.toString(), 'ether') + " ETH");
    expect(this.JPriceOracle.address).to.be.not.equal(ZERO_ADDRESS);
    expect(this.JPriceOracle.address).to.match(/0x[0-9a-fA-F]{40}/);
  });

  it('deploys JFactory', async function () {
    this.JFactory = await JFactory.new(this.JLoanDeployer.address, this.JPriceOracle.address, { from: factoryOwner });
    const tx = await web3.eth.getTransactionReceipt(this.JFactory.transactionHash);
    console.log("JFactory deploy Gas: " + tx.gasUsed);
    totcost = tx.gasUsed * GAS_PRICE;
    console.log("JFactory deploy costs: " + web3.utils.fromWei(totcost.toString(), 'ether') + " ETH");
    expect(this.JFactory.address).to.be.not.equal(ZERO_ADDRESS);
    expect(this.JFactory.address).to.match(/0x[0-9a-fA-F]{40}/);
  });

  it('set factory and fees collector address in deployers and price oracle', async function () {
    var tx = await this.JLoanDeployer.setLoanFactory(this.JFactory.address, {from: factoryOwner});
    expect(tx.receipt.transactionHash).to.match(/0x[0-9a-fA-F]{64}/);
    console.log(tx.receipt.gasUsed);
    totcost = tx.receipt.gasUsed * GAS_PRICE;
    console.log(web3.utils.fromWei(totcost.toString(), 'ether') + " ETH");

    tx = await this.JLoanDeployer.setFeesCollector(this.JFeesCollector.address, {from: factoryOwner});
    expect(tx.receipt.transactionHash).to.match(/0x[0-9a-fA-F]{64}/);
    console.log(tx.receipt.gasUsed);
    totcost = tx.receipt.gasUsed * GAS_PRICE;
    console.log(web3.utils.fromWei(totcost.toString(), 'ether') + " ETH");

    tx = await this.JPriceOracle.setFactoryAddress(this.JFactory.address, {from: factoryOwner});
    expect(tx.receipt.transactionHash).to.match(/0x[0-9a-fA-F]{64}/);
    console.log(tx.receipt.gasUsed);
    totcost = tx.receipt.gasUsed * GAS_PRICE;
    console.log(web3.utils.fromWei(totcost.toString(), 'ether') + " ETH");

    var getParams = await this.JLoanDeployer.loanParams();
    expect(getParams.factoryAddress).to.be.equal(this.JFactory.address);
    var getFeesColl = await this.JLoanDeployer.getFeesCollector();
    expect(getFeesColl).to.be.equal(this.JFeesCollector.address);
    var getFactory = await this.JPriceOracle.factoryAddress();
    expect(getFactory).to.be.equal(this.JFactory.address);
  });

  it('set new ETH pairs in price oracle contract', async function () {
    tx = await this.JPriceOracle.setNewPair("ETHDAI", 32785, 2, ZERO_ADDRESS, 18, this.erc20Lent1.address, 18, {from: factoryOwner});
    expect(tx.receipt.transactionHash).to.match(/0x[0-9a-fA-F]{64}/);
    console.log(tx.receipt.gasUsed);
    totcost = tx.receipt.gasUsed * GAS_PRICE;
    console.log("New Pair costs: " + web3.utils.fromWei(totcost.toString(), 'ether') + " ETH");
    var result = await this.JPriceOracle.pairCounter();
    expect(result.toString()).to.be.equal("1");
    const pair = await this.JPriceOracle.pairs(0);
    result = await this.JPriceOracle.getPairName(0);
    expect(result).to.be.equal(pair.pairName);
    result = await this.JPriceOracle.getPairDecimals(0);
    expect(result).to.be.bignumber.equal(pair.pairDecimals);
    expect(ZERO_ADDRESS).to.be.equal(pair.baseAddress);
    result = await this.JPriceOracle.getPairBaseDecimals(0);
    expect(result).to.be.bignumber.equal(pair.baseDecimals);
    expect(this.erc20Lent1.address).to.be.equal(pair.quoteAddress);
    result = await this.JPriceOracle.getPairQuoteDecimals(0);
    expect(result).to.be.bignumber.equal(pair.quoteDecimals);
    result = await this.JPriceOracle.getPairValue(0);
    expect(result).to.be.bignumber.equal(pair.pairValue);
  });

  it('set new JPT pairs in price oracle contract', async function () {
    tx = await this.JPriceOracle.setNewPair("JPTUSDC", 16875, 6, this.erc20Coll1.address, 18, this.erc20Lent2.address, 18, {from: factoryOwner});
    expect(tx.receipt.transactionHash).to.match(/0x[0-9a-fA-F]{64}/);
    console.log(tx.receipt.gasUsed);
    totcost = tx.receipt.gasUsed * GAS_PRICE;
    console.log("New Pair costs: " + web3.utils.fromWei(totcost.toString(), 'ether') + " ETH");
    var result = await this.JPriceOracle.pairCounter();
    expect(result.toString()).to.be.equal("2");
    const pair = await this.JPriceOracle.pairs(1);
    result = await this.JPriceOracle.getPairName(1);
    expect(result).to.be.equal(pair.pairName);
    result = await this.JPriceOracle.getPairDecimals(1);
    expect(result).to.be.bignumber.equal(pair.pairDecimals);
    expect(this.erc20Coll1.address).to.be.equal(pair.baseAddress);
    result = await this.JPriceOracle.getPairBaseDecimals(1);
    expect(result).to.be.bignumber.equal(pair.baseDecimals);
    expect(this.erc20Lent2.address).to.be.equal(pair.quoteAddress);
    result = await this.JPriceOracle.getPairQuoteDecimals(1);
    expect(result).to.be.bignumber.equal(pair.quoteDecimals);
    result = await this.JPriceOracle.getPairValue(1);
    expect(result).to.be.bignumber.equal(pair.pairValue);
  });

  it('set new admin in factory contract', async function () {
    tx = await this.JFactory.addAdmin(factoryAdmin, {from: factoryOwner});
    expect(tx.receipt.transactionHash).to.match(/0x[0-9a-fA-F]{64}/);
    console.log(tx.receipt.gasUsed);
    totcost = tx.receipt.gasUsed * GAS_PRICE;
    console.log("New admin costs: " + web3.utils.fromWei(totcost.toString(), 'ether') + " ETH");
    expect(await this.JFactory.isAdmin(factoryAdmin)).to.be.true;
  });

  it('owner set again the same address as admin', async function () {
    await expectRevert(this.JFactory.addAdmin(factoryAdmin, {from: factoryOwner}), "Address already Administrator.");
  });

  it('owner set new price in price oracle contract', async function () {
    tx = await this.JPriceOracle.setPairValue(0, 35885, 2, {from: factoryOwner});
    expect(tx.receipt.transactionHash).to.match(/0x[0-9a-fA-F]{64}/);
    console.log(tx.receipt.gasUsed);
    totcost = tx.receipt.gasUsed * GAS_PRICE;
    console.log("New price costs: " + web3.utils.fromWei(totcost.toString(), 'ether') + " ETH");
    const pair = await this.JPriceOracle.pairs(0);
    const result = await this.JPriceOracle.getPairValue(0);
    expect(result).to.be.bignumber.equal(pair.pairValue);
  });

  it('owner set new price in factory contract', async function () {
    tx = await this.JPriceOracle.setPairValue(1, 16785, 6, {from: factoryOwner});
    expect(tx.receipt.transactionHash).to.match(/0x[0-9a-fA-F]{64}/);
    console.log(tx.receipt.gasUsed);
    totcost = tx.receipt.gasUsed * GAS_PRICE;
    console.log("New price costs: " + web3.utils.fromWei(totcost.toString(), 'ether') + " ETH");
    const pair = await this.JPriceOracle.pairs(0);
    const result = await this.JPriceOracle.getPairValue(0);
    expect(result).to.be.bignumber.equal(pair.pairValue);
  });

  it('admin deploys new loan contract', async function () {
    tx = await this.JFactory.createNewLoanContract({from: factoryAdmin})
    console.log(tx.receipt.gasUsed);
    totcost = tx.receipt.gasUsed * GAS_PRICE;
    console.log("New pair contract deploy costs: " + web3.utils.fromWei(totcost.toString(), 'ether') + " ETH");
    loanPairAddress = await this.JFactory.getDeployedLoan(0);
    this.loanContract = await JLoan.at(loanPairAddress);
    console.log("New pair contract address: " + this.loanContract.address);
    expect(this.loanContract.address).to.be.not.equal(ZERO_ADDRESS);
    expect(this.loanContract.address).to.match(/0x[0-9a-fA-F]{40}/);
    pairName = await this.JPriceOracle.getPairName(0);
    expect(pairName).to.be.equal("ETHDAI");
  });
}



function borrowersOpenLoans (factoryOwner, borrower1, borrower2, borrower3, borrower4) {
  it('borrower1 calls how much collateral needs to deploy loan contract asking STABLE_COIN_AMOUNT1 stable coins tokens', async function () {
    console.log(`borrower1 address: ${borrower1}`);
    var borrBal = await web3.eth.getBalance(borrower1);
    console.log(`New borrower1 Balance: ${web3.utils.fromWei(borrBal, "ether")} ETH`);
    collAmount = await this.JFactory.calcMinCollateralWithFeesAmount(0, web3.utils.toWei(STABLE_COIN_AMOUNT1.toString(),'ether'), {from: borrower1})
    console.log(`Min Collateral Amount: ${web3.utils.fromWei(collAmount, "ether")} ETH`);
    true;
  });

  it('borrower1 open a loan asking STABLE_COIN_AMOUNT1 tokens', async function () {
    collAmount = await this.JFactory.calcMinCollateralWithFeesAmount(0, web3.utils.toWei(STABLE_COIN_AMOUNT1.toString(),'ether'), {from: borrower1})
    console.log(`Min collateral Amount: ${web3.utils.fromWei(collAmount, "ether")} ETH`);
    tx = await this.loanContract.openNewLoan(0, web3.utils.toWei(STABLE_COIN_AMOUNT1.toString(),'ether'), LOAN_RPB_RATE, {from: borrower1, value: collAmount})
    console.log(tx.receipt.gasUsed);
    totcost = tx.receipt.gasUsed * GAS_PRICE;
    console.log("New eth loan open costs: " + web3.utils.fromWei(totcost.toString(), 'ether') + " ETH");
    expectEvent(tx, "CollateralReceived");
    contractBalance = await this.loanContract.getContractBalance(0);
    console.log(`Contract Balance: ${web3.utils.fromWei(contractBalance.toString(), "ether")} ETH`);
    loanBalance = await this.loanContract.getLoanBalance(0);
    console.log(`Loan 0 Balance: ${web3.utils.fromWei(loanBalance.toString(), "ether")} ETH`);
    var borrBal = await web3.eth.getBalance(borrower1);
    console.log(`New borrower1 Balance: ${web3.utils.fromWei(borrBal, "ether")} ETH`);
    loansNum = await this.loanContract.loanId();
    expect(loansNum.toString()).to.be.equal(new BN(1).toString());
  });

  it('borrower2 open a loan asking STABLE_COIN_AMOUNT2 tokens', async function () {
    console.log(`borrower2 address: ${borrower2}`);
    collAmount = await this.JFactory.calcMinCollateralWithFeesAmount(0, web3.utils.toWei(STABLE_COIN_AMOUNT2.toString(),'ether'), {from: borrower2})
    console.log(`Min collateral Amount: ${web3.utils.fromWei(collAmount, "ether")} ETH`);
    tx = await this.loanContract.openNewLoan(0, web3.utils.toWei(STABLE_COIN_AMOUNT2.toString(),'ether'), LOAN_RPB_RATE, {from: borrower2, value: collAmount})
    console.log(tx.receipt.gasUsed);
    totcost = tx.receipt.gasUsed * GAS_PRICE;
    console.log("New eth loan open costs: " + web3.utils.fromWei(totcost.toString(), 'ether') + " ETH");
    expectEvent(tx, "CollateralReceived");
    contractBalance = await this.loanContract.getContractBalance(1);
    console.log(`Contract Balance: ${web3.utils.fromWei(contractBalance.toString(), "ether")} ETH`);
    loanBalance = await this.loanContract.getLoanBalance(1);
    console.log(`Loan 1 Balance: ${web3.utils.fromWei(loanBalance.toString(), "ether")} ETH`);
    var borrBal = await web3.eth.getBalance(borrower2);
    console.log(`New borrower2 Balance: ${web3.utils.fromWei(borrBal, "ether")} ETH`);
    loansNum = await this.loanContract.loanId();
    expect(loansNum.toString()).to.be.equal(new BN(2).toString());
  });

  it('borrower2 cannot open a loan on pair1 since he has no token for collateral', async function () {
    console.log(`borrower2 address: ${borrower2}`);
    collAmount = await this.JFactory.calcMinCollateralWithFeesAmount(1, web3.utils.toWei(STABLE_COIN_AMOUNT2.toString(),'ether'), {from: borrower2})
    console.log(`Min collateral Amount: ${web3.utils.fromWei(collAmount, "ether")} ETH`);
    await expectRevert(this.loanContract.openNewLoan(1, web3.utils.toWei(STABLE_COIN_AMOUNT2.toString(),'ether'), LOAN_RPB_RATE, {from: borrower2}), "!allowance");
    tx = await this.erc20Coll1.approve(this.loanContract.address, collAmount, {from: borrower2});
    console.log(tx.receipt.gasUsed);
    totcost = tx.receipt.gasUsed * GAS_PRICE;
    console.log("Borrower2 allowance costs: " + web3.utils.fromWei(totcost.toString(), 'ether') + " ETH");
    await expectRevert(this.loanContract.openNewLoan(1, web3.utils.toWei(STABLE_COIN_AMOUNT2.toString(),'ether'), LOAN_RPB_RATE, {from: borrower2}), "TH TRANSFER_FROM_FAILED");
  });

  it('factory owner add token to fees collector contract', async function () {
    tx = await this.JFeesCollector.allowToken(this.erc20Coll1.address, {from: factoryOwner});
    console.log(tx.receipt.gasUsed);
    totcost = tx.receipt.gasUsed * GAS_PRICE;
    console.log("Add token address to JFeesCollector costs: " + web3.utils.fromWei(totcost.toString(), 'ether') + " ETH");
    expect(tx.receipt.status).to.be.true;
  });

  it('borrower3 open a loan asking STABLE_COIN_AMOUNT3 tokens', async function () {
    console.log(`borrower3 address: ${borrower3}`);
    borrBal = await this.erc20Coll1.balanceOf(borrower3);
    console.log(`borrower3 Balance: ${web3.utils.fromWei(borrBal, "ether")} Coll.Tokens`);
    collAmount = await this.JFactory.calcMinCollateralWithFeesAmount(1, web3.utils.toWei(STABLE_COIN_AMOUNT3.toString(),'ether'), {from: borrower3});
    console.log(`Min collateral Amount: ${web3.utils.fromWei(collAmount, "ether")} Coll.Tokens`);
    tx = await this.erc20Coll1.approve(this.loanContract.address, collAmount, {from: borrower3});
    console.log(tx.receipt.gasUsed);
    totcost = tx.receipt.gasUsed * GAS_PRICE;
    console.log("Borrower3 allowance costs: " + web3.utils.fromWei(totcost.toString(), 'ether') + " ETH");
    expect(tx.receipt.status).to.be.true;
    console.log(`Min collateral Amount: ${web3.utils.fromWei(collAmount, "ether")} Coll.Tokens`);
    tx = await this.loanContract.openNewLoan(1, web3.utils.toWei(STABLE_COIN_AMOUNT3.toString(),'ether'), LOAN_RPB_RATE, {from: borrower3})
    console.log(tx.receipt.gasUsed);
    totcost = tx.receipt.gasUsed * GAS_PRICE;
    console.log("New token loan open costs: " + web3.utils.fromWei(totcost.toString(), 'ether') + " ETH");
    expectEvent(tx, "CollateralReceived");
    contractBalance = await this.loanContract.getContractBalance(2);
    console.log(`Contract Balance: ${web3.utils.fromWei(contractBalance.toString(), "ether")} Coll.Tokens`);
    loanBalance = await this.loanContract.getLoanBalance(2);
    console.log(`Loan0 Balance: ${web3.utils.fromWei(loanBalance.toString(), "ether")} Coll.Tokens`);
    var borrBal = await this.erc20Coll1.balanceOf(borrower3);
    console.log(`New borrower3 Balance: ${web3.utils.fromWei(borrBal, "ether")} Coll.Tokens`);
    loansNum = await this.loanContract.loanId();
    expect(loansNum.toString()).to.be.equal(new BN(3).toString());
  });

  it('borrower4 open a loan asking STABLE_COIN_AMOUNT4 tokens', async function () {
    console.log(`borrower4 address: ${borrower4}`);
    borrBal = await this.erc20Coll1.balanceOf(borrower4);
    console.log(`borrower4 Balance: ${web3.utils.fromWei(borrBal, "ether")} Coll.Tokens`);
    collAmount = await this.JFactory.calcMinCollateralWithFeesAmount(1, web3.utils.toWei(STABLE_COIN_AMOUNT4.toString(),'ether'), {from: borrower4});
    console.log(`Min collateral Amount: ${web3.utils.fromWei(collAmount, "ether")} Coll.Tokens`);
    tx = await this.erc20Coll1.approve(this.loanContract.address, collAmount, {from: borrower4});
    console.log(tx.receipt.gasUsed);
    totcost = tx.receipt.gasUsed * GAS_PRICE;
    console.log("Borrower4 allowance costs: " + web3.utils.fromWei(totcost.toString(), 'ether') + " ETH");
    expect(tx.receipt.status).to.be.true;
    console.log(`Min collateral Amount: ${web3.utils.fromWei(collAmount, "ether")} Coll.Tokens`);
    tx = await this.loanContract.openNewLoan(1, web3.utils.toWei(STABLE_COIN_AMOUNT4.toString(),'ether'), LOAN_RPB_RATE, {from: borrower4})
    console.log(tx.receipt.gasUsed);
    totcost = tx.receipt.gasUsed * GAS_PRICE;
    console.log("New eth loan open costs: " + web3.utils.fromWei(totcost.toString(), 'ether') + " ETH");
    expectEvent(tx, "CollateralReceived");
    contractBalance = await this.loanContract.getContractBalance(3);
    console.log(`Contract Balance: ${web3.utils.fromWei(contractBalance.toString(), "ether")} Coll.Tokens`);
    loanBalance = await this.loanContract.getLoanBalance(3);
    console.log(`Loan 1 Balance: ${web3.utils.fromWei(loanBalance.toString(), "ether")} Coll.Tokens`);
    var borrBal = await this.erc20Coll1.balanceOf(borrower4);
    console.log(`New borrower4 Balance: ${web3.utils.fromWei(borrBal, "ether")} Coll.Tokens`);
    loansNum = await this.loanContract.loanId();
    expect(loansNum.toString()).to.be.equal(new BN(4).toString());
  });

  it('borrowers can send collateral to pending contract', async function () {
    collAmount = new BN(1000000000);
    await expectRevert(web3.eth.sendTransaction({from: borrower1, to: this.loanContract.address, value: collAmount}), "revert");
    tx = await this.loanContract.depositEthCollateral(0, {from: borrower1, value: collAmount});
    console.log(tx.receipt.gasUsed);
    totcost = tx.receipt.gasUsed * GAS_PRICE;
    console.log("Add collateral loan0 costs: " + web3.utils.fromWei(totcost.toString(), 'ether') + " ETH");
    expectEvent(tx, "CollateralReceived");
    contractBalance = await this.loanContract.getContractBalance(0);
    console.log(`Contract Balance: ${web3.utils.fromWei(contractBalance.toString(), "ether")} ETH`);
    loanBalance = await this.loanContract.getLoanBalance(0);
    console.log(`Loan1 Balance: ${web3.utils.fromWei(loanBalance.toString(), "ether")} ETH`);
    
    tx = await this.erc20Coll1.approve(this.loanContract.address, collAmount, {from: borrower4});
    console.log(tx.receipt.gasUsed);
    totcost = tx.receipt.gasUsed * GAS_PRICE;
    console.log("Borrower4 allowance costs: " + web3.utils.fromWei(totcost.toString(), 'ether') + " ETH");
    tx = await this.loanContract.depositTokenCollateral(3, this.erc20Coll1.address, collAmount, {from: borrower4});
    console.log(tx.receipt.gasUsed);
    totcost = tx.receipt.gasUsed * GAS_PRICE;
    console.log("Add collateral loan3 costs: " + web3.utils.fromWei(totcost.toString(), 'ether') + " ETH");
    expectEvent(tx, "CollateralReceived");
    contractBalance = await this.loanContract.getContractBalance(3);
    console.log(`Contract Balance: ${web3.utils.fromWei(contractBalance.toString(), "ether")} Coll. Tokens`);
    loanBalance = await this.loanContract.getLoanBalance(3);
    console.log(`Loan3 Balance: ${web3.utils.fromWei(loanBalance.toString(), "ether")} ETH`);
  });
}



function lendersActivateLoans (borrower1, borrower2, borrower3, borrower4, lender1, lender2) {
  it('lender1 sends stable coins to loan0', async function () {
    var lenderBal = await this.erc20Lent1.balanceOf(lender1);
    console.log(`Lender1 Stable coins Balance: ${web3.utils.fromWei(lenderBal, "ether")} Stable coins`)
    await this.erc20Lent1.approve(this.loanContract.address, web3.utils.toWei(STABLE_COIN_AMOUNT1.toString(),'ether'), {from: lender1});
    console.log("Lender1 Allowance: " + await this.erc20Lent1.allowance(lender1, this.loanContract.address))
    tx = await this.loanContract.lenderSendStableCoins(0, this.erc20Lent1.address, {from: lender1});
    console.log(tx.receipt.gasUsed);
    totcost = tx.receipt.gasUsed * GAS_PRICE;
    console.log("Lender1 send stable coins to loan 0 costs: " + web3.utils.fromWei(totcost.toString(), 'ether') + " ETH");
    expectEvent(tx, "LoanStatusChanged");
    loanStatus0 = await this.loanContract.getLoanStatus(0);
    console.log("Loan 0 Status:" + loanStatus0);
    loanStatus1 = await this.loanContract.getLoanStatus(1);
    console.log("Loan 1 Status:" + loanStatus1);
    contractBalance = await this.loanContract.getContractBalance(0);
    console.log(`Contract Balance: ${web3.utils.fromWei(contractBalance.toString(), "ether")} ETH`);
    JFeesCollBalance = await this.JFeesCollector.getEthBalance();
    console.log(`JFeesCollector Balance: ${web3.utils.fromWei(JFeesCollBalance.toString(), "ether")} ETH`);
    borrBal = await this.erc20Lent1.balanceOf(borrower1);
    console.log(`New borrower1 Stable coins Balance: ${web3.utils.fromWei(borrBal, "ether")} Stable coins`);
    expect(borrBal.toString()).to.be.equal(web3.utils.toWei(STABLE_COIN_AMOUNT1.toString(), "ether"));
    borrBal = await this.erc20Lent1.balanceOf(borrower2);
    console.log(`New borrower2 Stable coins Balance: ${web3.utils.fromWei(borrBal, "ether")} Stable coins`);
    expect(borrBal.toString()).to.be.equal(new BN(0).toString());
    lenderBal = await this.erc20Lent1.balanceOf(lender1);
    console.log(`New lender1 Stable coins Balance: ${web3.utils.fromWei(lenderBal, "ether")} Stable coins`);
    expect(lenderBal.toString()).to.be.equal(web3.utils.toWei('985000', "ether"));
    expect(loanStatus0.toString()).to.be.equal(new BN(1).toString());
    expect(loanStatus1.toString()).to.be.equal(new BN(0).toString());
  });

  it('lender1 is a shareholder of loan0', async function () {
    console.log("Lender Address: " + lender1);
    tx = await this.loanContract.isShareholder(0, lender1);
    expect(tx).to.be.true;
    tx = await this.loanContract.getShareholderPlace(0, lender1);
    expect(tx.toString()).to.be.equal(new BN(1).toString());
    tx = await this.loanContract.loanShareholders(0, 1);
    expect(tx.holder).to.be.equal(lender1);
    expect((tx.shares).toString()).to.be.equal(new BN(100).toString());
  });

  it('lender1 send stable coins to loan1', async function () {
    var lenderBal = await this.erc20Lent1.balanceOf(lender1);
    console.log(`Lender1 Stable coins Balance: ${web3.utils.fromWei(lenderBal, "ether")} Stable coins`)
    await this.erc20Lent1.approve(this.loanContract.address, web3.utils.toWei(STABLE_COIN_AMOUNT2.toString(),'ether'), {from: lender1});
    console.log("Lender1 Allowance: " + await this.erc20Lent1.allowance(lender1, this.loanContract.address))
    tx = await this.loanContract.lenderSendStableCoins(1, this.erc20Lent1.address, {from: lender1});
    console.log(tx.receipt.gasUsed);
    totcost = tx.receipt.gasUsed * GAS_PRICE;
    console.log("Lender1 send stable coins to loan 1 costs: " + web3.utils.fromWei(totcost.toString(), 'ether') + " ETH");
    loanStatus0 = await this.loanContract.getLoanStatus(0);
    console.log("Loan 0 Status:" + loanStatus0);
    loanStatus1 = await this.loanContract.getLoanStatus(1);
    console.log("Loan 1 Status:" + loanStatus1);
    contractBalance = await this.loanContract.getContractBalance(1);
    console.log(`Contract Balance: ${web3.utils.fromWei(contractBalance.toString(), "ether")} ETH`);
    JFeesCollBalance = await this.JFeesCollector.getEthBalance();
    console.log(`JFeesCollector Balance: ${web3.utils.fromWei(JFeesCollBalance.toString(), "ether")} ETH`);
    borrBal = await this.erc20Lent1.balanceOf(borrower1);
    console.log(`New borrower1 Stable coins Balance: ${web3.utils.fromWei(borrBal, "ether")} Stable coins`);
    expect(borrBal.toString()).to.be.equal(web3.utils.toWei(STABLE_COIN_AMOUNT1.toString(), "ether"));
    borrBal = await this.erc20Lent1.balanceOf(borrower2);
    console.log(`New borrower2 Stable coins Balance: ${web3.utils.fromWei(borrBal, "ether")} Stable coins`);
    expect(borrBal.toString()).to.be.equal(web3.utils.toWei(STABLE_COIN_AMOUNT2.toString(), "ether"));
    lenderBal = await this.erc20Lent1.balanceOf(lender1);
    console.log(`New lender1 Stable coins Balance: ${web3.utils.fromWei(lenderBal, "ether")} Stable coins`);
    expect(lenderBal.toString()).to.be.equal(web3.utils.toWei('975000', "ether"));
    expect(loanStatus0.toString()).to.be.equal(new BN(1).toString());
    expect(loanStatus1.toString()).to.be.equal(new BN(1).toString());
  });

  it('lender1 is a shareholder of loan1', async function () {
    console.log("Lender Address: " + lender1);
    tx = await this.loanContract.isShareholder(1, lender1);
    expect(tx).to.be.true;
    tx = await this.loanContract.getShareholderPlace(1, lender1);
    expect(tx.toString()).to.be.equal(new BN(1).toString());
    tx = await this.loanContract.loanShareholders(1, 1);
    expect(tx.holder).to.be.equal(lender1);
    expect((tx.shares).toString()).to.be.equal(new BN(100).toString());
  });

  it('lender2 sends stable coins to loan2', async function () {
    var lenderBal = await this.erc20Lent2.balanceOf(lender2);
    console.log(`Lender2 Stable coins Balance: ${web3.utils.fromWei(lenderBal, "ether")} Stable coins`)
    await this.erc20Lent2.approve(this.loanContract.address, web3.utils.toWei(STABLE_COIN_AMOUNT3.toString(),'ether'), {from: lender2});
    console.log("Lender2 Allowance: " + await this.erc20Lent2.allowance(lender2, this.loanContract.address))
    tx = await this.loanContract.lenderSendStableCoins(2, this.erc20Lent2.address, {from: lender2});
    console.log(tx.receipt.gasUsed);
    totcost = tx.receipt.gasUsed * GAS_PRICE;
    console.log("Lender2 send stable coins to loan 2 costs: " + web3.utils.fromWei(totcost.toString(), 'ether') + " ETH");
    expectEvent(tx, "LoanStatusChanged");
    loanStatus2 = await this.loanContract.getLoanStatus(2);
    console.log("Loan 2 Status:" + loanStatus2);
    loanStatus3 = await this.loanContract.getLoanStatus(3);
    console.log("Loan 3 Status:" + loanStatus3);
    contractBalance = await this.loanContract.getContractBalance(2);
    console.log(`Contract Balance: ${web3.utils.fromWei(contractBalance.toString(), "ether")} ETH`);
    JFeesCollBalance = await this.JFeesCollector.getEthBalance();
    console.log(`JFeesCollector Balance: ${web3.utils.fromWei(JFeesCollBalance.toString(), "ether")} ETH`);
    borrBal = await this.erc20Lent2.balanceOf(borrower3);
    console.log(`New borrower3 Stable coins Balance: ${web3.utils.fromWei(borrBal, "ether")} Stable coins`);
    expect(borrBal.toString()).to.be.equal(web3.utils.toWei(STABLE_COIN_AMOUNT3.toString(), "ether"));
    borrBal = await this.erc20Lent2.balanceOf(borrower4);
    console.log(`New borrower4 Stable coins Balance: ${web3.utils.fromWei(borrBal, "ether")} Stable coins`);
    expect(borrBal.toString()).to.be.equal(new BN(0).toString());
    lenderBal = await this.erc20Lent2.balanceOf(lender2);
    console.log(`New lender2 Stable coins Balance: ${web3.utils.fromWei(lenderBal, "ether")} Stable coins`);
    expect(lenderBal.toString()).to.be.equal(web3.utils.toWei('998500', "ether"));
    expect(loanStatus2.toString()).to.be.equal(new BN(1).toString());
    expect(loanStatus3.toString()).to.be.equal(new BN(0).toString());
  });

  it('lender2 is a shareholder of loan2', async function () {
    console.log("Lender Address: " + lender2);
    tx = await this.loanContract.isShareholder(2, lender2);
    expect(tx).to.be.true;
    tx = await this.loanContract.getShareholderPlace(2, lender2);
    expect(tx.toString()).to.be.equal(new BN(1).toString());
    tx = await this.loanContract.loanShareholders(2, 1);
    expect(tx.holder).to.be.equal(lender2);
    expect((tx.shares).toString()).to.be.equal(new BN(100).toString());
  });

  it('lender2 send stable coins to loan3', async function () {
    var lenderBal = await this.erc20Lent2.balanceOf(lender2);
    console.log(`Lender2 Stable coins Balance: ${web3.utils.fromWei(lenderBal, "ether")} Stable coins`)
    await this.erc20Lent2.approve(this.loanContract.address, web3.utils.toWei(STABLE_COIN_AMOUNT4.toString(),'ether'), {from: lender2});
    console.log("Lender Allowance: " + await this.erc20Lent2.allowance(lender2, this.loanContract.address))
    tx = await this.loanContract.lenderSendStableCoins(3, this.erc20Lent2.address, {from: lender2});
    console.log(tx.receipt.gasUsed);
    totcost = tx.receipt.gasUsed * GAS_PRICE;
    console.log("Lender2 send stable coins to loan 3 costs: " + web3.utils.fromWei(totcost.toString(), 'ether') + " ETH");
    loanStatus2 = await this.loanContract.getLoanStatus(2);
    console.log("Loan 2 Status:" + loanStatus2);
    loanStatus3 = await this.loanContract.getLoanStatus(3);
    console.log("Loan 3 Status:" + loanStatus3);
    contractBalance = await this.loanContract.getContractBalance(3);
    console.log(`Contract Balance: ${web3.utils.fromWei(contractBalance.toString(), "ether")} ETH`);
    JFeesCollBalance = await this.JFeesCollector.getEthBalance();
    console.log(`JFeesCollector Balance: ${web3.utils.fromWei(JFeesCollBalance.toString(), "ether")} ETH`);
    borrBal = await this.erc20Lent2.balanceOf(borrower3);
    console.log(`New borrower3 Stable coins Balance: ${web3.utils.fromWei(borrBal, "ether")} Stable coins`);
    expect(borrBal.toString()).to.be.equal(web3.utils.toWei(STABLE_COIN_AMOUNT3.toString(), "ether"));
    borrBal = await this.erc20Lent2.balanceOf(borrower4);
    console.log(`New borrower4 Stable coins Balance: ${web3.utils.fromWei(borrBal, "ether")} Stable coins`);
    expect(borrBal.toString()).to.be.equal(web3.utils.toWei(STABLE_COIN_AMOUNT4.toString(), "ether"));
    lenderBal = await this.erc20Lent2.balanceOf(lender2);
    console.log(`New lender2 Stable coins Balance: ${web3.utils.fromWei(lenderBal, "ether")} Stable coins`);
    expect(lenderBal.toString()).to.be.equal(web3.utils.toWei('997500', "ether"));
    expect(loanStatus2.toString()).to.be.equal(new BN(1).toString());
    expect(loanStatus3.toString()).to.be.equal(new BN(1).toString());
  });

  it('lender2 is a shareholder of loan3', async function () {
    console.log("Lender Address: " + lender2);
    tx = await this.loanContract.isShareholder(3, lender2);
    expect(tx).to.be.true;
    tx = await this.loanContract.getShareholderPlace(3, lender2);
    expect(tx.toString()).to.be.equal(new BN(1).toString());
    tx = await this.loanContract.loanShareholders(3, 1);
    expect(tx.holder).to.be.equal(lender2);
    expect((tx.shares).toString()).to.be.equal(new BN(100).toString());
  });
}


function borrowersAddCollateral(borrower1, borrower2, borrower3, borrower4) {
  it('borrower1 can send collateral to active loans', async function () {
    console.log("Loan 0 collateral ratio: " + await this.loanContract.getActualCollateralRatio(0));
    console.log("Loan 1 collateral ratio: " + await this.loanContract.getActualCollateralRatio(1));
    ten_eth = new BN(web3.utils.toWei('10', "ether"));
    tx = await this.loanContract.depositEthCollateral(0, {from: borrower1, value: ten_eth});
    console.log(tx.receipt.gasUsed);
    totcost = tx.receipt.gasUsed * GAS_PRICE;
    console.log("borrower1 adding collateral costs: " + web3.utils.fromWei(totcost.toString(), 'ether') + " ETH");
    contractBalance = await this.loanContract.getContractBalance(0);
    console.log(`Contract Balance: ${web3.utils.fromWei(contractBalance.toString(), "ether")} ETH`);
    loanBalance = await this.loanContract.getLoanBalance(0);
    console.log(`Loan0 Balance: ${web3.utils.fromWei(loanBalance.toString(), "ether")} ETH`);
    loanBalance = await this.loanContract.getLoanBalance(1);
    console.log(`Loan1 Balance: ${web3.utils.fromWei(loanBalance.toString(), "ether")} ETH`);
    console.log("New collateral ratio loan0: " + await this.loanContract.getActualCollateralRatio(0));
    console.log("New collateral ratio loan1: " + await this.loanContract.getActualCollateralRatio(1));
  });

  it('borrower2 can send collateral to active loans', async function () {
    console.log("Loan 0 collateral ratio: " + await this.loanContract.getActualCollateralRatio(0));
    console.log("Loan 1 collateral ratio: " + await this.loanContract.getActualCollateralRatio(1));
    ten_eth = new BN(web3.utils.toWei('10', "ether"));
    tx = await this.loanContract.depositEthCollateral(1, {from: borrower2, value: ten_eth});
    console.log(tx.receipt.gasUsed);
    totcost = tx.receipt.gasUsed * GAS_PRICE;
    console.log("borrower2 adding collateral costs: " + web3.utils.fromWei(totcost.toString(), 'ether') + " ETH");
    contractBalance = await this.loanContract.getContractBalance(1);
    console.log(`Contract Balance: ${web3.utils.fromWei(contractBalance.toString(), "ether")} ETH`);
    loanBalance = await this.loanContract.getLoanBalance(0);
    console.log(`Loan0 Balance: ${web3.utils.fromWei(loanBalance.toString(), "ether")} ETH`);
    loanBalance = await this.loanContract.getLoanBalance(1);
    console.log(`Loan1 Balance: ${web3.utils.fromWei(loanBalance.toString(), "ether")} ETH`);
    console.log("New collateral ratio loan0: " + await this.loanContract.getActualCollateralRatio(0));
    console.log("New collateral ratio loan1: " + await this.loanContract.getActualCollateralRatio(1));
  });

  it('borrower3 can send token collateral to active contract', async function () {
    console.log("Loan2 collateral ratio: " + await this.loanContract.getActualCollateralRatio(2));
    console.log("Loan3 collateral ratio: " + await this.loanContract.getActualCollateralRatio(3));
    tenth_tok = web3.utils.toWei('10000', "ether");
    tx = await this.erc20Coll1.approve(this.loanContract.address, tenth_tok, {from: borrower3});
    console.log(tx.receipt.gasUsed);
    totcost = tx.receipt.gasUsed * GAS_PRICE;
    console.log("borrower3 approve costs: " + web3.utils.fromWei(totcost.toString(), 'ether') + " ETH");
    tx = await this.loanContract.depositTokenCollateral(2, this.erc20Coll1.address, tenth_tok, {from: borrower3});
    console.log(tx.receipt.gasUsed);
    totcost = tx.receipt.gasUsed * GAS_PRICE;
    console.log("borrower3 adding collateral costs: " + web3.utils.fromWei(totcost.toString(), 'ether') + " ETH");
    expectEvent(tx, "CollateralReceived");
    contractBalance = await this.loanContract.getContractBalance(2);
    console.log(`Contract Balance: ${web3.utils.fromWei(contractBalance.toString(), "ether")} Collat. Coins`);
    loanBal = await this.loanContract.getLoanBalance(2);
    console.log(`loan2 Balance: ${web3.utils.fromWei(loanBal.toString(), "ether")} Collat. Coins`);
    console.log("New collateral ratio loan2: " + await this.loanContract.getActualCollateralRatio(2));
    console.log("New collateral ratio loan3: " + await this.loanContract.getActualCollateralRatio(3));
  });

  it('borrower4 can send token collateral to active contract', async function () {
    console.log("Loan2 collateral ratio: " + await this.loanContract.getActualCollateralRatio(2));
    console.log("Loan3 collateral ratio: " + await this.loanContract.getActualCollateralRatio(3));
    tenth_tok = web3.utils.toWei('10000', "ether");
    tx = await this.erc20Coll1.approve(this.loanContract.address, tenth_tok, {from: borrower4});
    console.log(tx.receipt.gasUsed);
    totcost = tx.receipt.gasUsed * GAS_PRICE;
    console.log("borrower4 approve costs: " + web3.utils.fromWei(totcost.toString(), 'ether') + " ETH");
    tx = await this.loanContract.depositTokenCollateral(3, this.erc20Coll1.address, tenth_tok, {from: borrower4});
    console.log(tx.receipt.gasUsed);
    totcost = tx.receipt.gasUsed * GAS_PRICE;
    console.log("borrower4 adding collateral costs: " + web3.utils.fromWei(totcost.toString(), 'ether') + " ETH");
    expectEvent(tx, "CollateralReceived");
    contractBalance = await this.loanContract.getContractBalance(3);
    console.log(`Contract Balance: ${web3.utils.fromWei(contractBalance.toString(), "ether")} Collat. Coins`);
    loanBal = await this.loanContract.getLoanBalance(3);
    console.log(`loan3 Balance: ${web3.utils.fromWei(loanBal.toString(), "ether")} Collat. Coins`);
    console.log("New collateral ratio loan2: " + await this.loanContract.getActualCollateralRatio(2));
    console.log("New collateral ratio loan3: " + await this.loanContract.getActualCollateralRatio(3));
  });
}



function lendersGetAccruedInterest(lender1, lender2) {
  it('lender1 can have accrued interests from loan0 and loan1 as per RPB', async function () {
    lenderBal = await web3.eth.getBalance(lender1);
    console.log(`Lender1 ETH Balance: ${web3.utils.fromWei(lenderBal, "ether")} ETH`)
    console.log("Accrued interests loan0: " + await this.loanContract.getAccruedInterests(0));
    console.log("Accrued interests loan1: " + await this.loanContract.getAccruedInterests(1));
    contractBalance = await this.loanContract.getContractBalance(0);
    console.log(`Contract Balance: ${web3.utils.fromWei(contractBalance.toString(), "ether")} ETH`);
    loanBalance = await this.loanContract.getLoanBalance(0);
    console.log(`Loan0 Balance: ${web3.utils.fromWei(loanBalance.toString(), "ether")} ETH`);
    loanBalance = await this.loanContract.getLoanBalance(1);
    console.log(`Loan1 Balance: ${web3.utils.fromWei(loanBalance.toString(), "ether")} ETH`);
    tx = await this.loanContract.withdrawInterests(0, {from: lender1});
    console.log(tx.receipt.gasUsed);
    totcost = tx.receipt.gasUsed * GAS_PRICE;
    console.log("Lender withdraw interests from loan0 costs: " + web3.utils.fromWei(totcost.toString(), 'ether') + " ETH");
    tx = await this.loanContract.withdrawInterests(1, {from: lender1});
    console.log(tx.receipt.gasUsed);
    totcost = tx.receipt.gasUsed * GAS_PRICE;
    console.log("Lender withdraw interests from loan1 costs: " + web3.utils.fromWei(totcost.toString(), 'ether') + " ETH");
    contractBalance = await this.loanContract.getContractBalance(0);
    console.log(`Contract Balance: ${web3.utils.fromWei(contractBalance.toString(), "ether")} ETH`);
    loanBalance = await this.loanContract.getLoanBalance(0);
    console.log(`Loan 0 Balance: ${web3.utils.fromWei(loanBalance.toString(), "ether")} ETH`);
    loanBalance = await this.loanContract.getLoanBalance(1);
    console.log(`Loan 1 Balance: ${web3.utils.fromWei(loanBalance.toString(), "ether")} ETH`);
    console.log("New collateral ratio loan0: " + await this.loanContract.getActualCollateralRatio(0));
    console.log("New collateral ratio loan1: " + await this.loanContract.getActualCollateralRatio(1));
    lenderBal = await web3.eth.getBalance(lender1);
    console.log(`New lender1 ETH Balance: ${web3.utils.fromWei(lenderBal, "ether")} ETH`)
  });

  it('lender2 can have accrued interests from loan2 and loan3 as per RPB', async function () {
    lenderBal = await this.erc20Coll1.balanceOf(lender2);
    console.log(`Lender2 Coll Tokens Balance: ${web3.utils.fromWei(lenderBal, "ether")} Collat. Coins`);
    console.log("Accrued interests loan2: " + await this.loanContract.getAccruedInterests(2));
    console.log("Accrued interests loan3: " + await this.loanContract.getAccruedInterests(3));
    contractBalance = await this.loanContract.getContractBalance(3);
    console.log(`Contract Balance: ${web3.utils.fromWei(contractBalance.toString(), "ether")} Collat. Coins`);
    loanBalance = await this.loanContract.getLoanBalance(2);
    console.log(`Loan2 Balance: ${web3.utils.fromWei(loanBalance.toString(), "ether")} Collat. Coins`);
    loanBalance = await this.loanContract.getLoanBalance(3);
    console.log(`Loan3 Balance: ${web3.utils.fromWei(loanBalance.toString(), "ether")} Collat. Coins`);
    tx = await this.loanContract.withdrawInterests(2, {from: lender2});
    console.log(tx.receipt.gasUsed);
    totcost = tx.receipt.gasUsed * GAS_PRICE;
    console.log("Lender2 withdraw interests costs: " + web3.utils.fromWei(totcost.toString(), 'ether') + " ETH");
    tx = await this.loanContract.withdrawInterests(3, {from: lender2});
    console.log(tx.receipt.gasUsed);
    totcost = tx.receipt.gasUsed * GAS_PRICE;
    console.log("Lender2 withdraw interests costs: " + web3.utils.fromWei(totcost.toString(), 'ether') + " ETH");
    expectEvent(tx, "InterestsWithdrawed");
    contractBalance = await this.loanContract.getContractBalance(3);
    console.log(`Contract Balance: ${web3.utils.fromWei(contractBalance.toString(), "ether")} Collat. Coins`);
    loanBalance = await this.loanContract.getLoanBalance(2);
    console.log(`Loan2 Balance: ${web3.utils.fromWei(loanBalance.toString(), "ether")} Collat. Coins`);
    loanBalance = await this.loanContract.getLoanBalance(3);
    console.log(`Loan3 Balance: ${web3.utils.fromWei(loanBalance.toString(), "ether")} Collat. Coins`);
    console.log("New collateral ratio loan2: " + await this.loanContract.getActualCollateralRatio(0));
    console.log("New collateral ratio loan3: " + await this.loanContract.getActualCollateralRatio(1));
    lenderBal = await this.erc20Coll1.balanceOf(lender2);
    console.log(`Lender2 Coll Tokens Balance: ${web3.utils.fromWei(lenderBal, "ether")} Collat. Coins`);
  });

}

function priceDownfor150(factoryAdmin) {
  it('ETH pair price goes down, collateral under 150%, foreclosing', async function () {
    console.log("Pair price: " + await this.JPriceOracle.getPairValue(0));
    console.log("Loan0 collateral ratio: " + await this.loanContract.getActualCollateralRatio(0));
    console.log("Loan1 collateral ratio: " + await this.loanContract.getActualCollateralRatio(1));
    loanStatus = await this.loanContract.getLoanStatus(0);
    console.log("Loan0 Status:" + loanStatus);
    loanStatus = await this.loanContract.getLoanStatus(1);
    console.log("Loan1 Status:" + loanStatus);
    tx = await this.JPriceOracle.setPairValue(0, 22500, 2, {from: factoryAdmin});
    console.log(tx.receipt.gasUsed);
    totcost = tx.receipt.gasUsed * GAS_PRICE;
    console.log("Pair price change costs: " + web3.utils.fromWei(totcost.toString(), 'ether') + " ETH");
    pair = await this.JPriceOracle.pairs(0);
    newPrice = await this.JPriceOracle.getPairValue(0);
    expect(newPrice.toString()).to.be.bignumber.equal((pair.pairValue).toString());
    console.log("Pair Price: " + newPrice);
    console.log("Loan0 collateral ratio: " + await this.loanContract.getActualCollateralRatio(0));
    console.log("Loan1 collateral ratio: " + await this.loanContract.getActualCollateralRatio(1));
    loanStatus0 = await this.loanContract.getLoanStatus(0);
    console.log("Loan0 Status:" + loanStatus0);
    loanStatus1 = await this.loanContract.getLoanStatus(1);
    console.log("Loan1 Status:" + loanStatus1);
    expect(loanStatus0.toString()).to.be.equal(new BN(1).toString());
    expect(loanStatus1.toString()).to.be.equal(new BN(1).toString());
  });

  it('Coll Token pair price goes down, collateral under 150%, foreclosing', async function () {
    console.log("Pair price: " + await this.JPriceOracle.getPairValue(1));
    console.log("Loan2 collateral ratio: " + await this.loanContract.getActualCollateralRatio(2));
    console.log("Loan3 collateral ratio: " + await this.loanContract.getActualCollateralRatio(3));
    loanStatus = await this.loanContract.getLoanStatus(2);
    console.log("Loan2 Status:" + loanStatus);
    loanStatus = await this.loanContract.getLoanStatus(3);
    console.log("Loan3 Status:" + loanStatus);
    tx = await this.JPriceOracle.setPairValue(1, 10785, 6, {from: factoryAdmin});
    console.log(tx.receipt.gasUsed);
    totcost = tx.receipt.gasUsed * GAS_PRICE;
    console.log("Pair price change costs: " + web3.utils.fromWei(totcost.toString(), 'ether') + " ETH");
    pair = await this.JPriceOracle.pairs(1);
    newPrice = await this.JPriceOracle.getPairValue(1);
    expect(newPrice.toString()).to.be.bignumber.equal((pair.pairValue).toString());
    console.log("Pair Price: " + newPrice);
    console.log("Loan2 collateral ratio: " + await this.loanContract.getActualCollateralRatio(2));
    console.log("Loan3 collateral ratio: " + await this.loanContract.getActualCollateralRatio(3));
    loanStatus2 = await this.loanContract.getLoanStatus(2);
    console.log("Loan2 Status:" + loanStatus2);
    loanStatus3 = await this.loanContract.getLoanStatus(3);
    console.log("Loan3 Status:" + loanStatus3);
    expect(loanStatus2.toString()).to.be.equal(new BN(1).toString());
    expect(loanStatus3.toString()).to.be.equal(new BN(1).toString());
  });
}


function firstForeclosing(foreclosureAgent) {
  it('initiate foreclosure procedures for ETH collateral under 150% but above 120%, status from 1 to 4 on loan1, no change on loan0', async function () {
    agentBal = await web3.eth.getBalance(foreclosureAgent);
    console.log(`foreclosureAgent Balance: ${web3.utils.fromWei(agentBal, "ether")} ETH`);
    tx = await this.loanContract.initiateLoanForeclose(1, {from: foreclosureAgent});
    console.log(tx.receipt.gasUsed);
    totcost = tx.receipt.gasUsed * GAS_PRICE;
    console.log("Initiate Loan1 Foreclose costs: " + web3.utils.fromWei(totcost.toString(), 'ether') + " ETH");
    agentBal = await web3.eth.getBalance(foreclosureAgent);
    console.log(`foreclosureAgent Balance: ${web3.utils.fromWei(agentBal, "ether")} ETH`);
    JFeesCollBalance = await this.JFeesCollector.getEthBalance();
    console.log(`JFeesCollector Balance: ${web3.utils.fromWei(JFeesCollBalance.toString(), "ether")} ETH`);
    console.log("Loan0 collateral ratio: " + await this.loanContract.getActualCollateralRatio(0));
    console.log("Loan1 collateral ratio: " + await this.loanContract.getActualCollateralRatio(1));
    loanStatus0 = await this.loanContract.getLoanStatus(0);
    console.log("Loan0 Status:" + loanStatus0);
    loanStatus1 = await this.loanContract.getLoanStatus(1);
    console.log("Loan1 Status:" + loanStatus1);
    expect(loanStatus0).to.be.bignumber.equal(new BN(1).toString());
    expect(loanStatus1).to.be.bignumber.equal(new BN(4).toString());
  });

  it('initiate foreclosure procedures for Token collateral under 150% but above 120%, status from 1 to 4 on loan3, no change on loan2', async function () {
    agentBal = await web3.eth.getBalance(foreclosureAgent);
    console.log(`foreclosureAgent Balance: ${web3.utils.fromWei(agentBal, "ether")} ETH`);
    agentBal = await this.erc20Coll1.balanceOf(foreclosureAgent);
    console.log(`foreclosureAgent Balance: ${web3.utils.fromWei(agentBal, "ether")} Collat. Coins`);
    tx = await this.loanContract.initiateLoanForeclose(3, {from: foreclosureAgent});
    console.log(tx.receipt.gasUsed);
    totcost = tx.receipt.gasUsed * GAS_PRICE;
    console.log("Initiate Loan3 Foreclose costs: " + web3.utils.fromWei(totcost.toString(), 'ether') + " ETH");
    agentBal = await this.erc20Coll1.balanceOf(foreclosureAgent);
    console.log(`foreclosureAgent Balance: ${web3.utils.fromWei(agentBal, "ether")} Collat. Coins`);
    JFeesCollBalance = await this.JFeesCollector.getTokenBalance(this.erc20Coll1.address);
    console.log(`JFeesCollector Balance: ${web3.utils.fromWei(JFeesCollBalance.toString(), "ether")} Collat. Coins`);
    console.log("Loan2 collateral ratio: " + await this.loanContract.getActualCollateralRatio(2));
    console.log("Loan3 collateral ratio: " + await this.loanContract.getActualCollateralRatio(3));
    loanStatus2 = await this.loanContract.getLoanStatus(2);
    console.log("Loan2 Status:" + loanStatus2);
    loanStatus3 = await this.loanContract.getLoanStatus(3);
    console.log("Loan3 Status:" + loanStatus3);
    expect(loanStatus2).to.be.bignumber.equal(new BN(1).toString());
    expect(loanStatus3).to.be.bignumber.equal(new BN(4).toString());
  });

  it('initiate foreclosure procedures even on loan0', async function () {
    agentBal = await web3.eth.getBalance(foreclosureAgent);
    console.log(`foreclosureAgent Balance: ${web3.utils.fromWei(agentBal, "ether")} ETH`);
    tx = await this.loanContract.initiateLoanForeclose(0, {from: foreclosureAgent});
    console.log(tx.receipt.gasUsed);
    totcost = tx.receipt.gasUsed * GAS_PRICE;
    console.log("Initiate Loan1 Foreclose costs: " + web3.utils.fromWei(totcost.toString(), 'ether') + " ETH");
    agentBal = await web3.eth.getBalance(foreclosureAgent);
    console.log(`foreclosureAgent Balance: ${web3.utils.fromWei(agentBal, "ether")} ETH`);
    JFeesCollBalance = await this.JFeesCollector.getEthBalance();
    console.log(`JFeesCollector Balance: ${web3.utils.fromWei(JFeesCollBalance.toString(), "ether")} ETH`);
    console.log("Loan0 collateral ratio: " + await this.loanContract.getActualCollateralRatio(0));
    console.log("Loan1 collateral ratio: " + await this.loanContract.getActualCollateralRatio(1));
    loanStatus0 = await this.loanContract.getLoanStatus(0);
    console.log("Loan Status:" + loanStatus0);
    loanStatus1 = await this.loanContract.getLoanStatus(1);
    console.log("Loan Status:" + loanStatus1);
    expect(loanStatus0).to.be.bignumber.equal(new BN(4).toString());
    expect(loanStatus1).to.be.bignumber.equal(new BN(4).toString());
  });

  it('initiate foreclosure procedures even on loan2', async function () {
    agentBal = await web3.eth.getBalance(foreclosureAgent);
    console.log(`foreclosureAgent Balance: ${web3.utils.fromWei(agentBal, "ether")} ETH`);
    agentBal = await this.erc20Coll1.balanceOf(foreclosureAgent);
    console.log(`foreclosureAgent Balance: ${web3.utils.fromWei(agentBal, "ether")} Collat. Coins`);
    tx = await this.loanContract.initiateLoanForeclose(2, {from: foreclosureAgent});
    console.log(tx.receipt.gasUsed);
    totcost = tx.receipt.gasUsed * GAS_PRICE;
    console.log("Initiate Loan3 Foreclose costs: " + web3.utils.fromWei(totcost.toString(), 'ether') + " ETH");
    agentBal = await this.erc20Coll1.balanceOf(foreclosureAgent);
    console.log(`foreclosureAgent Balance: ${web3.utils.fromWei(agentBal, "ether")} Collat. Coins`);
    JFeesCollBalance = await this.JFeesCollector.getTokenBalance(this.erc20Coll1.address);
    console.log(`JFeesCollector Balance: ${web3.utils.fromWei(JFeesCollBalance.toString(), "ether")} Collat. Coins`);
    console.log("Loan2 collateral ratio: " + await this.loanContract.getActualCollateralRatio(2));
    console.log("Loan3 collateral ratio: " + await this.loanContract.getActualCollateralRatio(3));
    loanStatus2 = await this.loanContract.getLoanStatus(2);
    console.log("Loan2 Status:" + loanStatus2);
    loanStatus3 = await this.loanContract.getLoanStatus(3);
    console.log("Loan3 Status:" + loanStatus3);
    expect(loanStatus2).to.be.bignumber.equal(new BN(4).toString());
    expect(loanStatus3).to.be.bignumber.equal(new BN(4).toString());
  });

  it('initiate again foreclosure procedures for collateral under 150% for loan0 and loan1 (fail)', async function () {
    await expectRevert(this.loanContract.initiateLoanForeclose(0, {from: foreclosureAgent}), "!Status23");
    await expectRevert(this.loanContract.initiateLoanForeclose(1, {from: foreclosureAgent}), "!Status23");
  });

  it('initiate again foreclosure procedures for collateral under 150% for loan2 and loan3 (fail)', async function () {
    await expectRevert(this.loanContract.initiateLoanForeclose(2, {from: foreclosureAgent}), "!Status23");
    await expectRevert(this.loanContract.initiateLoanForeclose(3, {from: foreclosureAgent}), "!Status23");
  });
}


module.exports = {
  factoryInitialization,
  borrowersOpenLoans,
  lendersActivateLoans,
  borrowersAddCollateral,
  lendersGetAccruedInterest,
  priceDownfor150,
  firstForeclosing
};