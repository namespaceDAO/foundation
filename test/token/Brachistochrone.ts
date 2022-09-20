import { expect } from 'chai'
import { sub } from 'date-fns'
import { Contract } from 'ethers'
import { parseEther } from 'ethers/lib/utils'
import { ethers } from 'hardhat'

describe('Brachistochrone', () => {
  let found: Contract

  const setDate = async ({ daysBefore }: { daysBefore: number}): Promise<void> => {
    const date = sub(new Date(1666666667 * 1000), { days: daysBefore })
    const endingAt = Math.floor(date.getTime() / 1000)
    await ethers.provider.send('evm_mine', [endingAt])
  }

  beforeEach(async () => {
    await ethers.provider.send('hardhat_reset', [])
    const [origin] = await ethers.getSigners()
    const Found = await ethers.getContractFactory('Found')
    found = await Found.deploy(origin.address, true)
  })

  it('Brachistochrone prices', async () => {
    const val = parseEther('1')

    await setDate({ daysBefore: 31 })
    const a1 = await found.calculateMintAmount(val)

    await setDate({ daysBefore: 29 })
    const a2 = await found.calculateMintAmount(val)

    await setDate({ daysBefore: 15 })
    const a3 = await found.calculateMintAmount(val)

    await setDate({ daysBefore: 7 })
    const a4 = await found.calculateMintAmount(val)

    await setDate({ daysBefore: 0 })
    const a5 = await found.calculateMintAmount(val)

    expect(a1).to.equal(val.mul(2))
    expect(a2).to.lessThan(a1)
    expect(a3).to.lessThan(a2)
    expect(a4).to.lessThan(a3)
    expect(a5).to.lessThan(a4)
    expect(a5).to.equal(val)
  })
})
