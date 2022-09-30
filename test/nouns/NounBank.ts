import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import { expect } from 'chai'
import { Contract } from 'ethers'
import { parseEther } from 'ethers/lib/utils'
import { ethers } from 'hardhat'

describe('NounBank', () => {
  let alice: SignerWithAddress
  let bob: SignerWithAddress
  let found: Contract
  let game: Contract
  let data: Contract
  let bank: Contract

  const BASE_URI = 'https://bankofnouns.com/_/api/tokens/{id}.json'

  beforeEach(async () => {
    [alice, bob] = await ethers.getSigners()

    const Found = await ethers.getContractFactory('Found')
    found = await Found.deploy()

    const NounGame = await ethers.getContractFactory('NounGame')
    game = await NounGame.deploy(found.address, BASE_URI)

    const NounData = await ethers.getContractFactory('NounData')
    data = NounData.attach(await game.data())

    const NounBank = await ethers.getContractFactory('NounBank')
    bank = NounBank.attach(await game.bank())
  })

  it('Creates bank', async () => {
    await data.addNoun({
      name: 'Rubber Ducky',
      creator: alice.address,
      pixels: 0
    })

    const day = await game.currentDay()

    const value = parseEther(`${Math.random()}`)
    await game.vote(alice.address, 1, { value })

    const balance1 = await bank.balanceOf(alice.address, 0)
    const noun1 = await game.coinToNoun(day)

    expect(value.mul(10)).to.equal(balance1)
    expect(noun1).to.equal(1)
  })
})
