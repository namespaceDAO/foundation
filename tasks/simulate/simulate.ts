import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import { Contract } from 'ethers'
import { HandleOpts, handles } from './handles'
import { formatEther } from 'ethers/lib/utils'

interface SimulateOpts extends HandleOpts {
  duration: number
  stepsPerDay: number
  signers: SignerWithAddress[]
  found: Contract
  govt: Contract
}

export const simulate = async (opts: SimulateOpts): Promise<void> => {
  const { found, duration, stepsPerDay } = opts
  const time = Array.from(Array(duration).keys())

  const {
    props,
    stakes,
    createProp,
    createStake,
    mintFound
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

    // TODO: currently time doesnt move forward, it always assumes your in the current moment
    // to fix this pass a t into the `createStake` function and the `createProp` function
    if (Math.random() < 1 / stepsPerDay) {
      const stake = await createStake()
      console.log(`Stake created: ${stake.prop}`)
    }

    if (Math.random() < 1 / stepsPerDay) {
      const amount = await mintFound()
      console.log(`Found minted: ${formatEther(amount)}`)
    }
  }

  await time.reduce(async (acc, cur) => {
    return await acc.then(async () => await step(cur))
  }, Promise.resolve())

  const totalSupply = await found.totalSupply()

  console.log(`FOUND supply: ${formatEther(totalSupply)}`)
  console.log(`Total props: ${props.length}`)
  console.log(`Total stakes: ${stakes.length}`)
}
