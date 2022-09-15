import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import { expect } from 'chai'
import { Contract } from 'ethers'
import { ethers } from 'hardhat'

describe('Arch', () => {
  let alice: SignerWithAddress
  let bob: SignerWithAddress
  let arch: Contract
  const secondsPerWeek = 7 * 24 * 60 * 60

  before(async () => {
    [alice, bob] = await ethers.getSigners()
    const Arch = await ethers.getContractFactory('Arch')
    arch = await Arch.deploy()
    arch = arch.connect(bob)
  })

  it('Creates arch', async () => {
    const budgetRate = await arch.budgetRate()
    const inflationRate = await arch.inflationRate()
    const maximumDuration = await arch.maximumDuration()
    const goodAccounting = await arch.goodAccounting()

    expect(budgetRate).to.equal(52)
    expect(inflationRate).to.equal(20)
    expect(goodAccounting).to.equal(true)
    expect(maximumDuration).to.equal(2048 * secondsPerWeek)
  })

  it('Updates arch', async () => {
    await arch.connect(alice).setBudgetRate(12)
    await arch.connect(alice).setInflationRate(10)
    await arch.connect(alice).setGoodAccounting(false)
    await arch.connect(alice).setMaximumDuration(1024 * secondsPerWeek)

    const budgetRate = await arch.budgetRate()
    const inflationRate = await arch.inflationRate()
    const maximumDuration = await arch.maximumDuration()
    const goodAccounting = await arch.goodAccounting()

    expect(budgetRate).to.equal(12)
    expect(inflationRate).to.equal(10)
    expect(goodAccounting).to.equal(false)
    expect(maximumDuration).to.equal(1024 * secondsPerWeek)
  })

  it('Prevents unauthorized access', async () => {
    await Promise.all([
      arch.setBudgetRate(12),
      arch.setInflationRate(10),
      arch.setGoodAccounting(false),
      arch.setMaximumDuration(1024 * secondsPerWeek)
    ].map(p => (
      expect(p).to.rejectedWith('Ownable: caller is not the owner'))
    ))
  })

  it('Pauses and unpauses', async () => {
    const p1 = await arch.paused()
    await arch.connect(alice).pause()
    const p2 = await arch.paused()
    await arch.connect(alice).unpause()
    const p3 = await arch.paused()
    expect(p1).to.equal(false)
    expect(p2).to.equal(true)
    expect(p3).to.equal(false)
  })

  it('Updates owner', async () => {
    await expect(arch.setBudgetRate(16)).to.rejectedWith('Ownable: caller is not the owner')

    await arch.connect(alice).transferOwnership(bob.address)
    const owner = await arch.owner()
    await arch.connect(bob).setBudgetRate(16)
    const budgetRate = await arch.budgetRate()

    expect(owner).to.equal(bob.address)
    expect(budgetRate).to.equal(16)
  })
})
