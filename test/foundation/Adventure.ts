import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import { expect } from 'chai'
import { Contract } from 'ethers'
import { parseEther } from 'ethers/lib/utils'
import { ethers } from 'hardhat'

const ONE_DAY = 3600 * 24

describe('Adventure', () => {
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

    const Adventure = await ethers.getContractFactory('Adventure')
    venture = await Adventure.deploy(
      'FOUND NOTE',
      'FOUND NOTE',
      found.address
    )

    const Capitalism = await ethers.getContractFactory('Capitalism')
    capitalism = await Capitalism.attach(await venture.capitalism())
  })

  it('Creates Adventure', async () => {
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

  it('Ends stake sending back ETH and FOUND', async () => {
    const params = createStake()
    const value = parseEther('10')

    await found.connect(alice).mint(alice.address, { value })
    await found.connect(alice).approve(venture.address, value)
    await venture.connect(alice).startStake(params)

    await origin.sendTransaction({
      to: venture.address,
      value: parseEther('10')
    })

    const b1 = await bob.getBalance()
    const a1 = await found.balanceOf(alice.address)
    const stakeId = await capitalism.stakeCount()

    await venture.connect(alice).endStake(bob.address, stakeId)

    const b2 = await bob.getBalance()
    const a2 = await found.balanceOf(alice.address)

    expect(a1.add(params.amount)).to.equal(a2)
  })
})
