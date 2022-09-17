import { task } from 'hardhat/config'
import { initialize } from './world/initialize'
import { simulate } from './world/simulate'
import { createActors } from './strategy'
import { Account, State, Treasury } from './world'
import { formatEther } from 'ethers/lib/utils'

task('simulate', 'Simulates contract interactions', async (_, { ethers }) => {
  const init = await initialize({ ethers })

  const config = {
    duration: 24,
    secondsPerStep: 3600 * 6,
    verbose: true
  }

  interface HistoryLog { accounts: Account[], treasury: Treasury }
  const history: HistoryLog[] = []

  await simulate({
    ethers,
    ...init,
    ...config,
    actors: createActors(init),
    afterStep: async (state) => {
      history.push({
        accounts: Object.values(state.accounts),
        treasury: state.treasury
      })
    }
  })

  console.log(history)
})
