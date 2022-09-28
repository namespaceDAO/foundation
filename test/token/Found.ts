import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import { expect } from 'chai'
import { Contract } from 'ethers'
import { parseEther } from 'ethers/lib/utils'
import { ethers } from 'hardhat'

describe('Found', () => {
  let origin: SignerWithAddress
  let alice: SignerWithAddress
  let bob: SignerWithAddress
  let found: Contract

  beforeEach(async () => {
    [origin, alice, bob] = await ethers.getSigners()
    const Found = await ethers.getContractFactory('Found')
    found = await Found.deploy()
  })

  it('Create FOUND with getters', async () => {
  })

  it('Mints FOUND to minter and treasury', async () => {
  })

  it('Transfer ETHER and FOUND from treasury', async () => {
  })

  it('Origin claim found and value', async () => {
  })

  it('Fails to claim too much', async () => {
  })
})
