import { ethers } from 'hardhat'
import { expect } from 'chai'
import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import { Contract } from 'ethers'
import { parseEther } from 'ethers/lib/utils'
import { add } from 'date-fns'

const dateToTime = (date: Date): number => Math.floor(date.getTime() / 1000)

describe('Government', () => {
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
  })

  it('Creates govt', async () => {
    const currentWeek = await govt.currentWeek()
    const inflationRate = await govt.inflationRate()
    const weeklyLimit = await govt.weeklyLimit()

    expect(currentWeek).to.greaterThan(0)
    expect(inflationRate).to.equal(20)
    expect(weeklyLimit).to.equal(52)
  })

  it('Creates prop', async () => {
    const date = add(new Date(), { days: 1 })
    const expiresAt = dateToTime(add(date, { days: 7 + Math.random() * 7 }))
    const createdAt = dateToTime(date)

    await ethers.provider.send('evm_mine', [createdAt])
    await govt.createProp({
      text: 'hello world',
      expiresAt,
      note: {
        payee: alice.address,
        found: parseEther('1'),
        value: parseEther('1')
      }
    })

    const count = await govt.propCount()
    const prop = await govt.getProp(0)
    const currentWeek = await govt.currentWeek()

    expect(count).to.equal(1)
    expect(prop.id).to.equal(1)
    expect(prop.week).to.equal(currentWeek)
    expect(prop.text).to.equal('hello world')
    expect(prop.creator).to.equal(origin.address)
    expect(prop.createdAt).to.greaterThanOrEqual(createdAt)
    expect(prop.expiresAt).to.equal(expiresAt)
  })
})
