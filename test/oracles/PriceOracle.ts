import { ethers } from 'hardhat'
import { expect } from 'chai'
import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import { Contract } from 'ethers'

const parseEther = ethers.utils.parseEther

// TODO: test approval for all
// TODO: test allowances

describe('Oracle', () => {
  let origin: SignerWithAddress
  let alice: SignerWithAddress
  let bob: SignerWithAddress
  let oracle: Contract

  const BASE_URI = 'https://bankofnouns.com/_/api/tokens/{id}.json'

  it('Create coin ledger', async () => {
    [origin, alice, bob] = await ethers.getSigners()
    const Oracle = await ethers.getContractFactory('MockOracle')
    oracle = await Oracle.deploy()

    const price = await oracle.oraclePrice()
    const decimals = await oracle.oracleDecimals()

    const amount = parseEther(`${Math.random()}`)
    const value = await oracle.convertValueAtOraclePrice(amount)

    expect(price.div(Math.pow(10, decimals))).to.equal(1600)
    expect(value).to.equal(amount.mul(1600))
  })
})
