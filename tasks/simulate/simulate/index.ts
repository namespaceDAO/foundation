/* eslint-disable @typescript-eslint/restrict-plus-operands */
/* eslint-disable @typescript-eslint/restrict-template-expressions */
import chalk from 'chalk'
import { formatEther } from 'ethers/lib/utils'
import { Actor } from './actors'
import { createActions } from './actions'
import { Setup } from '../initialize'
import { parseTime, shuffle } from '../utils'
import { Mint, Prop, Stake } from '../data'

export * from './actors'

interface SimulateOpts extends Setup {
  duration: number
  secondsPerStep: number
  verbose: boolean
  actors: Actor[]
}

export const simulate = async (opts: SimulateOpts): Promise<void> => {
  const { verbose, found, duration, actors } = opts
  const actions = createActions(opts)
  const start = Math.floor(new Date().getTime() / 1000)
  const errors: any[] = []

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
        await actor.step({
          time, actors, ...actions
        }).then(async bits => {
          await Promise.all(
            bits.reduce<Array<Promise<void>>>((acc, bit) => {
              if (bit?._type === 'PROP') {
                const prop = bit as Prop
                if (verbose) {
                  console.log(`${chalk.bold(parseTime(time))} Prop created: Expires ${new Date(prop.expiresAt * 1000).toISOString()}`)
                }

                acc.push(actions.createProp(actor, prop))
              }

              if (bit?._type === 'STAKE') {
                const stake = bit as Stake
                if (verbose) {
                  console.log(`${chalk.bold(parseTime(time))} Stake created: ${formatEther(stake.amount)}`)
                }

                acc.push(actions.createStake(actor, stake))
              }

              if (bit?._type === 'MINT') {
                const mint = bit as Mint
                if (verbose) {
                  console.log(`${chalk.bold(parseTime(time))} Found minted: ${formatEther(mint.amount)}`)
                }
                acc.push(actions.mintFound(actor, mint))
              }

              return acc
            }, [])
          )
        }).catch(e => (
          catchError(actor.signer.address, e)
        ))
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
  console.log(`Total props: ${actions.props.length}`)
  console.log(`Total stakes: ${actions.stakes.length}`)
  console.log(`Total errors: ${errors.length}`)
}
