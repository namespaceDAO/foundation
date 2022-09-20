import chalk from 'chalk'
import { randomMint, randomProp, randomStake, Stake } from '../data'
import { Actor, State, Initialization, Step } from '../world'
import { parseTime, pickRandom } from '../utils'
import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import { formatEther } from 'ethers/lib/utils'

export const createRandomActor = (
  signer: SignerWithAddress,
  { govt, found }: Initialization
): Actor => ({
  signer,
  step: async (state: Step): Promise<void> => {
    const {
      time, createProp, createStake, mintToken
    } = state

    const shouldMint = Math.random() < 1 / 40
    const shouldStake = Math.random() < 1 / 40
    const shouldCreate = Math.random() < 1 / 40

    const log = (str: string): void => (
      console.log(`${chalk.bold(parseTime(time))} ${str}`)
    )

    const createStakeAttempt = async ({ props, time }: State): Promise<Stake | null> => {
      const possible = props.filter(prop => prop.expiresAt > time)
      if (possible.length === 0) return null

      const prop = pickRandom(possible)

      const stake = randomStake({ prop: prop.id, account: signer.address })
      const balance = await found.balanceOf(signer.address)

      const diff = stake.amount.sub(balance)

      if (diff.gt(0)) {
        await found.mint(signer.address, { value: diff })
      }

      return stake
    }

    const endStakeAttempt = async ({ time, stakes, props, endStake }: Step): Promise<void> => {
      const mine = stakes.filter(s => s.account === signer.address && s.endedAt == null)

      const ready = mine.reduce<Stake[]>((acc, cur) => {
        const prop = props[cur.prop - 1]

        if (prop.expiresAt <= time) {
          if (Math.random() < 0.1) {
            acc.push(cur)
          }
        }

        return acc
      }, [])

      await Promise.all(
        ready.map(endStake)
      )

      if (ready.length > 0) {
        ready.forEach(stake => {
          log(`${chalk.green('STAKE ENDED')} ${stake.id}`)
        })
      }
    }

    const startPropAttempt = async ({ time, props, startProp }: Step): Promise<void> => {
      const mine = props.filter(p => p.creator === signer.address && p.startedAt == null)
      if (mine.length === 0) return

      await Promise.all(
        mine.map(async (p) => {
          const capped = await govt.isCapitalized(p.id)
          if (capped === true) {
            log(`${chalk.blue('PROP STARTED')} ${p.id}`)
            return await startProp(p.id)
          }
        })
      )
    }

    if (shouldMint) {
      const mint = randomMint()
      await mintToken(mint)
      log(`${chalk.yellow('FOUND MINTED')} ${formatEther(mint.amount)}`)
    }

    if (shouldStake) {
      const stake = await createStakeAttempt(state)
      if (stake != null) {
        await createStake(stake)
        log(`${chalk.green('STAKE STARTED')} ${stake.id}`)
      }
    }

    if (shouldCreate) {
      const prop = randomProp({ creator: signer.address, time, maxFound: 5, maxValue: 5 })
      await createProp(prop)
      log(`${chalk.blue('PROP CREATED')}  ${prop.id}`)
    }

    await endStakeAttempt(state)
    await startPropAttempt(state)
  }
})
