import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import { expect } from 'chai'
import { Contract } from 'ethers'
import { ethers } from 'hardhat'
import { CapitalismDescriptor__factory } from '../../typechain-types'

describe('Noun', () => {
  let alice: SignerWithAddress
  let bob: SignerWithAddress
  let found: Contract
  let desc: Contract

  beforeEach(async () => {
    [alice, bob] = await ethers.getSigners()
    const NounsDescriptor = await ethers.getContractFactory('NounsDescriptor')
    desc = await NounsDescriptor.deploy()
  })

  it('Creates descriptor', async () => {
    const res = await desc.dataURI({
      id: 1,
      idea: 1,
      amount: 0,
      expiresAt: Math.floor(new Date().getTime() / 1000),
      startedAt: Math.floor(new Date().getTime() / 1000),
      endedAt: 0,
      founder: alice.address,
      redeemer: ethers.constants.AddressZero
    })

    console.log(res)
  })
})
