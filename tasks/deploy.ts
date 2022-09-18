import { task } from 'hardhat/config'

task('deploy', 'Deploys contracts', async (_, { ethers }) => {
  const Found = await ethers.getContractFactory('Found')
  const found = await Found.deploy()

  const Govt = await ethers.getContractFactory('Government')
  const govt = await Govt.deploy(found.address)
  await found.activateTreasurer(govt.address)

  const [origin] = await ethers.getSigners()

  const addresses = { found: found.address, govt: govt.address }

  console.log('ORIGIN: ' + origin.address)
  console.log('FOUND: ' + found.address)
  console.log('GOVT: ' + govt.address)

  console.log(addresses)
})
