import { ethers } from 'hardhat'
import { expect } from 'chai'
import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import { Contract } from 'ethers'

const parseEther = ethers.utils.parseEther

describe('Capitialism V1', () => {
  let origin: SignerWithAddress
  let alice: SignerWithAddress
  let bob: SignerWithAddress
  let govt: Contract
  let found: Contract
  let oracle: Contract
  let descriptor: Contract
  const COIN_URI = 'https://nouns.express/_/api/tokens/{id}.json'

  const createProp = async () => {
    const text = `hello world ${Math.random()}`
    const expiresAt = Math.floor(new Date().getTime() / 1000)
    const startCash = parseEther(`${0.1 * Math.random()}`)
    const endCash = parseEther(`${0.1 * Math.random()}`)

    const fund = [alice.address, startCash, endCash]
    const prop = [text, expiresAt, fund]

    await govt.createProp(prop)
    return prop
  }

  before(async () => {
    [origin, alice, bob] = await ethers.getSigners()
    const Found = await ethers.getContractFactory('Found')
    const Capitialism = await ethers.getContractFactory('Capitialism')
    found = await Found.deploy()
    govt = await Capitialism.deploy(found.address)
  })

  it('Creates capitalism', async () => {
    const count1 = await govt.propCount()
    expect(count1).to.equal(0)
  })

  // it('Starts prop', async () => {
  //   await createProp()
  //   await expect(
  //     govt.startProp(1)
  //   ).to.revertedWith('Government: prop cannot be started')
  // })
})
