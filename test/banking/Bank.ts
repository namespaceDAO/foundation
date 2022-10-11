import { ethers } from 'hardhat'
import { expect } from 'chai'
import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import { Contract } from 'ethers'

const parseEther = ethers.utils.parseEther

describe('Bank', () => {
  let origin: SignerWithAddress
  let alice: SignerWithAddress
  let bob: SignerWithAddress
  let bank: Contract

  it('Create coin bank', async () => {
    [origin, alice, bob] = await ethers.getSigners()
    const Bank = await ethers.getContractFactory('MockBank')
    bank = await Bank.deploy('')

    const supply = await bank.totalSupply()
    const supply1 = await bank.totalSupplyOf(1)

    expect(supply).to.equal(0)
    expect(supply1).to.equal(0)
  })

  it('Mint coins to Alice and Bob', async () => {
    const amountA = parseEther(`${Math.random()}`)
    const amountB = parseEther(`${Math.random()}`)

    await bank.mint(alice.address, 1, { value: amountA })
    await bank.mint(bob.address, 2, { value: amountB })

    const totalSupply = await bank.totalSupply()

    const balanceA = await bank.balanceOf(alice.address, 1)
    const balanceB = await bank.balanceOf(bob.address, 2)

    const supplyA = await bank.totalSupplyOf(1)
    const supplyB = await bank.totalSupplyOf(2)

    expect(balanceA).to.equal(amountA)
    expect(balanceB).to.equal(amountB)
    expect(supplyA).to.equal(amountA)
    expect(supplyB).to.equal(amountB)
    expect(totalSupply).to.equal(supplyA.add(supplyB))
  })

  it('Approves Alice as spender', async () => {
    const amountA = parseEther('1')
    const amountB = parseEther(`${Math.random()}`)

    await bank.mint(alice.address, 1, { value: amountA })
    await bank.connect(alice).approve(bob.address, amountB, 1)

    const b1 = await bank.balanceOf(bob.address, 1)
    const a1 = await bank.allowance(alice.address, bob.address, 1)

    await bank.connect(bob).safeTransferFrom(
      alice.address, bob.address, 1, amountB, 0
    )

    const b2 = await bank.balanceOf(bob.address, 1)
    const a2 = await bank.allowance(alice.address, bob.address, 1)

    expect(b1.add(amountB)).to.equal(b2)
    expect(a1).to.equal(b2)
    expect(a2).to.equal(0)
  })

  // TODO: test approval for all, test allowances
})
