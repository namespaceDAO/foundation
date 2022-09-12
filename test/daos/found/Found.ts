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
    const balance = await found.treasuryBalance()
    const treasurer = await found.treasurerAddress()
    expect(name).to.equal('FOUND')
    expect(symbol).to.equal('FOUND')
    expect(balance).to.equal(0)
    expect(treasurer).to.equal(origin.address)
  })

  it('Mints FOUND', async () => {
    const value = ethers.utils.parseEther(`${Math.random()}`)
    const e1 = await found.treasuryBalance()

    await found.mint(alice.address, { value })

    const ba = await found.balanceOf(alice.address)
    const bt = await found.balanceOf(found.address)
    const e2 = await found.treasuryBalance()

    expect(ba).to.equal(value)
    expect(bt).to.equal(value)
    expect(e1).to.equal(0)
    expect(e2).to.equal(value)
  })
})
