# Bank of Nouns

Updated on Sep 30 2022

## Nouns

Nouns are pixel art. Anyone can create a Noun, you just need a name and a 32x32 image. For example this rubber ducky.

![Noun example](assets/ducky.png)

Nouns are stored 100% on chain in the `NounData` contract.

    struct Noun {
        uint id;
        string name;
        bytes pixels;
        address creator;
    }

## Game of Nouns

Bank of Nouns creates one crypto currency every day. The coin for each day is determined by mystery minting on a Noun you like. The Noun with the most FOUND mystery minted becomes the coin for the day. Every early minter receives a 10x early minting bonus. After the first day the price of the coin is determined by the supply relative to every other coin. The more coins there are, the more expensive they are to mint and vice versa. Noun coins are bounded between 1 and 10000 coins to every FOUND with the target of 100. Early minting gives you 1000 Noun coins = 1 FOUND. 

## Adventure

Adventure is a contract for distributing FOUND among multiple parties. FOUND is distributed via shares created by staking FOUND. Share rates are determined by the mint activity and stake duration. FOUND is paid by unstaking. 

## Governance

Governance contains a tax on mint fees to create a community treasury. The treasury serves as a de facto mechanism for funding public goods. Currently the tax is 0% as there is no government.

## Future: Noun Cards

Create Noun cards by forging Noun coins. The power of the Noun card is determined by how many Noun coins were forged to create it. Players vote who can withdraw money from the treasury. Each treasurer has a number of shares that determines their claim of proceeds. 

# Development
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