import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import { Contract } from 'ethers'
import { HandleOpts, handles } from './handles'

interface SimulateOpts extends HandleOpts {
  duration: number
  stepsPerDay: number
  signers: SignerWithAddress[]
  found: Contract
  govt: Contract
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
