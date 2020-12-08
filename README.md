# Steps to deploy upgradeable contracts
#### a single wallet should deploy everything in this phase, because some function are marked as onlyOwner

#### use "deployProxy" whenever you deploy with Truffle, and update contracts using "upgradeProxy"

#### to set the owner inside contracts please call initialize function for eache one, eventually inserting other required parameters

a) deploy JFeesCollector contract.

b) deploy JPriceOracle contract.

c) deploy JLoanHelper contract (JPriceOracle address in initialize).

d) deploy JLoan (JPriceOracle, JFeesCollector and JLoanHelper in initialize)

e) create 1 or more pair to have prices inside JPriceOracle contract (setNewPair, see description below, again only owner can do that). When ETH is the collateral, base address should be set to address(0).

f) calculate the amount needed to have a loan in stable coin units (calcMinCollateralWithFeesAmount(uint256 _pairId, uint256 _askAmount), this is a public function). The result of this function is in wei. 

g) from JLoan contract open a new loan:

	 openNewLoan(uint256 _pairId, uint256 _borrowedAskAmount, uint256 _rpbRate)


h) you can find total opened loans calling loanId from Jloan contract

i) add address for tokens that JFeesCollector contract has to allow, with addTokenToList(address _tok) (onlyOwner).


## Setting a pair
When setting a new pair, the following function has to be called:

	function setNewPair(string memory _pairName, uint256 _price, uint8 _pairDecimals, uint8 _baseDecimals, uint8 _quoteDecimals) public onlyOwner 
	
It is important to have this standard:

	- pairName: base currency is collateral and quote currency is the token lender should send to borrower (stable coin or others). 
	As an example, if it is "ETHDAI" ETH (base) is the collateral token and DAI (quote) is the lending token 
	- price: without decimal separator (i.e. 327,75 becomes 327750 if you set pairdecimals to 3).
	- pairDecimals: decimals the pair is expressed in (i.e. 3). Please don't set too many decimals, I think that 8-10 should be the max
	- baseAddress: address of base token (if eth you have to set 0x0000000000000000000000000000000000000000)
	- baseDecimals: decimals of the base token (i.e. eth = 18)
	- quoteAddress: address of quote token (if eth you have to set 0x0000000000000000000000000000000000000000)
	- quoteDecimals: decimals of the quote token (i.e. dai = 18)
	
Please note that amounts in calculation functions are expressed with all decimals (i.e. 1 ether = 1000000000000000000 wei).

Functions are provided to change values inside the JFactory contract.



## Upgradeable contracts

Please refer to the following guides:
https://docs.openzeppelin.com/upgrades-plugins/1.x/writing-upgradeable
https://simpleaswater.com/upgradable-smart-contracts/?ref=eth_stackexchange
https://docs.nucypher.com/en/latest/architecture/upgradeable_proxy_contracts.html
https://github.com/OpenZeppelin/openzeppelin-upgrades/blob/master/packages/plugin-truffle/README.md

To upgrade contracts, you can use truffle or buidler:
https://www.trufflesuite.com/blog/a-sweet-upgradeable-contract-experience-with-openzeppelin-and-truffle
https://docs.openzeppelin.com/upgrades-plugins/1.x/

Remeber to set optimizer to true in .openzeppelin/project.json, as well as to configure optimization when compiling.

Please use:
npx oz compile    	to compile contracts
npx oz deploy		to deploy contracts, choosing if they should be upgradeable or not
npx oz upgrade		to upgrade contracts

or if you prefer truffle, please follow this guide: https://github.com/OpenZeppelin/openzeppelin-upgrades/blob/master/packages/plugin-truffle/README.md

NB) remember to clean up ./openzeppelin folder when starting from scratch, the only file that should be present is "project.json"
