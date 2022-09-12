import { ethers } from 'hardhat'
import { expect } from 'chai'
import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import { Contract } from 'ethers'

const parseEther = ethers.utils.parseEther

// TODO: test approval for all
// TODO: test allowances

describe('Ledger', () => {
  let origin: SignerWithAddress
  let alice: SignerWithAddress
  let bob: SignerWithAddress
  let ledger: Contract

  const BASE_URI = 'https://bankofnouns.com/_/api/tokens/{id}.json'

  it('Create coin ledger', async () => {
    [origin, alice, bob] = await ethers.getSigners()
    const Ledger = await ethers.getContractFactory('MockLedger')
    ledger = await Ledger.deploy(BASE_URI)

    const supply = await ledger.totalSupply()
    const balance = await ledger.treasuryBalance()
    const address = await ledger.treasurerAddress()
    const supply1 = await ledger.totalSupplyOf(1)
    const rate = await ledger.conversionRate(1, parseEther('1'))

    expect(supply).to.equal(0)
    expect(balance).to.equal(0)
    expect(supply1).to.equal(0)
    expect(rate).to.equal(1)
    expect(address).to.equal(origin.address)
  })

  it('Mint coins to Alice and Bob', async () => {
    const amountA = parseEther(`${Math.random()}`)
    const amountB = parseEther(`${Math.random()}`)

    await ledger.mint(alice.address, 1, 0, { value: amountA })
    await ledger.mint(bob.address, 2, 0, { value: amountB })

    const totalSupply = await ledger.totalSupply()

    const balanceA = await ledger.balanceOf(alice.address, 1)
    const balanceB = await ledger.balanceOf(bob.address, 2)

    const supplyA = await ledger.totalSupplyOf(1)
    const supplyB = await ledger.totalSupplyOf(2)

    expect(balanceA).to.equal(amountA)
    expect(balanceB).to.equal(amountB)
    expect(supplyA).to.equal(amountA)
    expect(supplyB).to.equal(amountB)
    expect(totalSupply).to.equal(supplyA.add(supplyB))
  })
})
