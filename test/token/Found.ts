import { ethers } from 'hardhat'
import { expect } from 'chai'
import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import { Contract } from 'ethers'

describe('Found', () => {
  let origin: SignerWithAddress
  let treasurer: SignerWithAddress
  let alice: SignerWithAddress
  let bob: SignerWithAddress
  let found: Contract

  beforeEach(async () => {
    [origin, treasurer, alice, bob] = await ethers.getSigners()
    const Found = await ethers.getContractFactory('Found')
    found = await Found.deploy()
    await found.setTreasurer(treasurer.address, true)
  })

  it('Create FOUND with getters', async () => {
    const name = await found.name()
    const symbol = await found.symbol()
    const balance = await found.treasuryBalance()
    const isTreasurer = await found.isTreasurer(treasurer.address)
    expect(name).to.equal('FOUND')
    expect(symbol).to.equal('FOUND')
    expect(balance).to.equal(0)
    expect(isTreasurer).to.equal(true)
  })

  it('Mints FOUND to minter and treasury', async () => {
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

  it('Transfer ETHER and FOUND from treasury', async () => {
    const amount = Math.floor(Math.random() * 1000) / 1000
    const value = ethers.utils.parseEther(`${amount}`)
    const half = ethers.utils.parseEther(`${amount / 2}`)

    const b1 = await bob.getBalance()
    const f1 = await found.balanceOf(bob.address)

    await found.mint(alice.address, { value })
    await found.connect(treasurer).transferValue(bob.address, half)
    await found.connect(treasurer).treasuryTransfer(found.address, bob.address, half)

    const b2 = await bob.getBalance()
    const f2 = await found.balanceOf(bob.address)

    expect(b1.add(half)).to.equal(b2)
    expect(f1.add(half)).to.equal(f2)
  })
})
