import { BigNumber } from 'ethers'
import { Actor } from '../actors'
import { Prop, Stake } from '../data'
import { Setup } from '../initialize'

export interface Actions {
  props: Prop[]
  stakes: Stake[]
  createProp: (actor: Actor, time: number) => Promise<Prop | null>
  createStake: (actor: Actor, time: number) => Promise<Stake | null>
  mintFound: (actor: Actor, time: number) => Promise<BigNumber | null>
}

interface ActionProps extends Setup {
  actors: Actor[]
}

export const createActions = ({ govt, actors, found }: ActionProps): Actions => {
  const props: Prop[] = []
  const stakes: Stake[] = []

  const accounts = actors.reduce<Record<string, {
    props: Record<number, Prop>
    stakes: Record<number, Stake>
  }>>((acc, cur) => {
    acc[cur.signer.address] = { props: {}, stakes: {} }
    return acc
  }, {})

  const createProp: Actions['createProp'] = async (actor, time) => {
    const prop = await actor.createProp({ time, props, stakes, actors })
    if (prop == null) return null

    await govt.connect(actor.signer).createProp(prop)
    prop.id = await govt.propCount()

    accounts[actor.signer.address].props[prop.id] = prop
    props[prop.id - 1] = prop

    return prop
  }

  const mintFound: Actions['mintFound'] = async (actor, time) => {
    const value = await actor.mintFound({ time, props, stakes, actors })
    if (value != null) {
      await found.connect(actor.signer).mint(actor.signer.address, { value })
    }
    return value
  }

  const createStake: Actions['createStake'] = async (actor, time) => {
    const stake = await actor.createStake({ time, props, stakes, actors })
    if (stake == null) return null

    await govt.connect(actor.signer).createStake(stake)
    stake.id = await govt.stakeCount()

    accounts[actor.signer.address].stakes[stake.id] = stake
    stakes[stake.id - 1] = stake

    return stake
  }

  return {
    props,
    stakes,
    createProp,
    createStake,
    mintFound
  }
}
