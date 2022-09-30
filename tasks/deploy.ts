import { task } from 'hardhat/config'

task('deploy', 'Deploys contracts', async (_, { ethers }) => {
  const [origin] = await ethers.getSigners()
  const Found = await ethers.getContractFactory('Found')

  const found = await Found.deploy()
  const BASE_URI = 'https://bankofnouns.com/_/api/tokens/{id}.json'

  console.log('ORIGIN: ' + origin.address)
  console.log('FOUND: ' + found.address)

  // const Govt = await ethers.getContractFactory('Government')
  // const govt = await Govt.deploy(found.address)
  // await found.activateTreasurer(govt.address)

  // const addresses = { found: found.address, govt: govt.address }

  // console.log('ORIGIN: ' + originAddress)
  // console.log('FOUND: ' + found.address)
  // console.log('GOVT: ' + govt.address)

  // console.log(addresses)
})
