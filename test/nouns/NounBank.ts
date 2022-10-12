import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import { expect } from 'chai'
import { BigNumber, Contract } from 'ethers'
import { parseEther } from 'ethers/lib/utils'
import { ethers } from 'hardhat'

describe('NounBank', () => {
  let alice: SignerWithAddress
  let bob: SignerWithAddress
  let found: Contract

  let bank: Contract
  let mint: Contract
  let data: Contract

  let duck: any

  beforeEach(async () => {
    [alice, bob] = await ethers.getSigners()

    const Found = await ethers.getContractFactory('Found')
    found = await Found.deploy()

    const NounData = await ethers.getContractFactory('NounData')
    data = await NounData.deploy()

    const NounBank = await ethers.getContractFactory('NounBank')
    bank = await NounBank.deploy(found.address, data.address)

    const NounMint = await ethers.getContractFactory('NounMint')
    mint = NounMint.attach(await bank.bank())

    const value = parseEther('100')
    await found.connect(alice).approve(bank.address, value)
    await found.connect(alice).mint(alice.address, { value })
    await found.connect(bob).approve(bank.address, value)
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

  it('Creates bank', async () => {
    const day = await bank.currentDay()
    const c = await bank.cash()
    const d = await bank.data()
    const b = await bank.bank()

    expect(day).to.equal(1)
    expect(c).to.equal(found.address)
    expect(d).to.equal(data.address)
    expect(b).to.equal(mint.address)
  })

  // TODO: fully test this function with failure cases
  it('Mints noun', async () => {
    const value = parseEther(`${Math.random()}`)
    await bank.connect(alice).mint(alice.address, alice.address, 1, value)
    const balance1 = await mint.balanceOf(alice.address, 1)
    expect(value).to.equal(balance1)
  })

  // TODO: fully test this function with failure cases
  it('Votes on noun', async () => {
    const day = await bank.currentDay()

    const value = parseEther(`${Math.random()}`)
    await bank.connect(alice).vote(alice.address, alice.address, day, value)

    const balance1 = await mint.balanceOf(alice.address, day)
    const noun1 = await bank.coinToNoun(day)

    expect(value.mul(10)).to.equal(balance1)
    expect(noun1).to.equal(day)
  })

  // TODO: fully test this function with failure cases
  it('Stakes on noun', async () => {
    const value = parseEther(`${Math.random()}`)
    const startedAt = Math.floor(new Date().getTime() / 1000)
    const expiresAt = startedAt + 3600 * 25

    await bank.connect(alice).stake({
      govt: ethers.constants.AddressZero,
      to: alice.address,
      noun: duck.id,
      found: value,
      expiresAt
    })

    const count = await bank.stakeCount()
    const stake = await bank.getStake(count)

    expect(stake.id).to.equal(count)
    expect(stake.noun).to.equal(duck.id)
    expect(stake.found).to.equal(value)
    expect(stake.expiresAt).to.equal(expiresAt)
    expect(stake.endedAt).to.equal(0)
    expect(stake.startedAt).to.greaterThanOrEqual(startedAt)
  })

  // TODO: test token data
  // TODO: test share data
  // TODO: test govt funding

  it('Burns stake', async () => {
    const value = parseEther(`${Math.random()}`)
    const startedAt = Math.floor(new Date().getTime() / 1000)
    const expiresAt = startedAt + 3600 * 25

    await bank.connect(alice).stake({
      govt: ethers.constants.AddressZero,
      to: alice.address,
      noun: duck.id,
      found: value,
      expiresAt
    })

    const stakeId = await bank.stakeCount()

    await bank.connect(alice).burn(alice.address, stakeId)
  })

  it('Shares correctly', async () => {
    const value1 = parseEther(`${Math.random()}`)
    const value2 = parseEther(`${Math.random()}`)
    const startedAt = Math.floor(new Date().getTime() / 1000)
    const expiresAt = startedAt + 3600 * 25

    const balance = parseEther('10')
    await found.connect(alice).transfer(bank.address, balance)
    await bank.connect(alice).stake({
      govt: ethers.constants.AddressZero,
      to: alice.address,
      noun: duck.id,
      found: value1,
      expiresAt
    })

    const shares1 = await bank.getShares(1)
    const total1 = await bank.totalShares()
    const [earnings1, penalty1] = await bank.calculatePayout(1, expiresAt)

    expect(shares1).to.equal(value1)
    expect(total1).to.equal(value1)
    expect(earnings1).to.equal(balance)
    expect(penalty1).to.equal(0)

    await bank.connect(alice).stake({
      govt: ethers.constants.AddressZero,
      to: alice.address,
      noun: duck.id,
      found: value2,
      expiresAt
    })

    const late2 = 3600 * 24 * 21
    const shares2 = await bank.getShares(2)
    const total2 = await bank.totalShares()
    const [earnings2, penalty2] = await bank.calculatePayout(2, expiresAt + late2)

    expect(shares2).to.equal(value2)
    expect(total2).to.equal(total1.add(shares2))
    expect(earnings2).to.equal(balance.mul(shares2).div(total2))
    expect(penalty2).to.greaterThan(0) // TODO
  })

  it('Claims coin stake', async () => {
    const day = await bank.currentDay()

    const value = parseEther(`${Math.random()}`)
    await bank.connect(alice).vote(alice.address, alice.address, day, value)

    const time = Math.floor(new Date().getTime() / 1000) + 3600 * 24
    await ethers.provider.send('evm_mine', [time])

    await bank.connect(alice).claim(alice.address, day, value)
  })
})
