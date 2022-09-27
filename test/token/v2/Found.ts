import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import { expect } from 'chai'
import { Contract } from 'ethers'
import { parseEther } from 'ethers/lib/utils'
import { ethers } from 'hardhat'

describe('Found 2', () => {
  let origin: SignerWithAddress
  let treasurer: SignerWithAddress
  let alice: SignerWithAddress
  let bob: SignerWithAddress
  let found: Contract

  beforeEach(async () => {
    [origin, treasurer, alice, bob] = await ethers.getSigners()
    const Found = await ethers.getContractFactory('Found1')
    found = await Found.deploy(origin.address, 0)
    await found.activateTreasurer(treasurer.address)
  })

  it('Create FOUND with getters', async () => {
    const name = await found.name()
    const symbol = await found.symbol()
    const balance = await found.valueBalance()
    const isTreasurerActive = await found.isTreasurerActive(treasurer.address)

    const totalValue = await found.totalValue()
    const claimedValue = await found.claimedValue()
    const claimedToken = await found.claimedToken()

    expect(name).to.equal('FOUND')
    expect(symbol).to.equal('FOUND')
    expect(balance).to.equal(0)
    expect(isTreasurerActive).to.equal(true)
    expect(claimedValue).to.equal(0)
    expect(claimedToken).to.equal(0)
    expect(totalValue).to.equal(0)
  })

  it('Mints FOUND to minter and treasury', async () => {
    const value = ethers.utils.parseEther(`${Math.random() + 1}`)
    const e1 = await found.valueBalance()

    await found.mint(alice.address, { value })

    const ba = await found.balanceOf(alice.address)
    const bt = await found.balanceOf(found.address)
    const e2 = await found.valueBalance()

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
    await found.connect(treasurer).pushValue(bob.address, half)
    await found.connect(treasurer).pushToken(bob.address, half)

    const b2 = await bob.getBalance()
    const f2 = await found.balanceOf(bob.address)

    expect(b1.add(half)).to.equal(b2)
    expect(f1.add(half)).to.equal(f2)
  })

  it('Origin claim found and value', async () => {
    await found.mint(alice.address, { value: parseEther('20') })

    const foundClaim = parseEther(`${Math.random()}`)
    const valueClaim = parseEther(`${Math.random()}`)

    const bf1 = await found.balanceOf(bob.address)
    const bv1 = await bob.getBalance()

    await found.claimValue(bob.address, valueClaim, 'my memo')
    await found.claimToken(bob.address, foundClaim, 'my memo')

    const bf2 = await found.balanceOf(bob.address)
    const bv2 = await bob.getBalance()

    expect(bf1.add(foundClaim)).to.equal(bf2)
    expect(bv1.add(valueClaim)).to.equal(bv2)

    await found.claimValue(bob.address, valueClaim, 'my memo')
    await found.claimToken(bob.address, foundClaim, 'my memo')

    const totalValue = await found.totalValue()
    const claimedValue = await found.claimedValue()
    const claimedToken = await found.claimedToken()

    expect(claimedValue).to.equal(valueClaim.mul(2))
    expect(claimedToken).to.equal(foundClaim.mul(2))
    expect(totalValue).to.equal(parseEther('20'))
  })

  it('Fails to claim too much', async () => {
    await found.mint(alice.address, { value: parseEther('10') })

    await expect(
      found.claimValue(bob.address, parseEther('1.0000001'), 'my memo')
    ).to.rejectedWith('Value claim too large')

    await expect(
      found.claimToken(bob.address, parseEther('1.0000001'), 'my memo')
    ).to.rejectedWith('Token claim too large')
  })
})
