import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import { expect } from 'chai'
import { Contract } from 'ethers'
import { parseEther } from 'ethers/lib/utils'
import { ethers } from 'hardhat'

const ONE_DAY = 3600 * 24

describe('Venture', () => {
  let origin: SignerWithAddress
  let alice: SignerWithAddress
  let bob: SignerWithAddress
  let found: Contract
  let venture: Contract
  let capitalism: Contract

  const getNow = (): number => Math.floor(new Date().getTime() / 1000)

  beforeEach(async () => {
    [origin, alice, bob] = await ethers.getSigners()
    const Found = await ethers.getContractFactory('Found')
    found = await Found.deploy()

    const Desc = await ethers.getContractFactory('NounDescriptor')
    const desc = await Desc.deploy()

    const Venture = await ethers.getContractFactory('Venture')
    venture = await Venture.deploy(
      'FOUND NOTE',
      'FOUND NOTE',
      desc.address,
      found.address
    )

    const Capitalism = await ethers.getContractFactory('Capitalism')
    capitalism = await Capitalism.attach(await venture.capitalism())
  })

  it('Creates Venture', async () => {
    const name = await capitalism.name()
    const symbol = await capitalism.symbol()

    expect(name).to.equal('FOUND NOTE')
    expect(symbol).to.equal('FOUND NOTE')

    await expect(capitalism.startStake({
      idea: 0,
      amount: 0,
      expiresAt: 0,
      founder: bob.address,
      owner: bob.address
    })).to.rejectedWith('Caller is not the admin')
  })

  it('Starts stake', async () => {
    const value = parseEther('10')

    await found.connect(alice).mint(alice.address, { value })
    await found.connect(alice).approve(venture.address, value)

    await venture.connect(alice).startStake({
      amount: parseEther('1'),
      expiresAt: getNow() + 3600 * 24 * 7,
      founder: alice.address,
      owner: alice.address,
      idea: 0
    })
  })

  it('Ends stake', async () => {
    const value = parseEther('10')

    await found.connect(alice).mint(alice.address, { value })
    await found.connect(alice).approve(venture.address, value)

    const idea = Math.floor(Math.random() * 100)
    const amount = parseEther(`${Math.random()}`)
    const startedAt = getNow()
    const duration = ONE_DAY * Math.floor(7 * Math.random() + 1)
    const expiresAt = startedAt + duration
    const founder = alice.address
    const owner = bob.address

    const params = { amount, expiresAt, founder, owner, idea }
    await venture.connect(alice).startStake(params)

    const stakeId = await capitalism.stakeCount()
    const stake = await capitalism.getStake(stakeId)
    const stakeOwner = await capitalism.ownerOf(stakeId)

    expect(stake.id).to.equal(stakeId)
    expect(stake.idea).to.equal(idea)
    expect(stake.amount).to.equal(amount)
    expect(stake.expiresAt).to.equal(expiresAt)
    expect(stake.startedAt).to.greaterThanOrEqual(startedAt)
    expect(stake.endedAt).to.equal(0)
    expect(stake.founder).to.equal(founder)
    expect(stake.redeemer).to.equal(ethers.constants.AddressZero)
    expect(stakeOwner).to.equal(owner)
  })
})
