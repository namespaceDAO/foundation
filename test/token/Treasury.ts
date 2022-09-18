import { ethers } from 'hardhat'
import { expect } from 'chai'
import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import { Contract } from 'ethers'

// TODO: test is treasurer inactive
describe('Treasury', () => {
  let origin: SignerWithAddress
  let treasurer: SignerWithAddress
  let alice: SignerWithAddress
  let bob: SignerWithAddress
  let treasury: Contract

  it('Create treasury', async () => {
    [origin, treasurer, alice, bob] = await ethers.getSigners()
    const Treasury = await ethers.getContractFactory('Treasury')
    treasury = await Treasury.deploy()

    const seed = ethers.utils.parseEther(`${5 * Math.random()}`)
    await origin.sendTransaction({ to: treasury.address, value: seed })

    const balance = await treasury.valueBalance()
    expect(balance).to.equal(seed)

    const isTreasurerActive = await treasury.isTreasurerActive(origin.address)
    expect(isTreasurerActive).to.equal(false)
  })

  it('Change treasurer', async () => {
    await treasury.activateTreasurer(treasurer.address)
    const isTreasurerActive = await treasury.isTreasurerActive(treasurer.address)
    expect(isTreasurerActive).to.equal(true)
  })

  it('Transfers funds for treasurer', async () => {
    const balance1 = await bob.getBalance()
    const treasury1 = await treasury.valueBalance()

    const transfer = ethers.utils.parseEther(`${Math.random()}`)
    await treasury.connect(treasurer).pushValue(bob.address, transfer)

    const balance2 = await bob.getBalance()
    const treasury2 = await treasury.valueBalance()
    expect(balance2.sub(balance1)).to.equal(transfer)
    expect(treasury1.sub(transfer)).to.equal(treasury2)
  })

  it('Fails to overspend funds', async () => {
    const balance = await treasury.valueBalance()
    const tooMuch = balance.mul(2)
    await expect(
      treasury.connect(treasurer).pushValue(origin.address, tooMuch)
    ).to.revertedWith('Treasury: transfer exceeds treasury balance')
  })

  it('Fails to transfer funds when not treasurer', async () => {
    const value = ethers.utils.parseEther(`${Math.random()}`)
    await expect(
      treasury.pushValue(bob.address, value)
    ).to.revertedWith('Treasury: caller is not the treasurer')
  })

  it('Fails to change treasurer when not owner', async () => {
    await expect(
      treasury.connect(alice).activateTreasurer(alice.address)
    ).to.revertedWith('Ownable: caller is not the owner')
  })
})
