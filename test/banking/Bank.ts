import { ethers } from 'hardhat'
import { expect } from 'chai'
import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import { Contract } from 'ethers'
import { Coin__factory } from '../../typechain-types'

describe('Bank', () => {
  let origin: SignerWithAddress
  let alice: SignerWithAddress
  let bob: SignerWithAddress
  let bank: Contract
  let Coin: Coin__factory

  const BASE_URI = 'https://bankofnouns.com/_/api/tokens/{id}.json'

  beforeEach(async () => {
    [origin, alice, bob] = await ethers.getSigners()
    const Bank = await ethers.getContractFactory('MockBank')
    Coin = await ethers.getContractFactory('Coin')
    bank = await Bank.deploy(BASE_URI)
  })

  it('Create bank', async () => {
    const supply = await bank.totalSupply()
    const supply1 = await bank.totalSupplyOf(1)

    expect(supply).to.equal(0)
    expect(supply1).to.equal(0)
  })

  it('Deploys coin', async () => {
    await bank.deployCoin(1, 'HI')
    const a1 = await bank.addressOf(1)

    const coin1 = Coin.attach(a1)
    const symbol1 = await coin1.symbol()

    expect(symbol1).to.equal('HI')
  })
})
