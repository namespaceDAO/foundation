import { task } from 'hardhat/config'

task('deploy', 'Deploys contracts', async (_, { ethers }) => {
  const Found = await ethers.getContractFactory('Found')
  const found = await Found.deploy()
  console.log('FOUND: ' + found.address)
})
