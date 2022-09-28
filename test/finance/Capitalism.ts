import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import { expect } from 'chai'
import { Contract } from 'ethers'
import { ethers } from 'hardhat'

describe('Capitalism', () => {
  let alice: SignerWithAddress
  let bob: SignerWithAddress
  let found: Contract
  let capital: Contract

  before(async () => {
    [alice, bob] = await ethers.getSigners()
    const Found = await ethers.getContractFactory('Found')
    found = await Found.deploy()

    const Capitalism = await ethers.getContractFactory('Capitalism')
    capital = await Capitalism.deploy(
      'FOUND NOTE',
      'FOUND NOTE',
      found.address
    )

    capital = capital.connect(bob)
  })

  it('Creates capitalism', async () => {
    const name = await capital.name()
    const symbol = await capital.symbol()

    expect(name).to.equal('FOUND NOTE')
    expect(symbol).to.equal('FOUND NOTE')
  })
})
