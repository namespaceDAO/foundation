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
      image: [
        BigNumber.from('0x0000fffffafafaff'),
        BigNumber.from('0x32236e5dff00ffff'),
        BigNumber.from('0x50500f0fffff00ff')
      ]
    })

    const nounSVG = await game.nounSVG(1)
    const nounURI = await game.nounURI(1)
    const nounJSON = await game.nounJSON(1)

    // TODO: more rigourous testing

    expect(nounSVG).to.equal('<svg width="420" height="420" viewBox="0 0 255 255" xmlns="http://www.w3.org/2000/svg" shape-rendering="crispEdges"><rect width="255" height="255" x="0" y="0" fill="rgba(250,250,250,255)"/><rect width="110" height="93" x="50" y="35" fill="rgba(255,0,255,255)"/><rect width="15" height="15" x="80" y="80" fill="rgba(255,255,0,255)"/></svg>')
    expect(nounURI).to.equal('data:application/json;base64,eyJpZCI6IjEiLCJuYW1lIjoiUnViYmVyIER1Y2t5IiwiZGVzY3JpcHRpb24iOiJSdWJiZXIgRHVja3kgaXMgYSBOb3VuIGNvaW4uIiwiaW1hZ2UiOiJkYXRhOmltYWdlL3N2Zyt4bWw7YmFzZTY0LFBITjJaeUIzYVdSMGFEMGlOREl3SWlCb1pXbG5hSFE5SWpReU1DSWdkbWxsZDBKdmVEMGlNQ0F3SURJMU5TQXlOVFVpSUhodGJHNXpQU0pvZEhSd09pOHZkM2QzTG5jekxtOXlaeTh5TURBd0wzTjJaeUlnYzJoaGNHVXRjbVZ1WkdWeWFXNW5QU0pqY21semNFVmtaMlZ6SWo0OGNtVmpkQ0IzYVdSMGFEMGlNalUxSWlCb1pXbG5hSFE5SWpJMU5TSWdlRDBpTUNJZ2VUMGlNQ0lnWm1sc2JEMGljbWRpWVNneU5UQXNNalV3TERJMU1Dd3lOVFVwSWk4K1BISmxZM1FnZDJsa2RHZzlJakV4TUNJZ2FHVnBaMmgwUFNJNU15SWdlRDBpTlRBaUlIazlJak0xSWlCbWFXeHNQU0p5WjJKaEtESTFOU3d3TERJMU5Td3lOVFVwSWk4K1BISmxZM1FnZDJsa2RHZzlJakUxSWlCb1pXbG5hSFE5SWpFMUlpQjRQU0k0TUNJZ2VUMGlPREFpSUdacGJHdzlJbkpuWW1Fb01qVTFMREkxTlN3d0xESTFOU2tpTHo0OEwzTjJaejQ9In0=')
    expect(nounJSON).to.equal('{"id":"1","name":"Rubber Ducky","description":"Rubber Ducky is a Noun coin.","image":"data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iNDIwIiBoZWlnaHQ9IjQyMCIgdmlld0JveD0iMCAwIDI1NSAyNTUiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyIgc2hhcGUtcmVuZGVyaW5nPSJjcmlzcEVkZ2VzIj48cmVjdCB3aWR0aD0iMjU1IiBoZWlnaHQ9IjI1NSIgeD0iMCIgeT0iMCIgZmlsbD0icmdiYSgyNTAsMjUwLDI1MCwyNTUpIi8+PHJlY3Qgd2lkdGg9IjExMCIgaGVpZ2h0PSI5MyIgeD0iNTAiIHk9IjM1IiBmaWxsPSJyZ2JhKDI1NSwwLDI1NSwyNTUpIi8+PHJlY3Qgd2lkdGg9IjE1IiBoZWlnaHQ9IjE1IiB4PSI4MCIgeT0iODAiIGZpbGw9InJnYmEoMjU1LDI1NSwwLDI1NSkiLz48L3N2Zz4="}')
  })
})
