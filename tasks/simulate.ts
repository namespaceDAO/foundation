import { task } from 'hardhat/config'

task('simulate', 'Simulates contract interactions', async (_, { ethers }) => {
  const Found = await ethers.getContractFactory('Found')
  const found = await Found.deploy()

  const Govt = await ethers.getContractFactory('Government')
  const govt = await Govt.deploy(found.address)

  const [origin, ...signers] = await ethers.getSigners()

  console.log('ORIGIN: ' + origin.address)
  console.log('FOUND: ' + found.address)
  console.log('GOVT: ' + govt.address)

  const duration = 10000
  const stepsPerDay = 24
  const time = Array.from(Array(duration).keys())

  const step = async (t: number): Promise<void> => {
    const day = Math.floor(t / stepsPerDay)

    // actions:
    // create prop
    // create stake
    // end stake
    // start prop
  }

  await time.reduce(async (acc, cur) => {
    return await acc.then(async () => await step(cur))
  }, Promise.resolve())
})
