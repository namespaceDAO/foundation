import { Mint, Prop, Stake } from '../data'
import { Setup } from './initialize'
import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import { Bit } from '../utils'

export interface State {
  time: number
  props: Prop[]
  stakes: Stake[]
  actors: Actor[]
}

export interface Actor {
  signer: SignerWithAddress
  step: (state: State) => Promise<Array<Bit | null>>
}

export interface Actions {
  props: Prop[]
  stakes: Stake[]
  createProp: (actor: Actor, prop: Prop) => Promise<void>
  createStake: (actor: Actor, stake: Stake) => Promise<void>
  mintFound: (actor: Actor, amount: Mint) => Promise<void>
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

  const createProp: Actions['createProp'] = async (actor, prop) => {
    await govt.connect(actor.signer).createProp(prop)
    prop.id = await govt.propCount()

    accounts[actor.signer.address].props[prop.id] = prop
    props[prop.id - 1] = prop
  }

  const mintFound: Actions['mintFound'] = async (actor, { amount }) => {
    await found.connect(actor.signer).mint(actor.signer.address, { value: amount })
  }

  const createStake: Actions['createStake'] = async (actor, stake) => {
    await govt.connect(actor.signer).createStake(stake)
    stake.id = await govt.stakeCount()

    accounts[actor.signer.address].stakes[stake.id] = stake
    stakes[stake.id - 1] = stake
  }

  return {
    props,
    stakes,
    createProp,
    createStake,
    mintFound
  }
}
