import { ethers } from 'hardhat'
import { expect } from 'chai'
import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import { Contract } from 'ethers'
import { parseEther } from 'ethers/lib/utils'
import { add } from 'date-fns'
import { dateToTime, getCurrentDateTime } from '../../../utils'

describe('PublicForum', () => {
  let origin: SignerWithAddress
  let alice: SignerWithAddress
  let found: Contract
  let govt: Contract

  before(async () => {
    [origin, alice] = await ethers.getSigners()
    const Found = await ethers.getContractFactory('Found')
    const Government = await ethers.getContractFactory('Government')
    found = await Found.deploy()
    govt = await Government.deploy(found.address)

    await found.setTreasurer(govt.address, true)
    await found.mint(origin.address, { value: parseEther('100') })
  })

  it('Successfully creates prop', async () => {
    const { date, time } = await getCurrentDateTime()
    const expiresAt = dateToTime(add(date, { days: 7 + Math.random() * 7 }))

    const text = 'hello world'
    const found = parseEther(`${Math.random()}`)
    const value = parseEther(`${Math.random()}`)
    const note = { payee: alice.address, found, value }
    await govt.createProp({ text, note, expiresAt })

    const count = await govt.propCount()
    const prop = await govt.getProp(1)

    expect(count).to.equal(1)
    expect(prop.id).to.equal(1)
    expect(prop.text).to.equal('hello world')
    expect(prop.author).to.equal(origin.address)
    expect(prop.createdAt).to.greaterThanOrEqual(time)
    expect(prop.expiresAt).to.equal(expiresAt)
    expect(prop.fund.id).to.equal(1)
    expect(prop.fund.payee).to.equal(alice.address)
    expect(prop.fund.found).to.equal(found)
    expect(prop.fund.value).to.equal(value)
  })

  it('Fails to create prop that expires in 6 hours', async () => {
    const { date } = await getCurrentDateTime()
    await expect(
      govt.createProp({
        text: 'hello world',
        expiresAt: dateToTime(add(date, { hours: 6 })),
        note: {
          payee: alice.address,
          found: parseEther('1'),
          value: parseEther('1')
        }
      })
    ).to.rejectedWith('Proposal expiration must be at least 1 day in the future')
  })

  it('Fails to create prop that expires in 2049 weeks', async () => {
    const { date } = await getCurrentDateTime()
    await expect(
      govt.createProp({
        text: 'hello world',
        expiresAt: dateToTime(add(date, { days: 2049 * 7 })),
        note: {
          payee: alice.address,
          found: parseEther('1'),
          value: parseEther('1')
        }
      })
    ).to.rejectedWith('Proposal window is too long')
  })

  it('Fails to create prop that expires at the beginning of time', async () => {
    await expect(
      govt.createProp({
        text: 'hello world',
        expiresAt: 0,
        note: {
          payee: alice.address,
          found: parseEther('1'),
          value: parseEther('1')
        }
      })
    ).to.rejectedWith('Proposal expiration must be at least 1 day in the future')
  })

  it('Fails to create prop without a funding request', async () => {
    const { date } = await getCurrentDateTime()
    await expect(
      govt.createProp({
        text: 'hello world',
        expiresAt: dateToTime(add(date, { days: 100 })),
        note: {
          payee: alice.address,
          found: parseEther('0'),
          value: parseEther('0')
        }
      })
    ).to.rejectedWith('You must request some funding')
  })

  it('Fails to get a prop that doesn\'t exist', async () => {
    const count = await govt.propCount()
    await expect(
      govt.getProp(count.add(100))
    ).to.rejectedWith('Prop not found')
  })
})
