import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import { expect } from 'chai'
import { BigNumber, Contract } from 'ethers'
import { ethers } from 'hardhat'

describe('NounData', () => {
  let alice: SignerWithAddress
  let bob: SignerWithAddress
  let found: Contract
  let game: Contract

  const BASE_URI = 'https://bankofnouns.com/_/api/tokens/{id}.json'

  beforeEach(async () => {
    [alice, bob] = await ethers.getSigners()

    const Found = await ethers.getContractFactory('Found')
    found = await Found.deploy()

    const NounGame = await ethers.getContractFactory('NounGame')
    game = await NounGame.deploy(found.address, BASE_URI)
  })

  it('Gets noun data', async () => {
    await game.submitNoun({
      name: 'Rubber Ducky',
      creator: alice.address,
      traits: [],
      image: [
        BigNumber.from('0x0000fffffafafaff'),
        BigNumber.from('0x32236e5dff00ffff'),
        BigNumber.from('0x50500f0fffff00ff')
      ]
    })

    const nounSVG = await game.nounSVG(1)
    const nounURI = await game.nounURI(1)
    const nounJSON = await game.nounJSON(1)

    const image64 = Buffer.from(nounSVG).toString('base64')
    const data = {
      id: '1',
      name: 'Rubber Ducky',
      description: 'Rubber Ducky is a Noun coin.',
      traits: [],
      image: 'data:image/svg+xml;base64,' + image64
    }
    const dataJSON = JSON.stringify(data)
    const data64 = Buffer.from(dataJSON).toString('base64')
    const dataURI = 'data:application/json;base64,' + data64

    expect(nounSVG).to.equal('<svg width="420" height="420" viewBox="0 0 255 255" xmlns="http://www.w3.org/2000/svg" shape-rendering="crispEdges"><rect width="255" height="255" x="0" y="0" fill="rgba(250,250,250,255)"/><rect width="110" height="93" x="50" y="35" fill="rgba(255,0,255,255)"/><rect width="15" height="15" x="80" y="80" fill="rgba(255,255,0,255)"/></svg>')
    expect(nounJSON).to.equal(dataJSON)
    expect(nounURI).to.equal(dataURI)
  })
})
