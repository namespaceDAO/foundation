import { task } from 'hardhat/config'

task('deploy', 'Deploys contracts', async (_, { ethers }) => {
  const [origin] = await ethers.getSigners()

  const BASE_URI = 'https://bankofnouns.com/_/api/tokens/{id}.json'

  const Found = await ethers.getContractFactory('Found')
  const found = await Found.deploy()

  const NounMove = await ethers.getContractFactory('NounMove')
  const game = await NounMove.deploy(found.address, BASE_URI)

  const NounBank = await ethers.getContractFactory('NounBank')
  const bank = NounBank.attach(await game.bank())

  console.log('ORIGIN: ' + origin.address)
  console.log('FOUND: ' + found.address)
  console.log('GAME: ' + game.address)
  console.log('BANK: ' + bank.address)

  // const Govt = await ethers.getContractFactory('Government')
  // const govt = await Govt.deploy(found.address)
  // await found.activateTreasurer(govt.address)

  // const addresses = { found: found.address, govt: govt.address }

  // console.log('ORIGIN: ' + originAddress)
  // console.log('FOUND: ' + found.address)
  // console.log('GOVT: ' + govt.address)

  // console.log(addresses)
})
