import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import { expect } from 'chai'
import { BigNumber, Contract } from 'ethers'
import { parseEther } from 'ethers/lib/utils'
import { ethers } from 'hardhat'

describe('NounBank', () => {
  let alice: SignerWithAddress
  let bob: SignerWithAddress
  let found: Contract
  let data: Contract
  let game: Contract
  let bank: Contract
  let duck: any

  beforeEach(async () => {
    [alice, bob] = await ethers.getSigners()

    const Found = await ethers.getContractFactory('Found')
    found = await Found.deploy()

    const NounData = await ethers.getContractFactory('NounData')
    data = await NounData.deploy()

    const NounBank = await ethers.getContractFactory('NounBank')
    game = await NounBank.deploy(found.address, data.address)

    const NounMint = await ethers.getContractFactory('NounMint')
    bank = NounMint.attach(await game.bank())

    const value = parseEther('100')
    await found.connect(alice).approve(game.address, value)
    await found.connect(alice).mint(alice.address, { value })
    await found.connect(bob).approve(game.address, value)
    await found.connect(bob).mint(alice.address, { value })

    await data.submitNoun({
      name: 'Rubber Ducky',
      creator: alice.address,
      traits: [],
      shapes: [
        BigNumber.from('0x0000fffffafafaff'),
        BigNumber.from('0x32236e5dff00ffff'),
        BigNumber.from('0x50500f0fffff00ff')
      ]
    })

    duck = await data.getNoun(1)
  })

  it('Creates game', async () => {
    const day = await data.currentDay()
    expect(day).to.equal(1)
  })

  it('Submits noun', async () => {
    await data.submitNoun({
      name: 'Rubber Ducky',
      creator: alice.address,
      traits: [],
      shapes: [
        BigNumber.from('0x0000fffffafafaff'),
        BigNumber.from('0x32236e5dff00ffff'),
        BigNumber.from('0x50500f0fffff00ff')
      ]
    })
    const count = await data.nounCount()
    const noun = await data.getNoun(count)

    const day = await data.currentDay()

    const value = parseEther(`${Math.random()}`)

    await game.connect(alice).vote(
      alice.address, alice.address, noun.id, value
    )

    const balance1 = await bank.balanceOf(alice.address, day)
    const noun1 = await game.coinToNoun(day)

    expect(value.mul(10)).to.equal(balance1)
    expect(noun1).to.equal(count)
  })

  it('Votes on noun', async () => {
    const day = await data.currentDay()

    const value = parseEther(`${Math.random()}`)
    await game.connect(alice).vote(alice.address, alice.address, day, value)

    const balance1 = await bank.balanceOf(alice.address, day)
    const noun1 = await game.coinToNoun(day)

    expect(value.mul(10)).to.equal(balance1)
    expect(noun1).to.equal(day)
  })

  it('Mints noun', async () => {
    const value = parseEther(`${Math.random()}`)
    await game.connect(alice).mint(alice.address, alice.address, 1, value)

    const balance1 = await bank.balanceOf(alice.address, 1)

    expect(value).to.equal(balance1)
  })

  it('Stakes on noun', async () => {
    const value = parseEther(`${Math.random()}`)
    const startedAt = Math.floor(new Date().getTime() / 1000)
    const expiresAt = startedAt + 3600 * 25

    await game.connect(alice).stake({
      to: alice.address,
      nounId: duck.id,
      amount: value,
      expiresAt
    })

    const count = await game.stakeCount()
    const stake = await game.getStake(count)

    expect(stake.id).to.equal(count)
    expect(stake.nounId).to.equal(duck.id)
    expect(stake.amount).to.equal(value)
    expect(stake.expiresAt).to.equal(expiresAt)
    expect(stake.endedAt).to.equal(0)
    expect(stake.startedAt).to.greaterThanOrEqual(startedAt)
  })

  it('Ends stake', async () => {
    const value = parseEther(`${Math.random()}`)
    const startedAt = Math.floor(new Date().getTime() / 1000)
    const expiresAt = startedAt + 3600 * 25

    await game.connect(alice).stake({
      to: alice.address,
      nounId: duck.id,
      amount: value,
      expiresAt
    })

    const stakeId = await game.stakeCount()

    await game.connect(alice).burn(alice.address, stakeId)
  })
})
