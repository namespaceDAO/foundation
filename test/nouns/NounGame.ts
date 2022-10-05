import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import { expect } from 'chai'
import { BigNumber, Contract } from 'ethers'
import { parseEther } from 'ethers/lib/utils'
import { ethers } from 'hardhat'

describe('NounGame', () => {
  let alice: SignerWithAddress
  let bob: SignerWithAddress
  let found: Contract
  let game: Contract
  let data: Contract
  let bank: Contract

  const BASE_URI = 'https://bankofnouns.com/_/api/tokens/{id}.json'

  beforeEach(async () => {
    [alice, bob] = await ethers.getSigners()

    const Found = await ethers.getContractFactory('Found')
    found = await Found.deploy()

    const NounGame = await ethers.getContractFactory('NounGame')
    game = await NounGame.deploy(found.address, BASE_URI)

    const NounBank = await ethers.getContractFactory('NounBank')
    bank = NounBank.attach(await game.bank())

    const value = parseEther('100')
    await found.connect(alice).approve(game.address, value)
    await found.connect(alice).mint(alice.address, { value })
    await found.connect(bob).approve(game.address, value)
    await found.connect(bob).mint(alice.address, { value })
  })

  it('Creates game', async () => {
    const day = await game.currentDay()
    expect(day).to.equal(1)
  })

  it('Submits noun', async () => {
    await game.submitNoun({
      name: 'Rubber Ducky',
      creator: alice.address,
      traits: [],
      shapes: [
        BigNumber.from('0x0000fffffafafaff'),
        BigNumber.from('0x32236e5dff00ffff'),
        BigNumber.from('0x50500f0fffff00ff')
      ]
    })

    const day = await game.currentDay()

    const value = parseEther(`${Math.random()}`)
    await game.connect(alice).vote(alice.address, alice.address, 1, value)

    const balance1 = await bank.balanceOf(alice.address, 1)
    const noun1 = await game.coinToNoun(day)

    expect(value.mul(10)).to.equal(balance1)
    expect(noun1.id).to.equal(1)
  })

  it('Votes on noun', async () => {
    await game.submitNoun({
      name: 'Rubber Ducky',
      creator: alice.address,
      traits: [],
      shapes: [
        BigNumber.from('0x0000fffffafafaff'),
        BigNumber.from('0x32236e5dff00ffff'),
        BigNumber.from('0x50500f0fffff00ff')
      ]
    })

    const day = await game.currentDay()

    const value = parseEther(`${Math.random()}`)
    await game.connect(alice).vote(alice.address, alice.address, 1, value)

    const balance1 = await bank.balanceOf(alice.address, 1)
    const noun1 = await game.coinToNoun(day)

    expect(value.mul(10)).to.equal(balance1)
    expect(noun1.id).to.equal(1)
  })

  it('Mints noun', async () => {
    await game.submitNoun({
      name: 'Rubber Ducky',
      creator: alice.address,
      traits: [],
      shapes: [
        BigNumber.from('0x0000fffffafafaff'),
        BigNumber.from('0x32236e5dff00ffff'),
        BigNumber.from('0x50500f0fffff00ff')
      ]
    })

    const value = parseEther(`${Math.random()}`)
    await game.connect(alice).mint(alice.address, alice.address, 1, value)

    const balance1 = await bank.balanceOf(alice.address, 1)

    expect(value).to.equal(balance1)
  })

  const createStake = (): any => {
    const idea = Math.floor(Math.random() * 100)
    const amount = parseEther(`${Math.random()}`)
    const startedAt = getNow()
    const duration = ONE_DAY * Math.floor(7 * Math.random() + 2)
    const expiresAt = startedAt + duration
    const founder = alice.address
    const owner = alice.address

    return { amount, expiresAt, startedAt, founder, owner, idea }
  }

  it('Starts stake with FOUND', async () => {
    const value = parseEther('10')

    await found.connect(alice).mint(alice.address, { value })
    await found.connect(alice).approve(venture.address, value)

    const params = createStake()
    await venture.connect(alice).startStake(params)

    const stakeId = await capitalism.stakeCount()
    const totalShares = await venture.totalShares()
    const stake = await capitalism.getStake(stakeId)
    const shares = await venture.stakeShares(stakeId)
    const stakeOwner = await capitalism.ownerOf(stakeId)

    expect(shares).to.equal(totalShares)
    expect(shares).to.greaterThan(0)

    expect(stake.id).to.equal(stakeId)
    expect(stake.idea).to.equal(params.idea)
    expect(stake.amount).to.equal(params.amount)
    expect(stake.expiresAt).to.equal(params.expiresAt)
    expect(stake.startedAt).to.greaterThanOrEqual(params.startedAt)
    expect(stake.endedAt).to.equal(0)
    expect(stake.founder).to.equal(params.founder)
    expect(stake.redeemer).to.equal(ethers.constants.AddressZero)
    expect(stakeOwner).to.equal(params.owner)
  })

  it('Ends stake sending FOUND', async () => {
    const params = createStake()
    const value = parseEther('10')

    await found.connect(alice).mint(alice.address, { value })
    await found.connect(alice).approve(venture.address, value)
    await venture.connect(alice).startStake(params)

    await found.connect(origin).mint(origin.address, { value })
    await found.connect(origin).transfer(venture.address, value)

    const a1 = await found.balanceOf(alice.address)
    const stakeId = await capitalism.stakeCount()
    await venture.connect(alice).endStake(alice.address, stakeId)
    const a2 = await found.balanceOf(alice.address)

    expect(value.sub(a1)).to.equal(params.amount)
    expect(a2).to.equal(value.mul(2))
  })
})
