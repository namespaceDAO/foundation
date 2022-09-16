/* eslint-disable @typescript-eslint/restrict-plus-operands */
/* eslint-disable @typescript-eslint/restrict-template-expressions */
import chalk from 'chalk'
import { formatEther } from 'ethers/lib/utils'
import { Actor } from './actors'
import { createActions } from './actions'
import { Setup } from './initialize'
import { parseTime, shuffle } from './utils'

interface SimulateOpts extends Setup {
  duration: number
  secondsPerStep: number
  verbose: boolean
  actors: Actor[]
}

export const simulate = async (opts: SimulateOpts): Promise<void> => {
  const { verbose, found, duration, actors } = opts

  const errors: any[] = []

  const {
    props,
    stakes,
    createProp,
    createStake,
    mintFound
  } = createActions(opts)

  const start = Math.floor(new Date().getTime() / 1000)

  const catchError = (step: string, e: Error): void => {
    console.log(chalk.bold(step) + ': ' + chalk.red(e as any))
    errors.push(e)
  }

  const time = Array.from(Array(duration).keys()).map(step => (
    Math.floor(step * opts.secondsPerStep) + start
  ))

  const step = async (time: number): Promise<void> => {
    await Promise.all(
      shuffle(actors).map(async (actor) => {
        // CREATE PROP
        await createProp(actor, time).then(prop => {
          if (verbose && prop != null) {
            console.log(`${chalk.bold(parseTime(time))} Prop created: Expires ${new Date(prop.expiresAt * 1000).toISOString()}`)
          }
        }).catch(e => catchError('createProp: ' + actor.signer.address, e))

        // CREATE STAKE
        await createStake(actor, time).then(stake => {
          if (verbose && stake != null) {
            console.log(`${chalk.bold(parseTime(time))} Stake created: ${formatEther(stake.amount)}`)
          }
        }).catch(e => catchError('createStake: ' + actor.signer.address, e))

        // MINT
        await mintFound(actor, time).then(found => {
          if (verbose && found != null) {
            console.log(`${chalk.bold(parseTime(time))} Found minted: ${formatEther(found)}`)
          }
        }).catch(e => catchError('mintFound: ' + actor.signer.address, e))
      })
    )
  }

  if (verbose) {
    console.log(`${chalk.bold(parseTime(time[0]))} Simulation begins`)
  }

  await time.reduce(async (acc, cur) => {
    return await acc.then(async () => await step(cur))
  }, Promise.resolve())

  if (verbose) {
    console.log(`${chalk.bold(parseTime(time[time.length - 1]))} Simulation complete`)
  }

  const totalSupply = await found.totalSupply()

  console.log(`FOUND supply: ${formatEther(totalSupply)}`)
  console.log(`Total props: ${props.length}`)
  console.log(`Total stakes: ${stakes.length}`)
  console.log(`Total errors: ${errors.length}`)
}
