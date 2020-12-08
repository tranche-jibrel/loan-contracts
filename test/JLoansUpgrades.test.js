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

const JFeesCollector = artifacts.require("JFeesCollector");
const JFeesCollector2 = artifacts.require("JFeesCollector2");

describe('JLoansUpgrades', function () {
  it('updating contract works', async () => {
    const owner = accounts[0];
    const jfc = await deployProxy(JFeesCollector, [], {from: owner});
    const jfc2 = await upgradeProxy(jfc.address, JFeesCollector2, {from: owner});

    await expectRevert(jfc2.initialize(), "Contract instance has already been initialized");

    ver = await jfc2.contractVersion();
    console.log(ver.toString());
    expect(ver.toString()).to.be.equal('1');
    await jfc2.updateVersion(2);
    ver = await jfc2.contractVersion();
    console.log(ver.toString());
    expect(ver.toString()).to.be.equal('2');

    const result = await jfc2.sayHello();
    expect(result).to.be.equal('Hello');
  });
});