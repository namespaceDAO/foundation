import { task } from 'hardhat/config'
import { initialize } from './initialize'
import { simulate } from './simulate'

task('simulate', 'Simulates contract interactions', async (_, { ethers }) => {
  const setup = await initialize(ethers)

  await simulate({
    ...setup,
    duration: 24 * 101,
    stepsPerDay: 24,
    verbose: true
  })
})
