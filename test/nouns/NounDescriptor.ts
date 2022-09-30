import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import { expect } from 'chai'
import { Contract } from 'ethers'
import { ethers } from 'hardhat'
import { TreasuryNote__factory } from '../../typechain-types'

describe('Noun', () => {
  let alice: SignerWithAddress
  let bob: SignerWithAddress
  let found: Contract
  let desc: Contract

  beforeEach(async () => {
    [alice, bob] = await ethers.getSigners()
    const NounData = await ethers.getContractFactory('NounData')
    desc = await NounData.deploy()
  })

  it('Creates descriptor', async () => {
    // const res = await desc.dataJSON({
    //   id: 1,
    //   idea: 1,
    //   amount: 0,
    //   expiresAt: Math.floor(new Date().getTime() / 1000),
    //   startedAt: Math.floor(new Date().getTime() / 1000),
    //   endedAt: 0,
    //   founder: alice.address,
    //   redeemer: ethers.constants.AddressZero
    // })
  })
})
