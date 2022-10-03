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

Bank of Nouns creates one ERC20 every day. The coin for each day is determined by voting for a Noun you like. The Noun with the most votes becomes the Noun coin for the day. 

- Every early minters receive a 10x early minting bonus of the new coin. 
- After the first day the mint price of the coin is determined by the supply relative to every other coin. The more demand the higher the price. 
- The treasury mains an average mint price of 1 Noun coin = 1 FOUND.
- Early minting 10x bonus is 10 Noun coins = 1 FOUND.

## Adventure

Adventure is a contract for distributing FOUND among multiple parties. 
- FOUND is distributed by staking FOUND. 
- Shares are determined by the mint activity and stake duration. 
- Ending your stake returns the prinicipal plus proceeds.

## Governance

Governance contains a tax on mint fees to create a community treasury. The treasury serves as a de facto mechanism for funding public goods. Currently the tax is 0% as there is no government.

## Future: Noun Cards

Create Noun cards by forging Noun coins. The power of the Noun card is determined by how many Noun coins were forged to create it. Players vote who can withdraw money from the treasury. Each treasurer has a number of shares that determines their claim of proceeds. 

## Future: Forged Coins

Create forged Noun coins by combining multiple Noun coins together. For example, combine a rubber ducky and a paper hat to create a new Noun coin that reflects the combined value of the originals. 

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