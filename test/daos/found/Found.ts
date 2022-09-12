import { ethers } from 'hardhat'
import { expect } from 'chai'
import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import { Contract } from 'ethers'

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
    const name = await found.name()
    const symbol = await found.symbol()
    expect(name).to.equal('FOUND')
    expect(symbol).to.equal('FOUND')
  })

  it('Mints FOUND', async () => {
    const value = ethers.utils.parseEther(`${Math.random()}`)
    await found.mint(alice.address, { value })

    const ba = await found.balanceOf(alice.address)
    const bt = await found.balanceOf(found.address)

    expect(ba).to.equal(value)
    expect(bt).to.equal(value)

    // TODO: check if ether was sent correctly
  })
})
