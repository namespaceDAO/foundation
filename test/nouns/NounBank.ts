import { ethers } from 'hardhat'
import { expect } from 'chai'
import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import { Contract } from 'ethers'
import { formatEther } from 'ethers/lib/utils'

const parseEther = ethers.utils.parseEther

describe('NounBank', () => {
  let origin: SignerWithAddress
  let alice: SignerWithAddress
  let bob: SignerWithAddress
  let coin: Contract
  let oracle: Contract
  let descriptor: Contract
  const COIN_URI = 'https://nouns.express/_/api/tokens/{id}.json'
  const bps = 10000

  beforeEach(async () => {
    [origin, alice, bob] = await ethers.getSigners()
    const MockDescriptor = await ethers.getContractFactory('MockDescriptor')
    const NounBank = await ethers.getContractFactory('NounBank')
    const Oracle = await ethers.getContractFactory('DollarOracle')
    descriptor = await MockDescriptor.deploy(2)
    oracle = await Oracle.deploy()
    coin = await NounBank.deploy(oracle.address, COIN_URI, descriptor.address)
  })

  it('Create NOUN COIN with getters', async () => {
    const desc = await coin.descriptor()
    const ampl = await coin.ampl()
    expect(desc).to.equal(descriptor.address)
    expect(ampl).to.equal(20000)
  })

  it('Origin claim', async () => {
    const value = parseEther('1')
    const claim1 = parseEther('0.05')
    const claim2 = parseEther('0.06')
    const balance1 = await bob.getBalance()

    await coin.mint(alice.address, 0, 0, { value })
    await coin.originClaim(bob.address, claim1)
    const balance2 = await bob.getBalance()

    expect(balance1.add(claim1)).to.equal(balance2)
    await expect(
      coin.originClaim(bob.address, claim2)
    ).to.revertedWith('Claimable: origin claim is too large')
    await coin.originClaim(bob.address, claim1)
  })

  it('Fails to origin claim when too large', async () => {
    const value = parseEther('1')
    const claim1 = parseEther('0.1000000000001')
    await coin.mint(alice.address, 0, 0, { value })
    await expect(
      coin.originClaim(bob.address, claim1)
    ).to.revertedWith('Claimable: origin claim is too large')
  })

  const randomizeAmpl = async () => {
    const ampl = Math.floor((1 + Math.random()) * bps)
    await coin.setAmpl(ampl)
    return ampl
  }

  it('Mints 2 to 1', async () => {
    const value = parseEther('1')

    const ampl = await randomizeAmpl()
    const price = await coin.convertValueAtOraclePrice(value)

    await coin.mint(alice.address, 0, 0, { value })
    await coin.mint(bob.address, 1, 0, { value })

    const balanceA = await coin.balanceOf(alice.address, 0)
    const balanceB = await coin.balanceOf(bob.address, 1)

    expect(balanceA).to.equal(price)
    expect(balanceB).to.equal(price.mul(ampl).div(bps))
  })

  it('Mint price stays constant with equal coin supplies', async () => {
    const value = parseEther('1')

    await randomizeAmpl()
    const price = await coin.convertValueAtOraclePrice(value)

    await coin.mintBatch(alice.address, [0, 1], 0, { value })

    const balanceA = await coin.balanceOf(alice.address, 0)
    const balanceB = await coin.balanceOf(alice.address, 1)

    expect(balanceA).to.equal(price.div(2)) // initial mint
    expect(balanceB).to.equal(price.div(2))

    await randomizeAmpl()
    await coin.mint(alice.address, 0, 0, { value })

    const balanceA1 = await coin.balanceOf(alice.address, 0)
    const balanceE1 = price.add(price.div(2))
    expect(balanceA1).to.equal(balanceE1)
  })

  it('Mints more of one then the other', async () => {
    const value1 = parseEther('1')
    const value2 = parseEther('1')

    const price1 = await coin.convertValueAtOraclePrice(value1)
    const price2 = await coin.convertValueAtOraclePrice(value2)

    const ampl = await randomizeAmpl()
    await coin.mint(alice.address, 0, 0, { value: value1 })
    await coin.mint(alice.address, 1, 0, { value: value2 })

    const balanceA = await coin.balanceOf(alice.address, 0)
    const balanceB = await coin.balanceOf(alice.address, 1)

    expect(balanceA).to.equal(price1)
    expect(balanceB).to.equal(price2.mul(ampl).div(bps)) // discount because other was minted
  })

  it('Mints less of one then the other', async () => {
    const value1 = parseEther('0.5')
    const value2 = parseEther('1')

    const price1 = await coin.convertValueAtOraclePrice(value1)
    const price2 = await coin.convertValueAtOraclePrice(value2)

    const ampl = await randomizeAmpl()
    await coin.mint(alice.address, 0, 0, { value: value1 })
    await coin.mint(alice.address, 1, 0, { value: value2 })

    const balanceA = await coin.balanceOf(alice.address, 0)
    const balanceB = await coin.balanceOf(alice.address, 1)

    expect(balanceA).to.equal(price1)
    expect(balanceB).to.equal(price2.mul(ampl).div(bps)) // discount because other was minted
  })

  it('Fails to mint with incorrect number of heads', async () => {
    const value = parseEther('1')

    await expect(
      coin.mint(alice.address, 3, 0, { value })
    ).to.revertedWith('Not enough heads')
  })

  it('Empty conversion rates', async () => {
    const value = parseEther('1')
    const price = await coin.convertValueAtOraclePrice(value)

    const rate1 = await coin.conversionRate(0, value)
    const rate2 = await coin.conversionRate(1, value)
    expect(rate1).to.equal(price) // 1 = 1 at the oracle price
    expect(rate2).to.equal(price) // 1 = 1 at the oracle price
  })

  it('Fails to mint zero coins', async () => {
    const amount = parseEther('0')

    await expect(
      coin.mint(alice.address, 0, 0, { value: amount })
    ).to.revertedWith('Must mint some coins')

    await expect(
      coin.mintBatch(alice.address, [0, 1], 0, { value: amount })
    ).to.revertedWith('Must mint some coins')
  })
})

describe('NounBank game theory', () => {
  let origin: SignerWithAddress
  let alice: SignerWithAddress
  let bob: SignerWithAddress
  let coin: Contract
  let oracle: Contract
  let descriptor: Contract
  const COIN_URI = 'https://nouns.express/_/api/tokens/{id}.json'
  const bps = 10000

  before(async () => {
    [origin, alice, bob] = await ethers.getSigners()
    const MockDescriptor = await ethers.getContractFactory('MockDescriptor')
    const NounBank = await ethers.getContractFactory('NounBank')
    const Oracle = await ethers.getContractFactory('DollarOracle')
    oracle = await Oracle.deploy()
    descriptor = await MockDescriptor.deploy(200)
    coin = await NounBank.deploy(oracle.address, COIN_URI, descriptor.address)
  })

  const randomizeAmpl = async () => {
    const ampl = Math.floor((1 + Math.random()) * bps)
    await coin.setAmpl(ampl)
    return ampl
  }

  const fillArray = (count: number, fill: (idx: number) => number) => (
    new Array(count).fill(0).map((_, idx) => fill(idx))
  )

  it('Mints 2 to 1', async () => {
    // start with alice spending 50 ETH for 50 coins
    const valueA = parseEther('50')
    const coinsA = fillArray(50, (i) => i * 2)
    await coin.mintBatch(alice.address, coinsA, 0, { value: valueA })

    // start with bob then spends 50 ETH for 50 coins
    const valueB = parseEther('50')
    const coinsB = fillArray(50, (i) => i * 2 + 1)
    await coin.mintBatch(bob.address, coinsB, 0, { value: valueB })

    const value1a = parseEther('1')
    const value2a = parseEther('2')
    const price1a = await coin.convertValueAtOraclePrice(value1a)
    const price2a = await coin.convertValueAtOraclePrice(value2a)

    expect(await coin.balanceOf(alice.address, 0)).to.equal(price1a)
    expect(await coin.balanceOf(bob.address, 1)).to.equal(price2a)

    // alice again with 50 ETH for 50 coins
    await coin.mintBatch(alice.address, coinsA, 0, { value: valueA })

    // bob with 50 ETH for just coin 1, massive L
    await coin.mint(bob.address, 1, 0, { value: valueB })

    const balanceA = await coin.balanceOf(alice.address, 0)
    const balanceB = await coin.balanceOf(bob.address, 1)

    const value1 = parseEther('1.75')
    const value2 = parseEther('27')
    const price1 = await coin.convertValueAtOraclePrice(value1)
    const price2 = await coin.convertValueAtOraclePrice(value2)

    expect(balanceA).to.equal(price1)
    expect(balanceB).to.equal(price2)
  })
})
