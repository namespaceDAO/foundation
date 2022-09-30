import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import { expect } from 'chai'
import { Contract } from 'ethers'
import { ethers } from 'hardhat'
import { CapitalismDescriptor__factory } from '../../typechain-types'

describe('NounBank', () => {
  let alice: SignerWithAddress
  let bob: SignerWithAddress
  let found: Contract
  let desc: Contract
  let bank: Contract

  const BASE_URI = 'https://bankofnouns.com/_/api/tokens/{id}.json'

  beforeEach(async () => {
    [alice, bob] = await ethers.getSigners()

    const Found = await ethers.getContractFactory('Found')
    found = await Found.deploy()

    const NounDescriptor = await ethers.getContractFactory('NounDescriptor')
    desc = await NounDescriptor.deploy()

    const NounBank = await ethers.getContractFactory('NounGame')
    bank = await NounBank.deploy(BASE_URI, desc.address, found.address)
  })

  it('Creates bank', async () => {
  })
})
