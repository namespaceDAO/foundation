import { task } from 'hardhat/config'
import { initialize } from './initialize'
import { simulate } from './simulate'
import { createActors } from './strategy'

task('simulate', 'Simulates contract interactions', async (_, { ethers }) => {
  const init = await initialize({ ethers })

  const config = {
    duration: 24,
    secondsPerStep: 3600 * 6,
    verbose: true
  }

  await simulate({
    ...init,
    ...config,
    actors: createActors(init)
  })
})
