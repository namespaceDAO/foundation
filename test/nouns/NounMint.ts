import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import { expect } from 'chai'
import { BigNumber, Contract } from 'ethers'
import { parseEther } from 'ethers/lib/utils'
import { ethers } from 'hardhat'

describe('NounMint', () => {
  let alice: SignerWithAddress
  let bob: SignerWithAddress
  let found: Contract
  let data: Contract
  let mint: Contract
  let bank: Contract

  beforeEach(async () => {
    [alice, bob] = await ethers.getSigners()

    const NounData = await ethers.getContractFactory('NounData')
    data = await NounData.deploy()

    const NounBank = await ethers.getContractFactory('NounBank')
    bank = await NounBank.deploy(data.address)

    const NounMint = await ethers.getContractFactory('NounMint')
    mint = NounMint.attach(await bank.bank())

    const Found = await ethers.getContractFactory('Found')
    found = await Found.attach(await bank.found())

    const value = parseEther('100')
    await found.connect(alice).approve(bank.address, value)
    await found.connect(alice).mint(alice.address, { value })
  })

  it('Deploys coin', async () => {
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

    const value = parseEther(`${Math.random()}`)
    await bank.connect(alice).vote(alice.address, alice.address, 1, value)

    await mint.deployCoin(1)
    const a1 = await mint.addressOf(1)

    const Coin = await ethers.getContractFactory('Coin')
    const coin1 = Coin.attach(a1)
    const name1 = await coin1.name()
    const symbol1 = await coin1.symbol()

    expect(name1).to.equal('Rubber Ducky')
    expect(symbol1).to.equal('NOUN COIN 1')
  })
})
