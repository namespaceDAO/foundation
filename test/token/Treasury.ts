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
    const address = await treasury.treasurerAddress()

    expect(balance).to.equal(seed)
    expect(address).to.equal(origin.address)
  })

  it('Change treasurer', async () => {
    const address1 = await treasury.treasurerAddress()
    expect(address1).to.equal(origin.address)

    await treasury.setTreasurer(treasurer.address)

    const address2 = await treasury.treasurerAddress()
    expect(address2).to.equal(treasurer.address)
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

  it('Fails to change treasurer', async () => {
    await expect(
      treasury.connect(alice).setTreasurer(alice.address)
    ).to.revertedWith('Ownable: caller is not the owner')
  })

  it('Locks treasury', async () => {
    await treasury.lockTreasury()
    await expect(
      treasury.setTreasurer(origin.address)
    ).to.revertedWith('Treasury: treasury is locked')
  })

  it('Fails to change treasurer when locked', async () => {
    await expect(
      treasury.setTreasurer(origin.address)
    ).to.revertedWith('Treasury: treasury is locked')
  })

  it('Transfers when locked', async () => {
    const transfer = ethers.utils.parseEther(`${Math.random() / 10}`)
    const b1 = await bob.getBalance()

    await treasury.connect(treasurer).transferValue(
      bob.address,
      transfer
    )

    const b2 = await bob.getBalance()

    expect(b1.add(transfer)).to.equal(b2)
  })
})
