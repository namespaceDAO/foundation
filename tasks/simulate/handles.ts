import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import { add } from 'date-fns'
import { BigNumber, Contract } from 'ethers'
import { Prop, randomMint, randomProp, randomStake, Stake } from './data'
import { pickRandom } from './utils'

export interface HandleOpts {
  signers: SignerWithAddress[]
  found: Contract
  govt: Contract
}

export interface Handles {
  props: Prop[]
  stakes: Stake[]
  createProp: () => Promise<Prop>
  createStake: () => Promise<Stake>
  mintFound: () => Promise<BigNumber>
}

export const handles = ({ govt, signers, found }: HandleOpts): Handles => {
  const props: Prop[] = []
  const stakes: Stake[] = []

  const accounts = signers.reduce<Record<string, {
    props: Record<number, Prop>
    stakes: Record<number, Stake>
  }>>((acc, cur) => {
    acc[cur.address] = { props: {}, stakes: {} }
    return acc
  }, {})

  const createProp = async (): Promise<Prop> => {
    const creator = pickRandom(signers)
    const prop = randomProp(creator.address, {
      maxFound: 5,
      maxValue: 5,
      maxTextLength: 200
    })

    await govt.connect(creator).createProp(prop)
    prop.id = await govt.propCount()

    accounts[creator.address].props[prop.id] = prop
    props[prop.id - 1] = prop

    return prop
  }

  const mintFound = async (): Promise<BigNumber> => {
    const creator = pickRandom(signers)
    const value = randomMint()
    await found.connect(creator).mint(creator.address, { value })
    return value
  }

  const createStake = async (): Promise<Stake> => {
    const prop = Math.floor(Math.random() * props.length)

    // TODO: pass time through the simulation
    const now = Math.floor(add(new Date(), { days: 7 }).getTime() / 1000)
    const possible = props.filter(p => p.expiresAt > now)

    console.log(props)

    const stake = randomStake(prop)

    const creator = pickRandom(signers)
    const balance = await found.balanceOf(creator.address)

    if (balance < stake.amount) {
      const value = stake.amount.sub(balance)
      await found.connect(creator).mint(creator.address, { value })
    }

    await govt.connect(creator).createStake(stake)
    stake.id = await govt.stakeCount()

    accounts[creator.address].stakes[stake.id] = stake
    stakes[stake.id - 1] = stake

    return stake
  }

  return {
    props,
    stakes,
    createProp,
    createStake,
    mintFound
  }
}
