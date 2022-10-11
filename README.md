# Bank of Nouns

One crypto currency every day forever. 

## Nouns

Nouns are pixel art stored 100% on chain. Anyone can create a Noun you just need a name, an image, and a list of traits. For example this paradigm shifting rubber ducky:

![Noun example](assets/ducky.png)

Creating a Noun mints an NFT to the creator. The holder of the original Noun can claim up to 10% of the supply of that coin. Burning original Nouns is a bull signal.

## Mint Coins

Every day collectors vote for art. The Noun with the most votes becomes the day's coin. Everyone who voted early gets a 10x early minting bonus and recieves the new coin.

After the first day the price of each coin is proportional to the supply of every other coin. The more demand, the more expensive the coin.

|        | Supply      | Mint Price   
| ------ | ----------- | ------------- 
| Coin A | 1000        | `5000 / FOUND`  
| Coin B | 3000        | `1667 / FOUND`
| Coin C | 5000        | `1000 / FOUND`  
| Coin D | 7000        | ` 714 / FOUND` 
| Coin E | 9000        | ` 555 / FOUND`

## Stake and Share

Mint proceeds can be claimed by the community using a secondary token called FOUND. FOUND can be minted for 1 ETH each. An origin address holds a 10% claim on FOUND.

Every day there are shares in the Bank of Nouns for sale. The price is proportional to how many coins were minted on the previous day. The more FOUND the bank earned yesterday, the more expensive the shares are today. Capped at `10 shares / FOUND`

|        | Last week avg | Yesterday   | Base Share Price
| ------ | ------------- | ----------- | ------------- 
| Coin A | 1000          |  1000       | `1 share / FOUND`  
| Coin B | 1000          |  2000       | `0.5 shares / FOUND`
| Coin C | 1000          |   500       | `2 shares / FOUND`
| Coin D | 1000          |    10       | `10 shares / FOUND`

Each stake has an expiration date. The expiration date creates a longer pays better bonus with an 10% APY on the share rate. Stakes capped at 10 years.

| Stake duration  | bonus | without bonus        | with bonus
| --------------- | ----- | -------------------- | ------------- 
|          1 year |   10% | `1 share / FOUND`    | `1.1 shares / FOUND`
|          2 year |   21% | `0.5 shares / FOUND` | `0.605 shares / FOUND`
|         5 years |   61% | `2 shares / FOUND`   | `3.22 shares / FOUND`
|        10 years |  161% | `10 shares / FOUND`  | `16 shares / FOUND`

Stakes that remain open more than 2 weeks after the expiration date receive late fees of 1.69% / day. Early unstaking acrews the same penalty but in the other direction.

| Days late        | penalty | without penalty      | with penalty
| --------------- | ------- | -------------------- | ------------- 
|           1 day |   1.69% | `100 shares`         | `98.31 shares`
|          7 days |  11.24% | `100 shares`         | `88.75 shares`
|         30 days |  59.97% | `100 shares`         | `59.97 shares`
|         60 days |    161% | `100 shares`         | `35.96 shares`

Stakes over 60 days late are considered fully expired and do not recieve mint proceeds. Anyone can burn these stakes to reduce the number of outstanding shares and increase their (any everyone's) own payouts. 

You are paid your principal plus earnings when you unstake. Your proceeds are the current bank's balance of FOUND times your stake's shares times the total number of outstanding shares. Each stake is tradable as an NFT.

## Future: Governance

At a later date a governance mechanism could be enabled. Owners of Noun coins would vote on the tax rate (30% maximum) and destination of the proceeds. 
