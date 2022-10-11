# Bank of Nouns

One crypto currency every day forever. Every Noun coin is represented by a piece of art stored 100% on chain. Anyone can create a Noun for example this rubber ducky:

![Noun example](assets/ducky.png)

## Minting Noun Coins

New Nouns become Noun coins when collectors vote for art. The art with the most votes wins and everyone who voted gets a 10x early mint bonus.

After the first day the price of each coin is proportional to the supply of every other coin. The more demand, the more expensive the coin.

If there are two Noun coins:

|        | Supply      | Mint Price   
| ------ | ----------- | ------------- 
| Coin A | 1000        | `1000 / FOUND`  
| Coin B | 1000        | `1000 / FOUND`
| *Next* | -           | `10000 / FOUND`

Or two coins with different supplies:

|        | Supply      | Mint Price   
| ------ | ----------- | ------------- 
| Coin A | 1000        | `2000 / FOUND`  
| Coin B | 3000        | ` 667 / FOUND`
| *Next* | -           | `10000 / FOUND`

Or if there are five coins:

|        | Supply      | Mint Price   
| ------ | ----------- | ------------- 
| Coin A | 1000        | `5000 / FOUND`  
| Coin B | 3000        | `1667 / FOUND`
| Coin C | 5000        | `1000 / FOUND`  
| Coin D | 7000        | ` 714 / FOUND` 
| Coin F | 9000        | ` 555 / FOUND`
| *Next* | -           | `10000 / FOUND`

## Earning Mint Proceeds

Mint proceeds are distributed to savy capitalists who stake FOUND. Each day there are shares for sale in the Bank of Nouns. The price of the shares is proportional to how many coins were minted on the previous day. The more FOUND the bank earned, the more expensive the shares are. Capped at `10 shares / FOUND`

|        | Last week avg | Yesterday   | Base Share Price
| ------ | ------------- | ----------- | ------------- 
| Coin A | 1000          |  1000       | `1 share / FOUND`  
| Coin B | 1000          |  2000       | `0.5 shares / FOUND`
| Coin C | 1000          |   500       | `2 shares / FOUND`
| Coin D | 1000          |    10       | `10 shares / FOUND`

Additonally each stake has an expiration date. The expiration date creates a longer pays better bonus with an 10% APY on the share rate. Stakes capped at 10 years.

| Stake duration  | bonus | without bonus        | with bonus
| --------------- | ----- | -------------------- | ------------- 
|          1 year |   10% | `1 share / FOUND`    | `1.1 shares / FOUND`
|          2 year |   21% | `0.5 shares / FOUND` | `0.605 shares / FOUND`
|         5 years |   61% | `2 shares / FOUND`   | `3.22 shares / FOUND`
|        10 years |  161% | `10 shares / FOUND`  | `16 shares / FOUND`

You have 2 weeks to unstake following the expiration date or a late fee of 1.69% / day will begin. Early unstaking acrews the same penalty but in the other direction.

| Days late       | penalty | without penalty      | with penalty
| --------------- | ------- | -------------------- | ------------- 
|           1 day |   1.69% | `100 shares`         | `98.31 shares`
|          7 days |  11.24% | `100 shares`         | `88.75 shares`
|         30 days |  59.97% | `100 shares`         | `59.97 shares`
|         60 days |    161% | `100 shares`         | `35.96 shares`

Stakes over 60 days late are considered fully expired and do not recieve mint proceeds. Anyone can burn these to reduce the number of outstanding shares and increase their own payouts. 

You are paid your principal plus earnings when you unstake. Your proceeds are the current bank's balance of FOUND times your stake's shares times the total number of outstanding shares. Each stake is tradable as an NFT.