import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import { Contract } from 'ethers'
import { Prop, randomProp, randomStake, Stake } from './data'
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
}

export const handles = ({ govt, signers }: HandleOpts): Handles => {
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
    props[prop.id] = prop

    return prop
  }

  const createStake = async (): Promise<Stake> => {
    const prop = Math.floor(Math.random() * props.length)
    const stake = randomStake(prop)

    const creator = pickRandom(signers)

    await govt.connect(creator).createStake(stake)
    stake.id = await govt.stakeCount()

    accounts[creator.address].stakes[stake.id] = stake
    stakes[stake.id] = stake

    return stake
  }

  return {
    props,
    stakes,
    createProp,
    createStake
  }
}

export const simulate = async (opts: SimulateOpts): Promise<void> => {
  const { duration, stepsPerDay } = opts
  const time = Array.from(Array(duration).keys())

  const {
    props,
    stakes,
    createProp,
    createStake
  } = handles(opts)

  const step = async (t: number): Promise<void> => {
    const day = Math.floor(t / stepsPerDay)

    if (t % stepsPerDay === 0) {
      console.log(`Day ${day}`)
    }

    // actions:
    // create prop
    // create stake
    // end stake
    // start prop

    if (Math.random() < 1 / stepsPerDay) {
      const prop = await createProp()
      console.log(`Prop created: ${new Date(prop.expiresAt * 1000).toISOString()}`)
    }

    if (Math.random() < 1 / stepsPerDay) {
      const stake = await createStake()
      console.log(`Stake created: ${stake.prop}`)
    }
  }

  await time.reduce(async (acc, cur) => {
    return await acc.then(async () => await step(cur))
  }, Promise.resolve())

  console.log(`Total props: ${props.length}`)
  console.log(`Total stakes: ${stakes.length}`)
}
