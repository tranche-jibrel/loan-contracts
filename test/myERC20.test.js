const { accounts, contract } = require('@openzeppelin/test-environment');
const { expect } = require('chai');
const {
    BN           // Big Number support
  } = require('@openzeppelin/test-helpers');
const { shouldBehaveLikeERC20 } = require('./ERC20.behaviour');

// Create a contract object from a compilation artifact
const MyContract = contract.fromArtifact('myERC20');

// Start test block
describe('myERC20', function () {
  const initialSupply = new BN('2000000');
  const [ owner, recipient, anotherAccount ] = accounts;

  beforeEach(async function () {
    this.value = new BN(1);
    // Deploy a new contract for each test
    this.token = await MyContract.new(initialSupply, { from: owner });
  });

  shouldBehaveLikeERC20('ERC20', (new BN('2000000000000000000000000')), owner, recipient, anotherAccount); // Appended 18 0s because initialSupply is multiplied by 10**18 in the constructor

  describe('is initialized properly', function () {
    it('has a name', async function () {
      expect(await this.token.name()).to.equal("NewJNT");
    });

    it('has a symbol', async function () {
      expect(await this.token.symbol()).to.equal("NJNT");
    });

    it('has 18 decimals', async function () {
      const dec = (await this.token.decimals()).toString();
      expect(dec).to.equal('18');
    });
  });

});