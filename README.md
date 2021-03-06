# Tranche

[![T|J](https://i.ibb.co/Ch5nFSD/logo-3.png)](https://jibrel.network)

    

Tranche is a decentralized finance protocol that allows users to create different risk profiles from DeFi cash-flow. Users can borrow or lend funds, as well as use the loan smart contracts to create new assets with different pay-out schedules.

The Tranche ecosystem is currently developing the following verticals:

- Lending Platform  (Published / Under Audit)
- Governance and the Tranche Token  (Unpublished / Under Audit) 
- Earning Assets  (In Progress)


## Lending and Borrowing

Tranche allows users to provide loans to other users, judging their credit-worthiness on a case-by-case basis. By doing so, Tranche aims to reduce collateralization ratios to below 100% in the near future. Tranche currently offers two different borrowing and lending pairs:

- ETH/DAI
- USDC/SLICE

The first version of the borrowing and lending platform is currently live at on the Kovan Test Network and can be accessed using this link: https://testnet-v1.tranche.finance/

You can go through the [Tranche Documentation](https://app.gitbook.com/@tranche/s/tranche-documentation/) to find user guides on how to use the platform.

### Lending and Borrowing Smart Contracts

The contracts for the platform are live and audited by , and we welcome any feedback or input. The current system architecture is comprised of four main contracts:

1. [JLoan](https://github.com/tranche-jibrel/loan-contracts/blob/master/contracts/JLoan.sol): This is the main contract that controls all the functions related to loan creation, loan closing, interest management, and reward and fee management, while utilizing other contracts listed below. 

2. [JLoanHelper](https://github.com/tranche-jibrel/loan-contracts/blob/master/contracts/JLoanHelper.sol) : This contract contains all heavy calculations and support functions for JLoan. 

3. [JPriceOracle](https://github.com/tranche-jibrel/loan-contracts/blob/master/contracts/JPriceOracle.sol) : This contract contract stores all pairs and their properties, including values, addresses and decimals. 

4. [JFeesCollector](https://github.com/tranche-jibrel/loan-contracts/blob/master/contracts/JFeesCollector.sol) : This contract acts as a collector of every fee generated by the system.

## Governance and Tranche Token

Tranche holders control and govern the network. Holders vote on proposals, modify parameters, and collect rewards for doing so. In addition, SLICE holders get to participate in any earnings that accrue within the protocol.

Governance and token documentation is in progress. 

## Earning Assets

Tranche's main benefit is in that it allows users to combine loans, or parts of loans, to create different Earning Assets with different risk profiles. Users can convert loans into four tranches (Tranches A, B, C, and T), that have different debt seniority (i.e. who gets paid first). By doing so, the protocol allows users to break the same loan into high-risk, high yield assets, and low-risk, low yield assets.

Earning Asset documentation is currently in progress.
