import chalk from 'chalk'
import { randomMint, randomProp, randomStake, Stake } from '../data'
import { Actor, State, Initialization, Step } from '../world'
import { parseTime, pickRandom } from '../utils'
import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import { formatEther } from 'ethers/lib/utils'

export const createRandomActor = (
  signer: SignerWithAddress,
  { found }: Initialization
): Actor => {
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
        acc.push(cur)
      }

      return acc
    }, [])

    await Promise.all(
      ready.map(endStake)
    )

    if (ready.length > 0) {
      ready.forEach(stake => {
        console.log(`${chalk.bold(parseTime(time))} Stake ended: ${formatEther(stake.amount)}`)
      })
    }
  }

  const step = async (state: Step): Promise<void> => {
    const {
      time, createProp, createStake, mintFound
    } = state

    const shouldMint = Math.random() < 1 / 40
    const shouldStake = Math.random() < 1 / 40
    const shouldCreate = Math.random() < 1 / 40

    if (shouldMint) {
      const mint = randomMint()
      await mintFound(mint)
      console.log(`${chalk.bold(parseTime(time))} Found minted: ${formatEther(mint.amount)}`)
    }

    if (shouldStake) {
      const stake = await createStakeAttempt(state)
      if (stake != null) {
        await createStake(stake)
        console.log(`${chalk.bold(parseTime(time))} Stake created: ${formatEther(stake.amount)}`)
      }
    }

    if (shouldCreate) {
      const prop = randomProp({ payee: signer.address, time, maxFound: 5, maxValue: 5 })
      await createProp(prop)
      console.log(`${chalk.bold(parseTime(time))} Prop created: Expires ${new Date(prop.expiresAt * 1000).toISOString()}`)
    }

    await endStakeAttempt(state)
  }

  return { step, signer }
}
