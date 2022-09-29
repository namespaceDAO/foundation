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
    const supply1 = await ledger.totalSupplyOf(1)

    expect(supply).to.equal(0)
    expect(supply1).to.equal(0)
  })

  it('Mint coins to Alice and Bob', async () => {
    const amountA = parseEther(`${Math.random()}`)
    const amountB = parseEther(`${Math.random()}`)

    await ledger.mint(alice.address, 1, { value: amountA })
    await ledger.mint(bob.address, 2, { value: amountB })

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

  it('Approves Alice as spender', async () => {
    const amountA = parseEther('1')
    const amountB = parseEther(`${Math.random()}`)

    await ledger.mint(alice.address, 1, { value: amountA })
    await ledger.connect(alice).approve(bob.address, amountB, 1)

    const b1 = await ledger.balanceOf(bob.address, 1)
    const a1 = await ledger.allowance(alice.address, bob.address, 1)

    await ledger.connect(bob).safeTransferFrom(
      alice.address, bob.address, 1, amountB, 0
    )

    const b2 = await ledger.balanceOf(bob.address, 1)
    const a2 = await ledger.allowance(alice.address, bob.address, 1)

    expect(b1.add(amountB)).to.equal(b2)
    expect(a1).to.equal(b2)
    expect(a2).to.equal(0)
  })
})
