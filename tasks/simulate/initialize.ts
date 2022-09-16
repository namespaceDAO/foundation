import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import { Contract } from 'ethers'
import { HardhatEthersHelpers } from 'hardhat/types'

export interface Setup {
  found: Contract
  govt: Contract
  origin: SignerWithAddress
  signers: SignerWithAddress[]
}

export const initialize = async (ethers: HardhatEthersHelpers): Promise<Setup> => {
  const Found = await ethers.getContractFactory('Found')
  const found = await Found.deploy()

  const Govt = await ethers.getContractFactory('Government')
  const govt = await Govt.deploy(found.address)
  await found.setTreasurer(govt.address, true)

  const [origin, ...signers] = await ethers.getSigners()

  console.log('ORIGIN: ' + origin.address)
  console.log('FOUND: ' + found.address)
  console.log('GOVT: ' + govt.address)

  return { found, govt, origin, signers }
}
