import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import { expect } from 'chai'
import { Contract } from 'ethers'
import { ethers } from 'hardhat'

describe('Venture', () => {
  let alice: SignerWithAddress
  let bob: SignerWithAddress
  let found: Contract
  let venture: Contract

  beforeEach(async () => {
    [alice, bob] = await ethers.getSigners()
    const Found = await ethers.getContractFactory('Found')
    found = await Found.deploy()

    const Venture = await ethers.getContractFactory('Venture')
    venture = await Venture.deploy(
      'FOUND NOTE',
      'FOUND NOTE',
      found.address
    )

    venture = venture.connect(bob)
  })

  it('Creates adventure', async () => {
    const Capitalism = await ethers.getContractFactory('Capitalism')
    const cap = await Capitalism.attach(await venture.capitalism())

    const name = await cap.name()
    const symbol = await cap.symbol()

    expect(name).to.equal('FOUND NOTE')
    expect(symbol).to.equal('FOUND NOTE')

    await expect(cap.startStake({
      amount: 0,
      expiresAt: 0,
      founder: bob.address,
      owner: bob.address,
      prop: 0
    })).to.rejectedWith('Caller is not the admin')
  })

  it('Starts stake', async () => {
    await venture.startStake({
      amount: 10,
      expiresAt: 0,
      founder: bob.address,
      owner: bob.address,
      prop: 0
    })
  })
})
