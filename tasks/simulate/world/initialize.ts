import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import { Contract } from 'ethers'
import { HardhatEthersHelpers } from 'hardhat/types'

export interface Setup {
  found: Contract
  govt: Contract
  origin: SignerWithAddress
}

export interface Initialization extends Setup {
  signers: SignerWithAddress[]
}

interface Init { ethers: HardhatEthersHelpers }

export const initialize = async ({ ethers }: Init): Promise<Initialization> => {
  const Found = await ethers.getContractFactory('Found')
  const found = await Found.deploy()

  const Govt = await ethers.getContractFactory('Government')
  const govt = await Govt.deploy(found.address)
  await found.activateTreasurer(govt.address)

  const [origin, ...signers] = await ethers.getSigners()

  console.log('ORIGIN: ' + origin.address)
  console.log('FOUND: ' + found.address)
  console.log('GOVT: ' + govt.address)

  return { found, govt, origin, signers }
}
