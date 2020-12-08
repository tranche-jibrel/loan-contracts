const { deployProxy, upgradeProxy } = require('@openzeppelin/truffle-upgrades');
const { accounts, contract, web3 } = require('@openzeppelin/test-environment');
const { BN, constants, expectEvent, expectRevert } = require('@openzeppelin/test-helpers');
const { expect } = require('chai');
const { ZERO_ADDRESS } = constants;

const myERC20 = contract.fromArtifact("myERC20");
const JFeesCollector = contract.fromArtifact("JFeesCollector");
const JPriceOracle = contract.fromArtifact('JPriceOracle');
const JLoan = contract.fromArtifact('JLoan');
const JLoanHelper = contract.fromArtifact("JLoanHelper"); //not upgradeable

const MYERC20_TOKEN_SUPPLY = 5000000; 
const GAS_PRICE = 27000000000;
const LOAN_RPB_RATE = 1000000000;
const STABLE_COIN_AMOUNT1 = 15000;
const STABLE_COIN_AMOUNT2 = 10000;
const STABLE_COIN_AMOUNT3 = 1500;
const STABLE_COIN_AMOUNT4 = 1000;


function factoryInitialization (tokenOwner, factoryOwner, borrower3, borrower4, lender1, lender2, factoryAdmin ) {
  
  it('deploys collateral erc20Coll', async function () {
    //gasPrice = await web3.eth.getGasPrice();
    //console.log("Gas price: " + gasPrice);
    console.log("TokenOwner address: " + tokenOwner);
    this.erc20Coll1 = await myERC20.new({ from: tokenOwner });
    expect(this.erc20Coll1.address).to.be.not.equal(ZERO_ADDRESS);
    expect(this.erc20Coll1.address).to.match(/0x[0-9a-fA-F]{40}/);
    console.log(`Coll Token Address: ${this.erc20Coll1.address}`);
    result = await this.erc20Coll1.totalSupply();
    expect(result.toString()).to.be.equal(new BN(0).toString());
    console.log("erc20Coll1 total supply: " + result);
    tx = await web3.eth.getTransactionReceipt(this.erc20Coll1.transactionHash);
    console.log("ERC20 Coll1 deploy Gas: " + tx.gasUsed);
    totcost = tx.gasUsed * GAS_PRICE;
    console.log("ERC20 Coll1 deploy costs: " + web3.utils.fromWei(totcost.toString(), 'ether') + " ETH");
    result = await this.erc20Coll1.owner();
    expect(result).to.be.equal(ZERO_ADDRESS);
    tx = await this.erc20Coll1.initialize(MYERC20_TOKEN_SUPPLY, { from: tokenOwner });
    console.log("ERC20 Coll1 Initialize Gas: " + tx.receipt.gasUsed);
    totcost = tx.receipt.gasUsed * GAS_PRICE;
    console.log("ERC20 Coll1 Initialize costs: " + web3.utils.fromWei(totcost.toString(), 'ether') + " ETH");
    result = await this.erc20Coll1.owner();
    expect(result).to.be.equal(tokenOwner);
    console.log("erc20Coll1 owner address: " + result);
    borrBal = await this.erc20Coll1.balanceOf(tokenOwner);
    console.log(`tokenOwner Collateral Balance: ${web3.utils.fromWei(borrBal, "ether")} Coll Tokens`);
  });

  it('deploys collateral erc20Lent1', async function () {
    //gasPrice = await web3.eth.getGasPrice();
    //console.log("Gas price: " + gasPrice);
    this.erc20Lent1 = await myERC20.new(MYERC20_TOKEN_SUPPLY, { from: tokenOwner });
    expect(this.erc20Lent1.address).to.be.not.equal(ZERO_ADDRESS);
    expect(this.erc20Lent1.address).to.match(/0x[0-9a-fA-F]{40}/);
    result = await this.erc20Lent1.totalSupply();
    expect(result.toString()).to.be.equal(new BN(0).toString());
    console.log("erc20Lent1 total supply: " + result);
    console.log(`Stable coin1 Token1 Address: ${this.erc20Lent1.address}`);
    tx = await web3.eth.getTransactionReceipt(this.erc20Lent1.transactionHash);
    console.log("ERC20 Lent1 deploy Gas: " + tx.gasUsed);
    totcost = tx.gasUsed * GAS_PRICE;
    console.log("ERC20 Lent1 deploy costs: " + web3.utils.fromWei(totcost.toString(), 'ether') + " ETH");
    tx = await this.erc20Lent1.initialize(MYERC20_TOKEN_SUPPLY, { from: tokenOwner });
    console.log("ERC20 Lent1 Initialize Gas: " + tx.receipt.gasUsed);
    totcost = tx.receipt.gasUsed * GAS_PRICE;
    console.log("ERC20 Lent1 Initialize costs: " + web3.utils.fromWei(totcost.toString(), 'ether') + " ETH");
    result = await this.erc20Lent1.owner();
    console.log("erc20Lent1 owner address: " + result);
    borrBal = await this.erc20Lent1.balanceOf(tokenOwner);
    console.log(`tokenOwner Lent1 Balance: ${web3.utils.fromWei(borrBal, "ether")} Stable Coin1 Tokens`);
  });

  it('deploys lent erc20Lent2', async function () {
    this.erc20Lent2 = await myERC20.new(MYERC20_TOKEN_SUPPLY, { from: tokenOwner });
    expect(this.erc20Lent2.address).to.be.not.equal(ZERO_ADDRESS);
    expect(this.erc20Lent2.address).to.match(/0x[0-9a-fA-F]{40}/);
    console.log(`Stable coin2 Address: ${this.erc20Lent2.address}`);
    result = await this.erc20Lent2.totalSupply();
    expect(result.toString()).to.be.equal(new BN(0).toString());
    console.log("erc20Lent2 total supply: " + result);
    tx = await web3.eth.getTransactionReceipt(this.erc20Lent2.transactionHash);
    console.log("ERC20 Lent2 deploy Gas: " + tx.gasUsed);
    totcost = tx.gasUsed * GAS_PRICE;
    console.log("ERC20 Lent2 deploy costs: " + web3.utils.fromWei(totcost.toString(), 'ether') + " ETH");
    tx = await this.erc20Lent2.initialize(MYERC20_TOKEN_SUPPLY, { from: tokenOwner });
    console.log("ERC20 Lent2 Initialize Gas: " + tx.receipt.gasUsed);
    totcost = tx.receipt.gasUsed * GAS_PRICE;
    console.log("ERC20 Lent2 Initialize costs: " + web3.utils.fromWei(totcost.toString(), 'ether') + " ETH");
    result = await this.erc20Lent2.owner();
    console.log("erc20Lent2 owner address: " + result);
    borrBal = await this.erc20Lent2.balanceOf(tokenOwner);
    console.log(`tokenOwner Lent2 Balance: ${web3.utils.fromWei(borrBal, "ether")} Stable Coin2 Tokens`);
  });

  it('send some collateral tokens to borrower3', async function () {
    console.log(`borrower3 address: ${borrower3}`);
    tx = await this.erc20Coll1.transfer(borrower3, web3.utils.toWei('1000000','ether'), { from: tokenOwner });
    console.log("Gas to transfer tokens to borrower3: " + tx.receipt.gasUsed);
    totcost = tx.receipt.gasUsed * GAS_PRICE;
    console.log("transfer token costs: " + web3.utils.fromWei(totcost.toString(), 'ether') + " ETH");
    borrBal = await this.erc20Coll1.balanceOf(borrower3);
    console.log(`borrower3 Collateral Balance: ${web3.utils.fromWei(borrBal, "ether")} Coll Tokens`);
    expect(web3.utils.fromWei(borrBal, "ether")).to.be.equal(new BN(1000000).toString());
  });

  it('send some collateral tokens to borrower4', async function () {
    console.log(`borrower4 address: ${borrower4}`);
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
    console.log("factoryOwner address: " + factoryOwner);
    this.JFeesCollector = await JFeesCollector.new({ from: factoryOwner })
    tx = await web3.eth.getTransactionReceipt(this.JFeesCollector.transactionHash);
    expect(this.JFeesCollector.transactionHash).to.match(/0x[0-9a-fA-F]{64}/);
    console.log("JFeesCollector deploy Gas: " + tx.gasUsed);
    totcost = tx.gasUsed * GAS_PRICE;
    console.log("JFeesCollector deploy costs: " + web3.utils.fromWei(totcost.toString(), 'ether') + " ETH");
    expect(this.JFeesCollector.address).to.be.not.equal(ZERO_ADDRESS);
    expect(this.JFeesCollector.address).to.match(/0x[0-9a-fA-F]{40}/);
    console.log("JFeesCollector address: " + this.JFeesCollector.address);
    tx = await this.JFeesCollector.initialize({ from: factoryOwner });
    console.log("JFeesCollector Initialize Gas: " + tx.receipt.gasUsed);
    totcost = tx.receipt.gasUsed * GAS_PRICE;
    console.log("JFeesCollector Initialize costs: " + web3.utils.fromWei(totcost.toString(), 'ether') + " ETH");
    result = await this.JFeesCollector.owner();
    expect(result).to.be.equal(factoryOwner);
    console.log("JFeesCollector owner address: " + result);
  });

  it('deploys JPriceOracle', async function () {
    this.JPriceOracle = await JPriceOracle.new({ from: factoryOwner });
    tx = await web3.eth.getTransactionReceipt(this.JPriceOracle.transactionHash);
    expect(this.JPriceOracle.transactionHash).to.match(/0x[0-9a-fA-F]{64}/);
    console.log("JPriceOracle deploy Gas: " + tx.gasUsed);
    totcost = tx.gasUsed * GAS_PRICE;
    console.log("JPriceOracle deploy costs: " + web3.utils.fromWei(totcost.toString(), 'ether') + " ETH");
    expect(this.JPriceOracle.address).to.be.not.equal(ZERO_ADDRESS);
    expect(this.JPriceOracle.address).to.match(/0x[0-9a-fA-F]{40}/);
    console.log("JPriceOracle address: " + this.JPriceOracle.address);
    tx = await this.JPriceOracle.initialize({ from: factoryOwner });
    console.log("JPriceOracle Initialize Gas: " + tx.receipt.gasUsed);
    totcost = tx.receipt.gasUsed * GAS_PRICE;
    console.log("JPriceOracle Initialize costs: " + web3.utils.fromWei(totcost.toString(), 'ether') + " ETH");
    result = await this.JPriceOracle.owner();
    expect(result).to.be.equal(factoryOwner);
    console.log("JPriceOracle owner address: " + result);
  });

  it('deploys JLoanHelper', async function () {
    this.JLoanHelper = await JLoanHelper.new(this.JPriceOracle.address, { from: factoryOwner });
    tx = await web3.eth.getTransactionReceipt(this.JLoanHelper.transactionHash);
    expect(this.JLoanHelper.transactionHash).to.match(/0x[0-9a-fA-F]{64}/);
    console.log("JLoanHelper deploy Gas: " + tx.gasUsed);
    totcost = tx.gasUsed * GAS_PRICE;
    console.log("JLoanHelper deploy costs: " + web3.utils.fromWei(totcost.toString(), 'ether') + " ETH");
    expect(this.JLoanHelper.address).to.be.not.equal(ZERO_ADDRESS);
    expect(this.JLoanHelper.address).to.match(/0x[0-9a-fA-F]{40}/);
    console.log("JLoanHelper address: " + this.JLoanHelper.address);
    /*tx = await this.JLoanHelper.initialize(this.JPriceOracle.address, { from: factoryOwner });
    console.log("JLoanHelper Initialize Gas: " + tx.receipt.gasUsed);
    totcost = tx.receipt.gasUsed * GAS_PRICE;
    console.log("JLoanHelper Initialize costs: " + web3.utils.fromWei(totcost.toString(), 'ether') + " ETH");*/
    result = await this.JLoanHelper.owner();
    expect(result).to.be.equal(factoryOwner);
    console.log("JLoanHelper owner address: " + result);
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
    console.log(await this.JPriceOracle.getPairBaseAddress(0));
    console.log(await this.JPriceOracle.getPairQuoteAddress(0));
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
    console.log(await this.JPriceOracle.getPairBaseAddress(1));
    console.log(await this.JPriceOracle.getPairQuoteAddress(1));
  });

  it('set new admin in Price oracle contract', async function () {
    tx = await this.JPriceOracle.addAdmin(factoryAdmin, {from: factoryOwner});
    expect(tx.receipt.transactionHash).to.match(/0x[0-9a-fA-F]{64}/);
    console.log(tx.receipt.gasUsed);
    totcost = tx.receipt.gasUsed * GAS_PRICE;
    console.log("New admin costs: " + web3.utils.fromWei(totcost.toString(), 'ether') + " ETH");
    expect(await this.JPriceOracle.isAdmin(factoryAdmin)).to.be.true;
  });

  it('owner set again the same address as admin', async function () {
    await expectRevert(this.JPriceOracle.addAdmin(factoryAdmin, {from: factoryOwner}), "Address already Administrator.");
  });

  it('owner set new price in price oracle contract fro pair 0', async function () {
    tx = await this.JPriceOracle.setPairValue(0, 35885, 2, {from: factoryOwner});
    expect(tx.receipt.transactionHash).to.match(/0x[0-9a-fA-F]{64}/);
    console.log(tx.receipt.gasUsed);
    totcost = tx.receipt.gasUsed * GAS_PRICE;
    console.log("New price costs: " + web3.utils.fromWei(totcost.toString(), 'ether') + " ETH");
    const pair = await this.JPriceOracle.pairs(0);
    const result = await this.JPriceOracle.getPairValue(0);
    expect(result).to.be.bignumber.equal(pair.pairValue);
  });

  it('owner set new price in price oracle contract for pair 1', async function () {
    tx = await this.JPriceOracle.setPairValue(1, 16785, 6, {from: factoryOwner});
    expect(tx.receipt.transactionHash).to.match(/0x[0-9a-fA-F]{64}/);
    console.log(tx.receipt.gasUsed);
    totcost = tx.receipt.gasUsed * GAS_PRICE;
    console.log("New price costs: " + web3.utils.fromWei(totcost.toString(), 'ether') + " ETH");
    const pair = await this.JPriceOracle.pairs(0);
    const result = await this.JPriceOracle.getPairValue(0);
    expect(result).to.be.bignumber.equal(pair.pairValue);
  });

  it('admin deploys loan contract', async function () {
    this.JLoan = await JLoan.new({ from: factoryOwner });
    tx = await web3.eth.getTransactionReceipt(this.JLoan.transactionHash);
    expect(this.JLoan.transactionHash).to.match(/0x[0-9a-fA-F]{64}/);
    console.log("JLoan deploy Gas: " + tx.gasUsed);
    totcost = tx.gasUsed * GAS_PRICE;
    console.log("JLoan deploy costs: " + web3.utils.fromWei(totcost.toString(), 'ether') + " ETH");
    expect(this.JLoan.address).to.be.not.equal(ZERO_ADDRESS);
    expect(this.JLoan.address).to.match(/0x[0-9a-fA-F]{40}/);
    console.log("JLoanHelper address: " + this.JLoan.address);
    tx = await this.JLoan.initialize(this.JPriceOracle.address, this.JFeesCollector.address, this.JLoanHelper.address, { from: factoryOwner });
    console.log("JLoan Initialize Gas: " + tx.receipt.gasUsed);
    totcost = tx.receipt.gasUsed * GAS_PRICE;
    console.log("JLoan Initialize costs: " + web3.utils.fromWei(totcost.toString(), 'ether') + " ETH");
    result = await this.JLoan.owner();
    expect(result).to.be.equal(factoryOwner);
    console.log("JLoan owner address: " + result);
  });

}



function borrowersOpenLoans (factoryOwner, borrower1, borrower2, borrower3, borrower4) {
  it('borrower1 calls how much collateral needs to deploy loan contract asking STABLE_COIN_AMOUNT1 stable coins tokens', async function () {
    console.log(`borrower1 address: ${borrower1}`);
    var borrBal = await web3.eth.getBalance(borrower1);
    console.log(`New borrower1 Balance: ${web3.utils.fromWei(borrBal, "ether")} ETH`);
    collAmount = await this.JLoan.getMinCollateralWithFeesAmount(0, web3.utils.toWei(STABLE_COIN_AMOUNT1.toString(),'ether'), {from: borrower1})
    console.log(`Min Collateral Amount: ${web3.utils.fromWei(collAmount, "ether")} ETH`);
    true;
  });

  it('borrower1 open a loan asking STABLE_COIN_AMOUNT1 tokens', async function () {
    console.log("JLoanHelper address: " + this.JLoanHelper.address);
    console.log("JLoan address: " + this.JLoan.address);
    collAmount = await this.JLoan.getMinCollateralWithFeesAmount(0, web3.utils.toWei(STABLE_COIN_AMOUNT1.toString(),'ether'), {from: borrower1})
    console.log(`Min collateral Amount: ${web3.utils.fromWei(collAmount, "ether")} ETH`);
    tx = await this.JLoan.openNewLoan(0, web3.utils.toWei(STABLE_COIN_AMOUNT1.toString(),'ether'), LOAN_RPB_RATE, {from: borrower1, value: collAmount})
    console.log(tx.receipt.gasUsed);
    totcost = tx.receipt.gasUsed * GAS_PRICE;
    console.log("New eth loan open costs: " + web3.utils.fromWei(totcost.toString(), 'ether') + " ETH");
    expectEvent(tx, "CollateralReceived");
    contractBalance = await this.JLoan.getContractBalance(0);
    console.log(`Contract Balance: ${web3.utils.fromWei(contractBalance.toString(), "ether")} ETH`);
    loanBalance = await this.JLoan.getLoanBalance(0);
    console.log(`Loan 0 Balance: ${web3.utils.fromWei(loanBalance.toString(), "ether")} ETH`);
    var borrBal = await web3.eth.getBalance(borrower1);
    console.log(`New borrower1 Balance: ${web3.utils.fromWei(borrBal, "ether")} ETH`);
    loansNum = await this.JLoan.loanId();
    expect(loansNum.toString()).to.be.equal(new BN(1).toString());
  });

  it('borrower2 open a loan asking STABLE_COIN_AMOUNT2 tokens', async function () {
    console.log(`borrower2 address: ${borrower2}`);
    collAmount = await this.JLoan.getMinCollateralWithFeesAmount(0, web3.utils.toWei(STABLE_COIN_AMOUNT2.toString(),'ether'), {from: borrower2})
    console.log(`Min collateral Amount: ${web3.utils.fromWei(collAmount, "ether")} ETH`);
    tx = await this.JLoan.openNewLoan(0, web3.utils.toWei(STABLE_COIN_AMOUNT2.toString(),'ether'), LOAN_RPB_RATE, {from: borrower2, value: collAmount})
    console.log(tx.receipt.gasUsed);
    totcost = tx.receipt.gasUsed * GAS_PRICE;
    console.log("New eth loan open costs: " + web3.utils.fromWei(totcost.toString(), 'ether') + " ETH");
    expectEvent(tx, "CollateralReceived");
    contractBalance = await this.JLoan.getContractBalance(1);
    console.log(`Contract Balance: ${web3.utils.fromWei(contractBalance.toString(), "ether")} ETH`);
    loanBalance = await this.JLoan.getLoanBalance(1);
    console.log(`Loan 1 Balance: ${web3.utils.fromWei(loanBalance.toString(), "ether")} ETH`);
    var borrBal = await web3.eth.getBalance(borrower2);
    console.log(`New borrower2 Balance: ${web3.utils.fromWei(borrBal, "ether")} ETH`);
    loansNum = await this.JLoan.loanId();
    expect(loansNum.toString()).to.be.equal(new BN(2).toString());
  });

  it('borrower2 cannot open a loan on pair1 since he has no token for collateral', async function () {
    console.log(`borrower2 address: ${borrower2}`);
    collAmount = await this.JLoan.getMinCollateralWithFeesAmount(1, web3.utils.toWei(STABLE_COIN_AMOUNT2.toString(),'ether'), {from: borrower2})
    console.log(`Min collateral Amount: ${web3.utils.fromWei(collAmount, "ether")} ETH`);
    await expectRevert(this.JLoan.openNewLoan(1, web3.utils.toWei(STABLE_COIN_AMOUNT2.toString(),'ether'), LOAN_RPB_RATE, {from: borrower2}), "!allowance");
    tx = await this.erc20Coll1.approve(this.JLoan.address, collAmount, {from: borrower2});
    console.log(tx.receipt.gasUsed);
    totcost = tx.receipt.gasUsed * GAS_PRICE;
    console.log("Borrower2 allowance costs: " + web3.utils.fromWei(totcost.toString(), 'ether') + " ETH");
    await expectRevert(this.JLoan.openNewLoan(1, web3.utils.toWei(STABLE_COIN_AMOUNT2.toString(),'ether'), LOAN_RPB_RATE, {from: borrower2}), "TH TRANSFER_FROM_FAILED");
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
    console.log(`borrower3 Collateral Balance: ${web3.utils.fromWei(borrBal, "ether")} Coll Tokens`);
    collAmount = await this.JLoan.getMinCollateralWithFeesAmount(1, web3.utils.toWei(STABLE_COIN_AMOUNT3.toString(),'ether'), {from: borrower3});
    console.log(`Min collateral Amount: ${web3.utils.fromWei(collAmount, "ether")} Coll.Tokens`);
    tx = await this.erc20Coll1.approve(this.JLoan.address, collAmount, {from: borrower3});
    console.log("borrower3 Allowance: " + await this.erc20Coll1.allowance(borrower3, this.JLoan.address));
    console.log(tx.receipt.gasUsed);
    totcost = tx.receipt.gasUsed * GAS_PRICE;
    console.log("Borrower3 allowance costs: " + web3.utils.fromWei(totcost.toString(), 'ether') + " ETH");
    expect(tx.receipt.status).to.be.true;
    console.log(`Min collateral Amount: ${web3.utils.fromWei(collAmount, "ether")} Coll.Tokens`);
    tx = await this.JLoan.openNewLoan(1, web3.utils.toWei(STABLE_COIN_AMOUNT3.toString(),'ether'), LOAN_RPB_RATE, {from: borrower3})
    console.log(tx.receipt.gasUsed);
    totcost = tx.receipt.gasUsed * GAS_PRICE;
    console.log("New token loan open costs: " + web3.utils.fromWei(totcost.toString(), 'ether') + " ETH");
    expectEvent(tx, "CollateralReceived");
    contractBalance = await this.JLoan.getContractBalance(2);
    console.log(`Contract Balance: ${web3.utils.fromWei(contractBalance.toString(), "ether")} Coll.Tokens`);
    loanBalance = await this.JLoan.getLoanBalance(2);
    console.log(`Loan0 Balance: ${web3.utils.fromWei(loanBalance.toString(), "ether")} Coll.Tokens`);
    var borrBal = await this.erc20Coll1.balanceOf(borrower3);
    console.log(`New borrower3 Balance: ${web3.utils.fromWei(borrBal, "ether")} Coll.Tokens`);
    loansNum = await this.JLoan.loanId();
    expect(loansNum.toString()).to.be.equal(new BN(3).toString());
  });

  it('borrower4 open a loan asking STABLE_COIN_AMOUNT4 tokens', async function () {
    console.log(`Coll Token Address: ${this.erc20Coll1.address}`);
    console.log(`borrower4 address: ${borrower4}`);
    borrBal = await this.erc20Coll1.balanceOf(borrower4);
    console.log(`borrower4 Collateral Balance: ${web3.utils.fromWei(borrBal, "ether")} Coll.Tokens`);
    collAmount = await this.JLoan.getMinCollateralWithFeesAmount(1, web3.utils.toWei(STABLE_COIN_AMOUNT4.toString(),'ether'), {from: borrower4});
    console.log(`Min collateral Amount: ${web3.utils.fromWei(collAmount, "ether")} Coll.Tokens`);
    tx = await this.erc20Coll1.approve(this.JLoan.address, collAmount, {from: borrower4});
    console.log(tx.receipt.gasUsed);
    totcost = tx.receipt.gasUsed * GAS_PRICE;
    console.log("Borrower4 allowance costs: " + web3.utils.fromWei(totcost.toString(), 'ether') + " ETH");
    expect(tx.receipt.status).to.be.true;
    console.log(`Min collateral Amount: ${web3.utils.fromWei(collAmount, "ether")} Coll.Tokens`);
    tx = await this.JLoan.openNewLoan(1, web3.utils.toWei(STABLE_COIN_AMOUNT4.toString(),'ether'), LOAN_RPB_RATE, {from: borrower4})
    console.log(tx.receipt.gasUsed);
    totcost = tx.receipt.gasUsed * GAS_PRICE;
    console.log("New eth loan open costs: " + web3.utils.fromWei(totcost.toString(), 'ether') + " ETH");
    expectEvent(tx, "CollateralReceived");
    contractBalance = await this.JLoan.getContractBalance(3);
    console.log(`Contract Balance: ${web3.utils.fromWei(contractBalance.toString(), "ether")} Coll.Tokens`);
    loanBalance = await this.JLoan.getLoanBalance(3);
    console.log(`Loan 1 Balance: ${web3.utils.fromWei(loanBalance.toString(), "ether")} Coll.Tokens`);
    var borrBal = await this.erc20Coll1.balanceOf(borrower4);
    console.log(`New borrower4 Balance: ${web3.utils.fromWei(borrBal, "ether")} Coll.Tokens`);
    loansNum = await this.JLoan.loanId();
    expect(loansNum.toString()).to.be.equal(new BN(4).toString());
  });

  it('borrowers can send collateral to pending contract', async function () {
    collAmount = new BN(1000000000);
    await expectRevert(web3.eth.sendTransaction({from: borrower1, to: this.JLoan.address, value: collAmount}), "revert");
    tx = await this.JLoan.depositEthCollateral(0, {from: borrower1, value: collAmount});
    console.log(tx.receipt.gasUsed);
    totcost = tx.receipt.gasUsed * GAS_PRICE;
    console.log("Add collateral loan0 costs: " + web3.utils.fromWei(totcost.toString(), 'ether') + " ETH");
    expectEvent(tx, "CollateralReceived");
    contractBalance = await this.JLoan.getContractBalance(0);
    console.log(`Contract Balance: ${web3.utils.fromWei(contractBalance.toString(), "ether")} ETH`);
    loanBalance = await this.JLoan.getLoanBalance(0);
    console.log(`Loan1 Balance: ${web3.utils.fromWei(loanBalance.toString(), "ether")} ETH`);
    
    tx = await this.erc20Coll1.approve(this.JLoan.address, collAmount, {from: borrower4});
    console.log(tx.receipt.gasUsed);
    totcost = tx.receipt.gasUsed * GAS_PRICE;
    console.log("Borrower4 allowance costs: " + web3.utils.fromWei(totcost.toString(), 'ether') + " ETH");
    tx = await this.JLoan.depositTokenCollateral(3, this.erc20Coll1.address, collAmount, {from: borrower4});
    console.log(tx.receipt.gasUsed);
    totcost = tx.receipt.gasUsed * GAS_PRICE;
    console.log("Add collateral loan3 costs: " + web3.utils.fromWei(totcost.toString(), 'ether') + " ETH");
    expectEvent(tx, "CollateralReceived");
    contractBalance = await this.JLoan.getContractBalance(3);
    console.log(`Contract Balance: ${web3.utils.fromWei(contractBalance.toString(), "ether")} Coll. Tokens`);
    loanBalance = await this.JLoan.getLoanBalance(3);
    console.log(`Loan3 Balance: ${web3.utils.fromWei(loanBalance.toString(), "ether")} ETH`);
  });
}



function lendersActivateLoans (borrower1, borrower2, borrower3, borrower4, lender1, lender2) {
  it('lender1 sends stable coins to loan0', async function () {
    var lenderBal = await this.erc20Lent1.balanceOf(lender1);
    console.log(`Lender1 Stable coins Balance: ${web3.utils.fromWei(lenderBal, "ether")} Stable coins`)
    await this.erc20Lent1.approve(this.JLoan.address, web3.utils.toWei(STABLE_COIN_AMOUNT1.toString(),'ether'), {from: lender1});
    console.log("Lender1 Allowance: " + await this.erc20Lent1.allowance(lender1, this.JLoan.address))
    tx = await this.JLoan.lenderSendStableCoins(0, this.erc20Lent1.address, {from: lender1});
    console.log(tx.receipt.gasUsed);
    totcost = tx.receipt.gasUsed * GAS_PRICE;
    console.log("Lender1 send stable coins to loan 0 costs: " + web3.utils.fromWei(totcost.toString(), 'ether') + " ETH");
    expectEvent(tx, "LoanStatusChanged");
    loanStatus0 = await this.JLoan.getLoanStatus(0);
    console.log("Loan 0 Status:" + loanStatus0);
    loanStatus1 = await this.JLoan.getLoanStatus(1);
    console.log("Loan 1 Status:" + loanStatus1);
    contractBalance = await this.JLoan.getContractBalance(0);
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
    tx = await this.JLoan.isShareholder(0, lender1);
    expect(tx).to.be.true;
    tx = await this.JLoan.getShareholderPlace(0, lender1);
    expect(tx.toString()).to.be.equal(new BN(1).toString());
    tx = await this.JLoan.loanShareholders(0, 1);
    expect(tx.holder).to.be.equal(lender1);
    expect((tx.shares).toString()).to.be.equal(new BN(100).toString());
  });

  it('lender1 send stable coins to loan1', async function () {
    var lenderBal = await this.erc20Lent1.balanceOf(lender1);
    console.log(`Lender1 Stable coins Balance: ${web3.utils.fromWei(lenderBal, "ether")} Stable coins`)
    await this.erc20Lent1.approve(this.JLoan.address, web3.utils.toWei(STABLE_COIN_AMOUNT2.toString(),'ether'), {from: lender1});
    console.log("Lender1 Allowance: " + await this.erc20Lent1.allowance(lender1, this.JLoan.address))
    tx = await this.JLoan.lenderSendStableCoins(1, this.erc20Lent1.address, {from: lender1});
    console.log(tx.receipt.gasUsed);
    totcost = tx.receipt.gasUsed * GAS_PRICE;
    console.log("Lender1 send stable coins to loan 1 costs: " + web3.utils.fromWei(totcost.toString(), 'ether') + " ETH");
    loanStatus0 = await this.JLoan.getLoanStatus(0);
    console.log("Loan 0 Status:" + loanStatus0);
    loanStatus1 = await this.JLoan.getLoanStatus(1);
    console.log("Loan 1 Status:" + loanStatus1);
    contractBalance = await this.JLoan.getContractBalance(1);
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
    tx = await this.JLoan.isShareholder(1, lender1);
    expect(tx).to.be.true;
    tx = await this.JLoan.getShareholderPlace(1, lender1);
    expect(tx.toString()).to.be.equal(new BN(1).toString());
    tx = await this.JLoan.loanShareholders(1, 1);
    expect(tx.holder).to.be.equal(lender1);
    expect((tx.shares).toString()).to.be.equal(new BN(100).toString());
  });

  it('lender2 sends stable coins to loan2', async function () {
    var lenderBal = await this.erc20Lent2.balanceOf(lender2);
    console.log(`Lender2 Stable coins Balance: ${web3.utils.fromWei(lenderBal, "ether")} Stable coins`)
    await this.erc20Lent2.approve(this.JLoan.address, web3.utils.toWei(STABLE_COIN_AMOUNT3.toString(),'ether'), {from: lender2});
    console.log("Lender2 Allowance: " + await this.erc20Lent2.allowance(lender2, this.JLoan.address))
    tx = await this.JLoan.lenderSendStableCoins(2, this.erc20Lent2.address, {from: lender2});
    console.log(tx.receipt.gasUsed);
    totcost = tx.receipt.gasUsed * GAS_PRICE;
    console.log("Lender2 send stable coins to loan 2 costs: " + web3.utils.fromWei(totcost.toString(), 'ether') + " ETH");
    expectEvent(tx, "LoanStatusChanged");
    loanStatus2 = await this.JLoan.getLoanStatus(2);
    console.log("Loan 2 Status:" + loanStatus2);
    loanStatus3 = await this.JLoan.getLoanStatus(3);
    console.log("Loan 3 Status:" + loanStatus3);
    contractBalance = await this.JLoan.getContractBalance(2);
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
    tx = await this.JLoan.isShareholder(2, lender2);
    expect(tx).to.be.true;
    tx = await this.JLoan.getShareholderPlace(2, lender2);
    expect(tx.toString()).to.be.equal(new BN(1).toString());
    tx = await this.JLoan.loanShareholders(2, 1);
    expect(tx.holder).to.be.equal(lender2);
    expect((tx.shares).toString()).to.be.equal(new BN(100).toString());
  });

  it('lender2 send stable coins to loan3', async function () {
    var lenderBal = await this.erc20Lent2.balanceOf(lender2);
    console.log(`Lender2 Stable coins Balance: ${web3.utils.fromWei(lenderBal, "ether")} Stable coins`)
    await this.erc20Lent2.approve(this.JLoan.address, web3.utils.toWei(STABLE_COIN_AMOUNT4.toString(),'ether'), {from: lender2});
    console.log("Lender Allowance: " + await this.erc20Lent2.allowance(lender2, this.JLoan.address))
    tx = await this.JLoan.lenderSendStableCoins(3, this.erc20Lent2.address, {from: lender2});
    console.log(tx.receipt.gasUsed);
    totcost = tx.receipt.gasUsed * GAS_PRICE;
    console.log("Lender2 send stable coins to loan 3 costs: " + web3.utils.fromWei(totcost.toString(), 'ether') + " ETH");
    loanStatus2 = await this.JLoan.getLoanStatus(2);
    console.log("Loan 2 Status:" + loanStatus2);
    loanStatus3 = await this.JLoan.getLoanStatus(3);
    console.log("Loan 3 Status:" + loanStatus3);
    contractBalance = await this.JLoan.getContractBalance(3);
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
    tx = await this.JLoan.isShareholder(3, lender2);
    expect(tx).to.be.true;
    tx = await this.JLoan.getShareholderPlace(3, lender2);
    expect(tx.toString()).to.be.equal(new BN(1).toString());
    tx = await this.JLoan.loanShareholders(3, 1);
    expect(tx.holder).to.be.equal(lender2);
    expect((tx.shares).toString()).to.be.equal(new BN(100).toString());
  });
}


function borrowersAddCollateral(borrower1, borrower2, borrower3, borrower4) {
  it('borrower1 can send collateral to active loans', async function () {
    console.log("Loan 0 collateral ratio: " + await this.JLoan.getActualCollateralRatio(0));
    console.log("Loan 1 collateral ratio: " + await this.JLoan.getActualCollateralRatio(1));
    ten_eth = new BN(web3.utils.toWei('10', "ether"));
    tx = await this.JLoan.depositEthCollateral(0, {from: borrower1, value: ten_eth});
    console.log(tx.receipt.gasUsed);
    totcost = tx.receipt.gasUsed * GAS_PRICE;
    console.log("borrower1 adding collateral costs: " + web3.utils.fromWei(totcost.toString(), 'ether') + " ETH");
    contractBalance = await this.JLoan.getContractBalance(0);
    console.log(`Contract Balance: ${web3.utils.fromWei(contractBalance.toString(), "ether")} ETH`);
    loanBalance = await this.JLoan.getLoanBalance(0);
    console.log(`Loan0 Balance: ${web3.utils.fromWei(loanBalance.toString(), "ether")} ETH`);
    loanBalance = await this.JLoan.getLoanBalance(1);
    console.log(`Loan1 Balance: ${web3.utils.fromWei(loanBalance.toString(), "ether")} ETH`);
    console.log("New collateral ratio loan0: " + await this.JLoan.getActualCollateralRatio(0));
    console.log("New collateral ratio loan1: " + await this.JLoan.getActualCollateralRatio(1));
  });

  it('borrower2 can send collateral to active loans', async function () {
    console.log("Loan 0 collateral ratio: " + await this.JLoan.getActualCollateralRatio(0));
    console.log("Loan 1 collateral ratio: " + await this.JLoan.getActualCollateralRatio(1));
    ten_eth = new BN(web3.utils.toWei('10', "ether"));
    tx = await this.JLoan.depositEthCollateral(1, {from: borrower2, value: ten_eth});
    console.log(tx.receipt.gasUsed);
    totcost = tx.receipt.gasUsed * GAS_PRICE;
    console.log("borrower2 adding collateral costs: " + web3.utils.fromWei(totcost.toString(), 'ether') + " ETH");
    contractBalance = await this.JLoan.getContractBalance(1);
    console.log(`Contract Balance: ${web3.utils.fromWei(contractBalance.toString(), "ether")} ETH`);
    loanBalance = await this.JLoan.getLoanBalance(0);
    console.log(`Loan0 Balance: ${web3.utils.fromWei(loanBalance.toString(), "ether")} ETH`);
    loanBalance = await this.JLoan.getLoanBalance(1);
    console.log(`Loan1 Balance: ${web3.utils.fromWei(loanBalance.toString(), "ether")} ETH`);
    console.log("New collateral ratio loan0: " + await this.JLoan.getActualCollateralRatio(0));
    console.log("New collateral ratio loan1: " + await this.JLoan.getActualCollateralRatio(1));
  });

  it('borrower3 can send token collateral to active contract', async function () {
    console.log("Loan2 collateral ratio: " + await this.JLoan.getActualCollateralRatio(2));
    console.log("Loan3 collateral ratio: " + await this.JLoan.getActualCollateralRatio(3));
    tenth_tok = web3.utils.toWei('10000', "ether");
    tx = await this.erc20Coll1.approve(this.JLoan.address, tenth_tok, {from: borrower3});
    console.log(tx.receipt.gasUsed);
    totcost = tx.receipt.gasUsed * GAS_PRICE;
    console.log("borrower3 approve costs: " + web3.utils.fromWei(totcost.toString(), 'ether') + " ETH");
    tx = await this.JLoan.depositTokenCollateral(2, this.erc20Coll1.address, tenth_tok, {from: borrower3});
    console.log(tx.receipt.gasUsed);
    totcost = tx.receipt.gasUsed * GAS_PRICE;
    console.log("borrower3 adding collateral costs: " + web3.utils.fromWei(totcost.toString(), 'ether') + " ETH");
    expectEvent(tx, "CollateralReceived");
    contractBalance = await this.JLoan.getContractBalance(2);
    console.log(`Contract Balance: ${web3.utils.fromWei(contractBalance.toString(), "ether")} Collat. Coins`);
    loanBal = await this.JLoan.getLoanBalance(2);
    console.log(`loan2 Balance: ${web3.utils.fromWei(loanBal.toString(), "ether")} Collat. Coins`);
    console.log("New collateral ratio loan2: " + await this.JLoan.getActualCollateralRatio(2));
    console.log("New collateral ratio loan3: " + await this.JLoan.getActualCollateralRatio(3));
  });

  it('borrower4 can send token collateral to active contract', async function () {
    console.log("Loan2 collateral ratio: " + await this.JLoan.getActualCollateralRatio(2));
    console.log("Loan3 collateral ratio: " + await this.JLoan.getActualCollateralRatio(3));
    tenth_tok = web3.utils.toWei('10000', "ether");
    tx = await this.erc20Coll1.approve(this.JLoan.address, tenth_tok, {from: borrower4});
    console.log(tx.receipt.gasUsed);
    totcost = tx.receipt.gasUsed * GAS_PRICE;
    console.log("borrower4 approve costs: " + web3.utils.fromWei(totcost.toString(), 'ether') + " ETH");
    tx = await this.JLoan.depositTokenCollateral(3, this.erc20Coll1.address, tenth_tok, {from: borrower4});
    console.log(tx.receipt.gasUsed);
    totcost = tx.receipt.gasUsed * GAS_PRICE;
    console.log("borrower4 adding collateral costs: " + web3.utils.fromWei(totcost.toString(), 'ether') + " ETH");
    expectEvent(tx, "CollateralReceived");
    contractBalance = await this.JLoan.getContractBalance(3);
    console.log(`Contract Balance: ${web3.utils.fromWei(contractBalance.toString(), "ether")} Collat. Coins`);
    loanBal = await this.JLoan.getLoanBalance(3);
    console.log(`loan3 Balance: ${web3.utils.fromWei(loanBal.toString(), "ether")} Collat. Coins`);
    console.log("New collateral ratio loan2: " + await this.JLoan.getActualCollateralRatio(2));
    console.log("New collateral ratio loan3: " + await this.JLoan.getActualCollateralRatio(3));
  });
}



function lendersGetAccruedInterest(lender1, lender2) {
  it('lender1 can have accrued interests from loan0 and loan1 as per RPB', async function () {
    lenderBal = await web3.eth.getBalance(lender1);
    console.log(`Lender1 ETH Balance: ${web3.utils.fromWei(lenderBal, "ether")} ETH`)
    console.log("Accrued interests loan0: " + await this.JLoan.getAccruedInterests(0));
    console.log("Accrued interests loan1: " + await this.JLoan.getAccruedInterests(1));
    contractBalance = await this.JLoan.getContractBalance(0);
    console.log(`Contract Balance: ${web3.utils.fromWei(contractBalance.toString(), "ether")} ETH`);
    loanBalance = await this.JLoan.getLoanBalance(0);
    console.log(`Loan0 Balance: ${web3.utils.fromWei(loanBalance.toString(), "ether")} ETH`);
    loanBalance = await this.JLoan.getLoanBalance(1);
    console.log(`Loan1 Balance: ${web3.utils.fromWei(loanBalance.toString(), "ether")} ETH`);
    tx = await this.JLoan.withdrawInterests(0, {from: lender1});
    console.log(tx.receipt.gasUsed);
    totcost = tx.receipt.gasUsed * GAS_PRICE;
    console.log("Lender withdraw interests from loan0 costs: " + web3.utils.fromWei(totcost.toString(), 'ether') + " ETH");
    tx = await this.JLoan.withdrawInterests(1, {from: lender1});
    console.log(tx.receipt.gasUsed);
    totcost = tx.receipt.gasUsed * GAS_PRICE;
    console.log("Lender withdraw interests from loan1 costs: " + web3.utils.fromWei(totcost.toString(), 'ether') + " ETH");
    contractBalance = await this.JLoan.getContractBalance(0);
    console.log(`Contract Balance: ${web3.utils.fromWei(contractBalance.toString(), "ether")} ETH`);
    loanBalance = await this.JLoan.getLoanBalance(0);
    console.log(`Loan 0 Balance: ${web3.utils.fromWei(loanBalance.toString(), "ether")} ETH`);
    loanBalance = await this.JLoan.getLoanBalance(1);
    console.log(`Loan 1 Balance: ${web3.utils.fromWei(loanBalance.toString(), "ether")} ETH`);
    console.log("New collateral ratio loan0: " + await this.JLoan.getActualCollateralRatio(0));
    console.log("New collateral ratio loan1: " + await this.JLoan.getActualCollateralRatio(1));
    lenderBal = await web3.eth.getBalance(lender1);
    console.log(`New lender1 ETH Balance: ${web3.utils.fromWei(lenderBal, "ether")} ETH`)
  });

  it('lender2 can have accrued interests from loan2 and loan3 as per RPB', async function () {
    lenderBal = await this.erc20Coll1.balanceOf(lender2);
    console.log(`Lender2 Coll Tokens Balance: ${web3.utils.fromWei(lenderBal, "ether")} Collat. Coins`);
    console.log("Accrued interests loan2: " + await this.JLoan.getAccruedInterests(2));
    console.log("Accrued interests loan3: " + await this.JLoan.getAccruedInterests(3));
    contractBalance = await this.JLoan.getContractBalance(3);
    console.log(`Contract Balance: ${web3.utils.fromWei(contractBalance.toString(), "ether")} Collat. Coins`);
    loanBalance = await this.JLoan.getLoanBalance(2);
    console.log(`Loan2 Balance: ${web3.utils.fromWei(loanBalance.toString(), "ether")} Collat. Coins`);
    loanBalance = await this.JLoan.getLoanBalance(3);
    console.log(`Loan3 Balance: ${web3.utils.fromWei(loanBalance.toString(), "ether")} Collat. Coins`);
    tx = await this.JLoan.withdrawInterests(2, {from: lender2});
    console.log(tx.receipt.gasUsed);
    totcost = tx.receipt.gasUsed * GAS_PRICE;
    console.log("Lender2 withdraw interests costs: " + web3.utils.fromWei(totcost.toString(), 'ether') + " ETH");
    tx = await this.JLoan.withdrawInterests(3, {from: lender2});
    console.log(tx.receipt.gasUsed);
    totcost = tx.receipt.gasUsed * GAS_PRICE;
    console.log("Lender2 withdraw interests costs: " + web3.utils.fromWei(totcost.toString(), 'ether') + " ETH");
    expectEvent(tx, "InterestsWithdrawed");
    contractBalance = await this.JLoan.getContractBalance(3);
    console.log(`Contract Balance: ${web3.utils.fromWei(contractBalance.toString(), "ether")} Collat. Coins`);
    loanBalance = await this.JLoan.getLoanBalance(2);
    console.log(`Loan2 Balance: ${web3.utils.fromWei(loanBalance.toString(), "ether")} Collat. Coins`);
    loanBalance = await this.JLoan.getLoanBalance(3);
    console.log(`Loan3 Balance: ${web3.utils.fromWei(loanBalance.toString(), "ether")} Collat. Coins`);
    console.log("New collateral ratio loan2: " + await this.JLoan.getActualCollateralRatio(0));
    console.log("New collateral ratio loan3: " + await this.JLoan.getActualCollateralRatio(1));
    lenderBal = await this.erc20Coll1.balanceOf(lender2);
    console.log(`Lender2 Coll Tokens Balance: ${web3.utils.fromWei(lenderBal, "ether")} Collat. Coins`);
  });

}

function priceDownfor150(factoryAdmin) {
  it('ETH pair price goes down, collateral under 150%, foreclosing', async function () {
    console.log("Pair price: " + await this.JPriceOracle.getPairValue(0));
    console.log("Loan0 collateral ratio: " + await this.JLoan.getActualCollateralRatio(0));
    console.log("Loan1 collateral ratio: " + await this.JLoan.getActualCollateralRatio(1));
    loanStatus = await this.JLoan.getLoanStatus(0);
    console.log("Loan0 Status:" + loanStatus);
    loanStatus = await this.JLoan.getLoanStatus(1);
    console.log("Loan1 Status:" + loanStatus);
    tx = await this.JPriceOracle.setPairValue(0, 22500, 2, {from: factoryAdmin});
    console.log(tx.receipt.gasUsed);
    totcost = tx.receipt.gasUsed * GAS_PRICE;
    console.log("Pair price change costs: " + web3.utils.fromWei(totcost.toString(), 'ether') + " ETH");
    pair = await this.JPriceOracle.pairs(0);
    newPrice = await this.JPriceOracle.getPairValue(0);
    expect(newPrice.toString()).to.be.bignumber.equal((pair.pairValue).toString());
    console.log("Pair Price: " + newPrice);
    console.log("Loan0 collateral ratio: " + await this.JLoan.getActualCollateralRatio(0));
    console.log("Loan1 collateral ratio: " + await this.JLoan.getActualCollateralRatio(1));
    loanStatus0 = await this.JLoan.getLoanStatus(0);
    console.log("Loan0 Status:" + loanStatus0);
    loanStatus1 = await this.JLoan.getLoanStatus(1);
    console.log("Loan1 Status:" + loanStatus1);
    expect(loanStatus0.toString()).to.be.equal(new BN(1).toString());
    expect(loanStatus1.toString()).to.be.equal(new BN(1).toString());
  });

  it('Coll Token pair price goes down, collateral under 150%, foreclosing', async function () {
    console.log("Pair price: " + await this.JPriceOracle.getPairValue(1));
    console.log("Loan2 collateral ratio: " + await this.JLoan.getActualCollateralRatio(2));
    console.log("Loan3 collateral ratio: " + await this.JLoan.getActualCollateralRatio(3));
    loanStatus = await this.JLoan.getLoanStatus(2);
    console.log("Loan2 Status:" + loanStatus);
    loanStatus = await this.JLoan.getLoanStatus(3);
    console.log("Loan3 Status:" + loanStatus);
    tx = await this.JPriceOracle.setPairValue(1, 10785, 6, {from: factoryAdmin});
    console.log(tx.receipt.gasUsed);
    totcost = tx.receipt.gasUsed * GAS_PRICE;
    console.log("Pair price change costs: " + web3.utils.fromWei(totcost.toString(), 'ether') + " ETH");
    pair = await this.JPriceOracle.pairs(1);
    newPrice = await this.JPriceOracle.getPairValue(1);
    expect(newPrice.toString()).to.be.bignumber.equal((pair.pairValue).toString());
    console.log("Pair Price: " + newPrice);
    console.log("Loan2 collateral ratio: " + await this.JLoan.getActualCollateralRatio(2));
    console.log("Loan3 collateral ratio: " + await this.JLoan.getActualCollateralRatio(3));
    loanStatus2 = await this.JLoan.getLoanStatus(2);
    console.log("Loan2 Status:" + loanStatus2);
    loanStatus3 = await this.JLoan.getLoanStatus(3);
    console.log("Loan3 Status:" + loanStatus3);
    expect(loanStatus2.toString()).to.be.equal(new BN(1).toString());
    expect(loanStatus3.toString()).to.be.equal(new BN(1).toString());
  });
}


function firstForeclosing(foreclosureAgent) {
  it('initiate foreclosure procedures for ETH collateral under 150% but above 120%, status from 1 to 4 on loan1, no change on loan0', async function () {
    agentBal = await web3.eth.getBalance(foreclosureAgent);
    console.log(`foreclosureAgent Balance: ${web3.utils.fromWei(agentBal, "ether")} ETH`);
    tx = await this.JLoan.initiateLoanForeclose(1, {from: foreclosureAgent});
    console.log(tx.receipt.gasUsed);
    totcost = tx.receipt.gasUsed * GAS_PRICE;
    console.log("Initiate Loan1 Foreclose costs: " + web3.utils.fromWei(totcost.toString(), 'ether') + " ETH");
    agentBal = await web3.eth.getBalance(foreclosureAgent);
    console.log(`foreclosureAgent Balance: ${web3.utils.fromWei(agentBal, "ether")} ETH`);
    JFeesCollBalance = await this.JFeesCollector.getEthBalance();
    console.log(`JFeesCollector Balance: ${web3.utils.fromWei(JFeesCollBalance.toString(), "ether")} ETH`);
    console.log("Loan0 collateral ratio: " + await this.JLoan.getActualCollateralRatio(0));
    console.log("Loan1 collateral ratio: " + await this.JLoan.getActualCollateralRatio(1));
    loanStatus0 = await this.JLoan.getLoanStatus(0);
    console.log("Loan0 Status:" + loanStatus0);
    loanStatus1 = await this.JLoan.getLoanStatus(1);
    console.log("Loan1 Status:" + loanStatus1);
    expect(loanStatus0).to.be.bignumber.equal(new BN(1).toString());
    expect(loanStatus1).to.be.bignumber.equal(new BN(4).toString());
  });

  it('initiate foreclosure procedures for Token collateral under 150% but above 120%, status from 1 to 4 on loan3, no change on loan2', async function () {
    agentBal = await web3.eth.getBalance(foreclosureAgent);
    console.log(`foreclosureAgent Balance: ${web3.utils.fromWei(agentBal, "ether")} ETH`);
    agentBal = await this.erc20Coll1.balanceOf(foreclosureAgent);
    console.log(`foreclosureAgent Balance: ${web3.utils.fromWei(agentBal, "ether")} Collat. Coins`);
    tx = await this.JLoan.initiateLoanForeclose(3, {from: foreclosureAgent});
    console.log(tx.receipt.gasUsed);
    totcost = tx.receipt.gasUsed * GAS_PRICE;
    console.log("Initiate Loan3 Foreclose costs: " + web3.utils.fromWei(totcost.toString(), 'ether') + " ETH");
    agentBal = await this.erc20Coll1.balanceOf(foreclosureAgent);
    console.log(`foreclosureAgent Balance: ${web3.utils.fromWei(agentBal, "ether")} Collat. Coins`);
    JFeesCollBalance = await this.JFeesCollector.getTokenBalance(this.erc20Coll1.address);
    console.log(`JFeesCollector Balance: ${web3.utils.fromWei(JFeesCollBalance.toString(), "ether")} Collat. Coins`);
    console.log("Loan2 collateral ratio: " + await this.JLoan.getActualCollateralRatio(2));
    console.log("Loan3 collateral ratio: " + await this.JLoan.getActualCollateralRatio(3));
    loanStatus2 = await this.JLoan.getLoanStatus(2);
    console.log("Loan2 Status:" + loanStatus2);
    loanStatus3 = await this.JLoan.getLoanStatus(3);
    console.log("Loan3 Status:" + loanStatus3);
    expect(loanStatus2).to.be.bignumber.equal(new BN(1).toString());
    expect(loanStatus3).to.be.bignumber.equal(new BN(4).toString());
  });

  it('initiate foreclosure procedures even on loan0', async function () {
    agentBal = await web3.eth.getBalance(foreclosureAgent);
    console.log(`foreclosureAgent Balance: ${web3.utils.fromWei(agentBal, "ether")} ETH`);
    tx = await this.JLoan.initiateLoanForeclose(0, {from: foreclosureAgent});
    console.log(tx.receipt.gasUsed);
    totcost = tx.receipt.gasUsed * GAS_PRICE;
    console.log("Initiate Loan1 Foreclose costs: " + web3.utils.fromWei(totcost.toString(), 'ether') + " ETH");
    agentBal = await web3.eth.getBalance(foreclosureAgent);
    console.log(`foreclosureAgent Balance: ${web3.utils.fromWei(agentBal, "ether")} ETH`);
    JFeesCollBalance = await this.JFeesCollector.getEthBalance();
    console.log(`JFeesCollector Balance: ${web3.utils.fromWei(JFeesCollBalance.toString(), "ether")} ETH`);
    console.log("Loan0 collateral ratio: " + await this.JLoan.getActualCollateralRatio(0));
    console.log("Loan1 collateral ratio: " + await this.JLoan.getActualCollateralRatio(1));
    loanStatus0 = await this.JLoan.getLoanStatus(0);
    console.log("Loan Status:" + loanStatus0);
    loanStatus1 = await this.JLoan.getLoanStatus(1);
    console.log("Loan Status:" + loanStatus1);
    expect(loanStatus0).to.be.bignumber.equal(new BN(4).toString());
    expect(loanStatus1).to.be.bignumber.equal(new BN(4).toString());
  });

  it('initiate foreclosure procedures even on loan2', async function () {
    agentBal = await web3.eth.getBalance(foreclosureAgent);
    console.log(`foreclosureAgent Balance: ${web3.utils.fromWei(agentBal, "ether")} ETH`);
    agentBal = await this.erc20Coll1.balanceOf(foreclosureAgent);
    console.log(`foreclosureAgent Balance: ${web3.utils.fromWei(agentBal, "ether")} Collat. Coins`);
    tx = await this.JLoan.initiateLoanForeclose(2, {from: foreclosureAgent});
    console.log(tx.receipt.gasUsed);
    totcost = tx.receipt.gasUsed * GAS_PRICE;
    console.log("Initiate Loan3 Foreclose costs: " + web3.utils.fromWei(totcost.toString(), 'ether') + " ETH");
    agentBal = await this.erc20Coll1.balanceOf(foreclosureAgent);
    console.log(`foreclosureAgent Balance: ${web3.utils.fromWei(agentBal, "ether")} Collat. Coins`);
    JFeesCollBalance = await this.JFeesCollector.getTokenBalance(this.erc20Coll1.address);
    console.log(`JFeesCollector Balance: ${web3.utils.fromWei(JFeesCollBalance.toString(), "ether")} Collat. Coins`);
    console.log("Loan2 collateral ratio: " + await this.JLoan.getActualCollateralRatio(2));
    console.log("Loan3 collateral ratio: " + await this.JLoan.getActualCollateralRatio(3));
    loanStatus2 = await this.JLoan.getLoanStatus(2);
    console.log("Loan2 Status:" + loanStatus2);
    loanStatus3 = await this.JLoan.getLoanStatus(3);
    console.log("Loan3 Status:" + loanStatus3);
    expect(loanStatus2).to.be.bignumber.equal(new BN(4).toString());
    expect(loanStatus3).to.be.bignumber.equal(new BN(4).toString());
  });

  it('initiate again foreclosure procedures for collateral under 150% for loan0 and loan1 (fail)', async function () {
    await expectRevert(this.JLoan.initiateLoanForeclose(0, {from: foreclosureAgent}), "!Status23");
    await expectRevert(this.JLoan.initiateLoanForeclose(1, {from: foreclosureAgent}), "!Status23");
  });

  it('initiate again foreclosure procedures for collateral under 150% for loan2 and loan3 (fail)', async function () {
    await expectRevert(this.JLoan.initiateLoanForeclose(2, {from: foreclosureAgent}), "!Status23");
    await expectRevert(this.JLoan.initiateLoanForeclose(3, {from: foreclosureAgent}), "!Status23");
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