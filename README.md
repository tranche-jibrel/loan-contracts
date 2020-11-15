# Steps to deploy loans Factory 
#### a single wallet should deploy everything in this phase, because some function are marked as onlyOwner

a) first the deployer should be deployed (JLoanDeployer)

b) deploy JFeesCollector (eth and tokens allowed).

c) then the factory should be deployed (JFactory) with deployer address in parameters of constructor

d) set the factory address inside the deployer (setLoanFactory(factoryAddress), only owner can do that)

e) set the fee collectsr address inside the deployer (setFeesCollector(address payable _feeColl), only owner can do that)

f) create 1 or more pair to have prices inside JFactory contract (setNewPair, see description below, again only owner can do that). When ETH is the collateral, base address should be set to address(0).

g) calculate the amount needed to have a loan in stable coin units (calcMinCollateralWithFeesAmount(uint _pairId, uint _askAmount), this is public). The result of this function is in wei. 

h) from JFactory deploy a contract that will be used for every pair:

	createNewLoanContract()


i) please find total deployed loans calling pairCounter, and ask for address with getDeployedLoan(uint _idx) to have loans contract address (JFactory)

j) add tokens into JFeesCollector contract with addTokenToList(address _tok) (onlyOwner) to find token balances.


## Setting a pair
When setting a new pair, the following function has to be called:

	function setNewPair(string memory _pairName, uint _price, uint8 _pairDecimals, uint8 _baseDecimals, uint8 _quoteDecimals) public onlyOwner 
	
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

