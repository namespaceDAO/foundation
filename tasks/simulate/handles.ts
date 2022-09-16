import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import { add } from 'date-fns'
import { BigNumber } from 'ethers'
import { Prop, randomMint, randomProp, randomStake, Stake } from './data'
import { Setup } from './setup'
import { pickRandom } from './utils'

export interface Handles {
  props: Prop[]
  stakes: Stake[]
  createProp: (time: number) => Promise<{ actor: SignerWithAddress, prop: Prop }>
  createStake: (time: number) => Promise<{ actor: SignerWithAddress, stake: Stake }>
  mintFound: (time: number) => Promise<{ actor: SignerWithAddress, amount: BigNumber }>
}

export const handles = ({ govt, signers, found }: Setup): Handles => {
  const props: Prop[] = []
  const stakes: Stake[] = []

  const accounts = signers.reduce<Record<string, {
    props: Record<number, Prop>
    stakes: Record<number, Stake>
  }>>((acc, cur) => {
    acc[cur.address] = { props: {}, stakes: {} }
    return acc
  }, {})

  const createProp: Handles['createProp'] = async (time) => {
    const actor = pickRandom(signers)
    const prop = randomProp(actor.address, {
      maxFound: 5,
      maxValue: 5,
      maxTextLength: 200
    })

    await govt.connect(actor).createProp(prop)
    prop.id = await govt.propCount()

    accounts[actor.address].props[prop.id] = prop
    props[prop.id - 1] = prop

    return { actor, prop }
  }

  const mintFound: Handles['mintFound'] = async (time) => {
    const actor = pickRandom(signers)
    const value = randomMint()
    await found.connect(actor).mint(actor.address, { value })
    return { actor, amount: value }
  }

  const createStake: Handles['createStake'] = async (time) => {
    const prop = Math.floor(Math.random() * props.length)

    // TODO: pass time through the simulation
    const now = Math.floor(add(new Date(), { days: 7 }).getTime() / 1000)
    const possible = props.filter(p => p.expiresAt > now)

    const stake = randomStake(prop)

    const actor = pickRandom(signers)
    const balance = await found.balanceOf(actor.address)

    if (balance < stake.amount) {
      const value = stake.amount.sub(balance)
      await found.connect(actor).mint(actor.address, { value })
    }

    await govt.connect(actor).createStake(stake)
    stake.id = await govt.stakeCount()

    accounts[actor.address].stakes[stake.id] = stake
    stakes[stake.id - 1] = stake

    return { actor, stake }
  }

  return {
    props,
    stakes,
    createProp,
    createStake,
    mintFound
  }
}
