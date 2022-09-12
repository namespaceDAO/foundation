import { ethers } from 'hardhat'
import { expect } from 'chai'
import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import { Contract } from 'ethers'

const parseEther = ethers.utils.parseEther

describe('Bank', () => {
  let origin: SignerWithAddress
  let alice: SignerWithAddress
  let bob: SignerWithAddress
  let reserve: Contract
  let bank: Contract
  let coin1: Contract

  const BASE_URI = 'https://bankofnouns.com/_/api/tokens/{id}.json'

  before(async () => {
    [origin, alice, bob] = await ethers.getSigners()
    const Bank = await ethers.getContractFactory('MockBank')
    bank = await Bank.deploy(BASE_URI)
  })

  it('Deploy token', async () => {
    await bank.deployToken(1, 'COIN1')
    const address = await bank.canonicalToken(1)

    const Token = await ethers.getContractFactory('Token')
    coin1 = await Token.attach(address)

    expect(await coin1.name()).to.equal('COIN1')
  })

  it('Transfers coin', async () => {
    const amountA = parseEther(`${Math.random()}`)
    await bank.mint(alice.address, 1, 0, { value: amountA })

    const balanceA1 = await coin1.balanceOf(alice.address)
    await coin1.connect(alice).transfer(bob.address, amountA)

    const balanceA = await coin1.balanceOf(alice.address)
    const balanceB = await coin1.balanceOf(bob.address)

    expect(balanceA).to.equal(0)
    expect(balanceB).to.equal(balanceA1)
  })
})
