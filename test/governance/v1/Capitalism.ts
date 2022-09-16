import { ethers } from 'hardhat'
import { expect } from 'chai'
import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import { Contract } from 'ethers'
import { parseEther } from 'ethers/lib/utils'
import { add } from 'date-fns'
import { dateToTime, getCurrentDateTime } from '../../utils'

describe('Capitalism', () => {
  const seed = parseEther('100')
  let origin: SignerWithAddress
  let alice: SignerWithAddress
  let bob: SignerWithAddress
  let found: Contract
  let govt: Contract

  before(async () => {
    [origin, alice, bob] = await ethers.getSigners()
    const Found = await ethers.getContractFactory('Found')
    const Government = await ethers.getContractFactory('Government')
    found = await Found.deploy()
    govt = await Government.deploy(found.address)

    // seed the treasury with some ether and found
    await found.mint(origin.address, { value: seed })
    await found.setTreasurer(govt.address, true)
  })

  it('Creates govt', async () => {
    const currentDay = await govt.currentDay()
    const inflationRate = await govt.inflationRate()
    const budgetRate = await govt.budgetRate()

    expect(currentDay).to.greaterThan(0)
    expect(inflationRate).to.equal(20)
    expect(budgetRate).to.equal(52)
  })

  it('Successfully starts stake', async () => {
    const { date, time } = await getCurrentDateTime()
    const duration = { days: 7 + Math.random() * 7 }
    const expiresAt = dateToTime(add(date, duration))

    const text = 'hello world'
    const note = {
      payee: alice.address,
      found: parseEther(`${Math.random()}`),
      value: parseEther(`${Math.random()}`)
    }

    const prop = { text, note, expiresAt }
    await govt.connect(alice).createProp(prop)

    const value = parseEther('1')
    await found.mint(alice.address, { value })
    const count1 = await govt.stakeCount()

    const params = {
      prop: 1,
      amount: parseEther(`${Math.random()}`),
      reason: ''
    }

    await govt.connect(alice).createStake(params)

    const count2 = await govt.stakeCount()
    const stake = await govt.getStake(1)

    expect(count1.add(1)).to.equal(count2)
    expect(stake.id).to.equal(count2)
    expect(stake.prop).to.equal(params.prop)
    expect(stake.staker).to.equal(alice.address)
    expect(stake.amount).to.equal(params.amount)
    expect(stake.createdAt).to.greaterThanOrEqual(time)
    expect(stake.expiresAt).to.equal(expiresAt)
    expect(stake.totalStaked).to.equal(0)
    expect(stake.totalSupply).to.equal(seed.mul(2).add(value.mul(2)))

    const currentDay = await govt.currentDay()
    const stakedToday = await govt.stakedPerDay(currentDay)
    const stakedOnProp = await govt.stakedOnProp(stake.prop)

    expect(stakedToday).to.equal(stake.amount)
    expect(stakedOnProp).to.equal(stake.amount)

    const owner = await govt.ownerOf(stake.id)
    expect(owner).to.equal(alice.address)
  })

  it('Fails to stake without FOUND', async () => {
    await expect(
      govt.createStake({ prop: 1, amount: parseEther('0'), reason: '' })
    ).to.rejectedWith('Must stake some FOUND')

    await expect(
      govt.connect(bob).createStake({ prop: 1, amount: parseEther('1'), reason: '' })
    ).to.rejectedWith('ERC20: transfer amount exceeds balance')
  })

  it('Starts prop', async () => {
    await govt.startProp(1)
  })

  it('Ends stake', async () => {
    const { date } = await getCurrentDateTime()
    const endingAt = dateToTime(add(date, { days: 20 }))

    await ethers.provider.send('evm_mine', [endingAt])

    await govt.connect(alice).endStake(1)
  })
})
