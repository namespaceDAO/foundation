import { HardhatUserConfig } from 'hardhat/config'
import '@nomicfoundation/hardhat-toolbox'
import '@nomiclabs/hardhat-etherscan'
import 'hardhat-gas-reporter'
import dotenv from 'dotenv'

export * from './tasks'

dotenv.config()

const isProduction = process.env.ENV === 'prod'

const config: HardhatUserConfig = {
  solidity: {
    version: '0.8.10',
    settings: {
      optimizer: {
        enabled: isProduction,
        runs: 10000
      }
    }
  },
  gasReporter: {
    enabled: isProduction,
    coinmarketcap: process.env.COIN_MARKET_CAP_API_KEY,
    currency: 'USD'
    // gasPrice: 26
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY
  },
  networks: {
    // ropsten: process.env.ROPSTEN_PRIVATE_KEY != null
    //   ? {
    //       url: process.env.ROPSTEN_URL,
    //       accounts: [process.env.ROPSTEN_PRIVATE_KEY]
    //     }
    //   : undefined,
    // rinkeby: process.env.RINKEBY_PRIVATE_KEY != null
    //   ? {
    //       url: process.env.RINKEBY_URL,
    //       accounts: [process.env.RINKEBY_PRIVATE_KEY]
    //     }
    //   : undefined
    // mainnet: process.env.MAINNET_PRIVATE_KEY != null
    //   ? {
    //       url: process.env.MAINNET_URL,
    //       accounts: [process.env.MAINNET_PRIVATE_KEY]
    //     }
    //   : undefined
  }
}

export default config
