import { task } from 'hardhat/config'
import { simulate } from './simulate'

task('simulate', 'Simulates contract interactions', async (_, { ethers }) => {
  const Found = await ethers.getContractFactory('Found')
  const found = await Found.deploy()

  const Govt = await ethers.getContractFactory('Government')
  const govt = await Govt.deploy(found.address)
  await found.setTreasurer(govt.address, true)

  const [origin, ...signers] = await ethers.getSigners()

  console.log('ORIGIN: ' + origin.address)
  console.log('FOUND: ' + found.address)
  console.log('GOVT: ' + govt.address)

  await simulate({
    duration: 24 * 101,
    stepsPerDay: 24,
    signers,
    found,
    govt,
    verbose: true
  })
})
