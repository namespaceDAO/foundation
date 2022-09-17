# FOUND

- Found is an ERC20 where 1 ETH = 1 FOUND. For every FOUND minted an extra FOUND is deposited into the treasury to be used by the community.
- Money (either FOUND or ETH) can be withdrawn from the treasury using the governance mechanism.

# GOVERNANCE

- Builders submit proposals to the Foundation with a request for funding. 
- Funders who hold found stake on proposals to earn extra money from the treasury. 
- Staking acts as a de facto selection mechanism for things worth building.

# DEVELOPMENT
```
yarn install

// run all tests
npx hardhat test

// test one file
npx hardhat test --grep Found

// run the simulation
npx hardhat simulate

// compile contracts
npx hardhat compile
```