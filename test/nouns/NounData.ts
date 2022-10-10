import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import { expect } from 'chai'
import { BigNumber, Contract } from 'ethers'
import { ethers } from 'hardhat'

describe('NounData', () => {
  let alice: SignerWithAddress
  let bob: SignerWithAddress
  let found: Contract
  let data: Contract

  const BASE_URI = 'https://bankofnouns.com/_/api/tokens/{id}.json'

  beforeEach(async () => {
    [alice, bob] = await ethers.getSigners()

    const Found = await ethers.getContractFactory('Found')
    found = await Found.deploy()

    const NounData = await ethers.getContractFactory('NounData')
    data = await NounData.deploy()
  })

  it('Gets noun data', async () => {
    const shapes = [
      '0xfffffafafaff',
      '0x32236e5dff00ffff',
      '0x50500f0fffff00ff'
    ]

    await data.submitNoun({
      name: 'Rubber Ducky',
      creator: alice.address,
      traits: ['rubber', 'ducky'],
      shapes: shapes.map(BigNumber.from)
    })

    const jsonData = await data.tokenData(1)
    const noun = JSON.parse(jsonData)

    expect(noun.id).to.equal(1)
    expect(noun.name).to.equal('Rubber Ducky')
    expect(noun.description).to.equal('Rubber Ducky is a Noun coin.')
    expect(noun.traits).to.have.ordered.members(['rubber', 'ducky'])
    expect(noun.shapes).to.have.ordered.members(shapes)

    const nounSVG = await data.tokenSVG(1)
    const nounURI = await data.tokenURI(1)

    const image64 = Buffer.from(nounSVG).toString('base64')
    expect(noun.image).to.equal(`data:image/svg+xml;base64,${image64}`)

    const data64 = Buffer.from(JSON.stringify(noun)).toString('base64')
    const dataURI = 'data:application/json;base64,' + data64

    expect(nounSVG).to.equal('<svg width="420" height="420" viewBox="0 0 255 255" xmlns="http://www.w3.org/2000/svg" shape-rendering="crispEdges"><rect width="255" height="255" x="0" y="0" fill="rgba(250,250,250,255)"/><rect width="110" height="93" x="50" y="35" fill="rgba(255,0,255,255)"/><rect width="15" height="15" x="80" y="80" fill="rgba(255,255,0,255)"/></svg>')
    expect(nounURI).to.equal(dataURI)
  })
})
