import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import { expect } from 'chai'
import { BigNumber, Contract } from 'ethers'
import { parseEther } from 'ethers/lib/utils'
import { ethers } from 'hardhat'

describe('NounMove', () => {
  let alice: SignerWithAddress
  let bob: SignerWithAddress
  let found: Contract
  let data: Contract
  let game: Contract
  let bank: Contract

  beforeEach(async () => {
    [alice, bob] = await ethers.getSigners()

    const Found = await ethers.getContractFactory('Found')
    found = await Found.deploy()

    const NounData = await ethers.getContractFactory('NounData')
    data = await NounData.deploy()

    const NounMove = await ethers.getContractFactory('NounMove')
    game = await NounMove.deploy(found.address, data.address)

    const NounBank = await ethers.getContractFactory('NounBank')
    bank = NounBank.attach(await game.bank())

    const value = parseEther('100')
    await found.connect(alice).approve(game.address, value)
    await found.connect(alice).mint(alice.address, { value })
    await found.connect(bob).approve(game.address, value)
    await found.connect(bob).mint(alice.address, { value })
  })

  it('Creates game', async () => {
    const day = await data.currentDay()
    expect(day).to.equal(1)
  })

  it('Submits noun', async () => {
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

    const day = await data.currentDay()

    const value = parseEther(`${Math.random()}`)
    await game.connect(alice).vote(alice.address, alice.address, 1, value)

    const balance1 = await bank.balanceOf(alice.address, 1)
    const noun1 = await game.coinToNoun(day)

    expect(value.mul(10)).to.equal(balance1)
    expect(noun1).to.equal(1)
  })

  it('Votes on noun', async () => {
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

    const day = await data.currentDay()

    const value = parseEther(`${Math.random()}`)
    await game.connect(alice).vote(alice.address, alice.address, 1, value)

    const balance1 = await bank.balanceOf(alice.address, 1)
    const noun1 = await game.coinToNoun(day)

    expect(value.mul(10)).to.equal(balance1)
    expect(noun1).to.equal(1)
  })

  it('Mints noun', async () => {
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
    await game.connect(alice).mint(alice.address, alice.address, 1, value)

    const balance1 = await bank.balanceOf(alice.address, 1)

    expect(value).to.equal(balance1)
  })
})
