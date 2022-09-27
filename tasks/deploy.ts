import { task } from 'hardhat/config'

task('deploy', 'Deploys contracts', async (_, { ethers }) => {
  const Found = await ethers.getContractFactory('Found1')

  const originAddress = '0x5E2DDebd950aAc94dE0eCCf981FF0ece6ed7eedE'
  const found = await Found.deploy(originAddress, 1666666667)

  console.log('ORIGIN: ' + originAddress)
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
