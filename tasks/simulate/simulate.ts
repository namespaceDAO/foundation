/* eslint-disable @typescript-eslint/restrict-plus-operands */
/* eslint-disable @typescript-eslint/restrict-template-expressions */
import chalk from 'chalk'
import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import { Contract } from 'ethers'
import { HandleOpts, handles } from './handles'
import { formatEther, parseEther } from 'ethers/lib/utils'

interface SimulateOpts extends HandleOpts {
  duration: number
  stepsPerDay: number
  signers: SignerWithAddress[]
  found: Contract
  govt: Contract
  verbose: boolean
}

type Step = (time: number) => Promise<void>

export const simulate = async (opts: SimulateOpts): Promise<void> => {
  const { verbose, found, duration, stepsPerDay } = opts
  const time = Array.from(Array(duration).keys())

  const errors: any[] = []

  const {
    props,
    stakes,
    createProp,
    createStake,
    mintFound
  } = handles(opts)

  const start = Math.floor(new Date().getTime() / 1000)

  const getDateString = (time: number): string => {
    const date = new Date(time * 1000)
    return date.toISOString()
  }

  const catchError = (step: string, e: Error): void => {
    console.log(chalk.bold(step) + ': ' + chalk.red(e as any))
    errors.push(e)
  }

  const stepCreateProp: Step = async (time) => {
    if (Math.random() < 1 / stepsPerDay) {
      return await createProp(time).then(({ prop }) => {
        if (verbose) {
          console.log(`${chalk.bold(getDateString(time))} Prop created expires at: ${new Date(prop.expiresAt * 1000).toISOString()}`)
        }
      }).catch(e => catchError('createProp', e))
    }
  }

  const stepCreateStake: Step = async (time) => {
    if (Math.random() < 1 / stepsPerDay) {
      return await createStake(time).then(({ stake }) => {
        if (verbose) {
          console.log(`${chalk.bold(getDateString(time))} Stake created: ${formatEther(stake.amount)} FOUND`)
        }
      }).catch(e => catchError('createStake', e))
    }
  }

  const stepMintFound: Step = async (time) => {
    if (Math.random() < 1 / stepsPerDay) {
      return await mintFound(time).then(({ amount }) => {
        if (verbose) {
          console.log(`${chalk.bold(getDateString(time))} Found minted: ${formatEther(amount)} FOUND`)
        }
      }).catch(e => catchError('mintFound', e))
    }
  }

  const step = async (step: number): Promise<void> => {
    const t = Math.floor((step + Math.random()) * 3600) + start
    await stepCreateProp(t)
    await stepCreateStake(t)
    await stepMintFound(t)
  }

  await time.reduce(async (acc, cur) => {
    return await acc.then(async () => await step(cur))
  }, Promise.resolve())

  const totalSupply = await found.totalSupply()

  console.log(`FOUND supply: ${formatEther(totalSupply)}`)
  console.log(`Total props: ${props.length}`)
  console.log(`Total stakes: ${stakes.length}`)
  console.log(`Total errors: ${errors.length}`)
}
