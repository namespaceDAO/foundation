import { ethers } from 'hardhat'
import { expect } from 'chai'
import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import { BigNumber, Contract } from 'ethers'
import { parseEther } from 'ethers/lib/utils'

// TODO: test is treasurer inactive
describe('Treasury', () => {
  let origin: SignerWithAddress
  let treasurer: SignerWithAddress
  let alice: SignerWithAddress
  let bob: SignerWithAddress
  let treasury: Contract

  const seedTreasury = async (): Promise<BigNumber> => {
    const to = treasury.address
    const seed = parseEther('5')
    await origin.sendTransaction({ to, value: seed })
    return seed
  }

  beforeEach(async () => {
    [origin, treasurer, alice, bob] = await ethers.getSigners()

    const Treasury = await ethers.getContractFactory('Treasury')
    treasury = await Treasury.deploy()

    await treasury.activateTreasurer(treasurer.address)
  })

  it('Create treasury', async () => {
    [origin, treasurer, alice, bob] = await ethers.getSigners()

    const isTreasurerActive = await treasury.isTreasurerActive(origin.address)
    expect(isTreasurerActive).to.equal(false)
  })

  it('Updates balance', async () => {
    const b1 = await treasury.valueBalance()
    const seed = await seedTreasury()
    const b2 = await treasury.valueBalance()
    expect(b1.add(seed)).to.equal(b2)
  })

  it('Activate treasurer', async () => {
    const a1 = await treasury.isTreasurerActive(alice.address)
    await treasury.activateTreasurer(alice.address)
    const a2 = await treasury.isTreasurerActive(alice.address)
    expect(a1).to.equal(false)
    expect(a2).to.equal(true)
  })

  it('Dectivate treasurer', async () => {
    await treasury.activateTreasurer(bob.address)
    const a1 = await treasury.isTreasurerActive(bob.address)
    await treasury.deactivateTreasurer(bob.address)
    const a2 = await treasury.isTreasurerActive(bob.address)
    expect(a1).to.equal(true)
    expect(a2).to.equal(false)
  })

  it('Moves treasury funds', async () => {
    await seedTreasury()
    await treasury.activateTreasurer(alice.address)

    const b1 = await bob.getBalance()
    const amount = parseEther(`${Math.random()}`)
    await treasury.connect(alice).pushValue(bob.address, amount)
    const b2 = await bob.getBalance()

    expect(b1.add(amount)).to.equal(b2)
  })

  it('Fails to overspend funds', async () => {
    await seedTreasury()
    const balance = await treasury.valueBalance()
    const tooMuch = balance.mul(2)
    await expect(
      treasury.connect(treasurer).pushValue(origin.address, tooMuch)
    ).to.revertedWith('Treasury transfer exceeds balance')
  })

  it('Fails to transfer funds when not treasurer', async () => {
    await seedTreasury()
    const value = ethers.utils.parseEther(`${Math.random()}`)
    await expect(
      treasury.pushValue(bob.address, value)
    ).to.revertedWith('Caller is not the treasurer')
  })

  it('Fails to change treasurer when not owner', async () => {
    await expect(
      treasury.connect(alice).activateTreasurer(alice.address)
    ).to.revertedWith('Ownable: caller is not the owner')

    await expect(
      treasury.connect(alice).deactivateTreasurer(alice.address)
    ).to.revertedWith('Ownable: caller is not the owner')
  })
})
