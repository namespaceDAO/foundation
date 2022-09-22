import { expect } from 'chai'
import { add } from 'date-fns'
import { Contract } from 'ethers'
import { parseEther } from 'ethers/lib/utils'
import { ethers } from 'hardhat'

describe('Brachistochrone', () => {
  let chronos: Contract
  const start = Math.floor(new Date().getTime() / 1000)

  const getTime = (date: Date): number => {
    return Math.floor(date.getTime() / 1000)
  }

  const addDays = async (days: number): Promise<void> => {
    const date = add(start * 1000, { days })
    await ethers.provider.send('evm_mine', [getTime(date)])
  }

  beforeEach(async () => {
    await ethers.provider.send('hardhat_reset', [])
    const Chron = await ethers.getContractFactory('Brachistochrone')

    await addDays(1)
    const date = add(start * 1000, { days: 33 })
    chronos = await Chron.deploy(getTime(date))
  })

  it('Brachistochrone prices', async () => {
    const val = parseEther('1')

    const a1 = await chronos.consume(val)

    await addDays(7)
    const a2 = await chronos.consume(val)

    await addDays(15)
    const a3 = await chronos.consume(val)

    await addDays(29)
    const a4 = await chronos.consume(val)

    await addDays(33)
    const a5 = await chronos.consume(val)

    expect(a1).to.equal(val.mul(2))
    expect(a2).to.lessThan(a1)
    expect(a3).to.lessThan(a2)
    expect(a4).to.lessThan(a3)
    expect(a5).to.lessThan(a4)
    expect(a5).to.equal(val)
  })
})
