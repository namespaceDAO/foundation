/* eslint-disable @typescript-eslint/restrict-plus-operands */
/* eslint-disable @typescript-eslint/restrict-template-expressions */
import chalk from 'chalk'
import { formatEther } from 'ethers/lib/utils'
import { Prop, Stake } from '../data'
import { parseTime, shuffle } from '../utils'
import { Account, Actor, State } from './types'
import { createActions } from './actions'
import { Setup } from './initialize'

interface SimulateOpts extends Setup {
  duration: number
  secondsPerStep: number
  verbose: boolean
  actors: Actor[]
}

export const simulate = async (opts: SimulateOpts): Promise<void> => {
  const { verbose, found, duration, actors } = opts
  const start = Math.floor(new Date().getTime() / 1000)
  const errors: any[] = []

  const catchError = (step: string, e: Error): void => {
    console.log(chalk.bold(step) + ': ' + chalk.red(e as any))
    errors.push(e)
  }

  const time = Array.from(Array(duration).keys()).map(step => (
    Math.floor(step * opts.secondsPerStep) + start
  ))

  const props: Prop[] = []
  const stakes: Stake[] = []

  const accounts = actors.reduce<Record<string, Account>>((acc, cur) => {
    acc[cur.signer.address] = { props: {}, stakes: {} }
    return acc
  }, {})

  const step = async (time: number): Promise<void> => {
    await Promise.all(
      shuffle(actors).map(async (actor) => {
        const state: State = { time, props, stakes, accounts, actors }
        const actions = createActions(actor, opts, state)

        await actor.step({ ...actions, ...state }).catch((e: any) => (
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
  console.log(`Total props: ${props.length}`)
  console.log(`Total stakes: ${stakes.length}`)
  console.log(`Total errors: ${errors.length}`)
}
