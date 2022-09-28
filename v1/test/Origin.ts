import { ethers } from 'hardhat'
import { expect } from 'chai'
import { beforeEach } from 'mocha'
import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import { Contract } from 'ethers'

describe('Origin', () => {
  let signer: SignerWithAddress
  let signer2: SignerWithAddress
  let origin: Contract

  beforeEach(async () => {
    [signer, signer2] = await ethers.getSigners()

    const Origin = await ethers.getContractFactory('Origin')
    origin = await Origin.deploy(signer.address)
  })

  it('Create origin with getters', async () => {
    const address = await origin.originAddress()
    const provenance = await origin.originProvenance()
    expect(address).to.equal(signer.address)
    expect(provenance).to.equal(ethers.constants.AddressZero)
  })

  it('Move origin', async () => {
    await origin.updateOrigin(signer2.address)
    const address = await origin.originAddress()
    expect(address).to.equal(signer2.address)
  })

  it('Relinquish origin', async () => {
    await origin.relinquishOrigin()
    const address = await origin.originAddress()
    const provenance = await origin.originProvenance()
    expect(address).to.equal(ethers.constants.AddressZero)
    expect(provenance).to.equal(signer.address)
  })

  it('Fails to move origin', async () => {
    await expect(
      origin.connect(signer2).updateOrigin(signer2.address)
    ).to.revertedWith('Caller is not the origin')
  })

  it('Fails to relinquish origin', async () => {
    await expect(
      origin.connect(signer2).relinquishOrigin()
    ).to.revertedWith('Caller is not the origin')
  })
})
