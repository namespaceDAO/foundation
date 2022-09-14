import { ethers } from 'hardhat'
import { expect } from 'chai'
import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import { Contract } from 'ethers'

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

    const balance = await treasury.treasuryBalance()
    expect(balance).to.equal(seed)

    const isTreasurer = await treasury.isTreasurer(origin.address)
    expect(isTreasurer).to.equal(false)
  })

  it('Change treasurer', async () => {
    await treasury.setTreasurer(treasurer.address, true)
    const isTreasurer = await treasury.isTreasurer(treasurer.address)
    expect(isTreasurer).to.equal(true)
  })

  it('Transfers funds for treasurer', async () => {
    const balance1 = await bob.getBalance()
    const treasury1 = await treasury.treasuryBalance()

    const transfer = ethers.utils.parseEther(`${Math.random()}`)
    await treasury.connect(treasurer).transferValue(bob.address, transfer)

    const balance2 = await bob.getBalance()
    const treasury2 = await treasury.treasuryBalance()
    expect(balance2.sub(balance1)).to.equal(transfer)
    expect(treasury1.sub(transfer)).to.equal(treasury2)
  })

  it('Fails to overspend funds', async () => {
    const balance = await treasury.treasuryBalance()
    const tooMuch = balance.mul(2)
    await expect(
      treasury.connect(treasurer).transferValue(origin.address, tooMuch)
    ).to.revertedWith('Treasury: transfer exceeds treasury balance')
  })

  it('Fails to transfer funds when not treasurer', async () => {
    const value = ethers.utils.parseEther(`${Math.random()}`)
    await expect(
      treasury.transferValue(bob.address, value)
    ).to.revertedWith('Treasury: caller is not the treasurer')
  })

  it('Fails to change treasurer when not owner', async () => {
    await expect(
      treasury.connect(alice).setTreasurer(alice.address, true)
    ).to.revertedWith('Ownable: caller is not the owner')
  })
})
