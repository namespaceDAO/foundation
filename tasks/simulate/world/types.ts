import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import { Mint, Prop, Stake } from '../data'

export interface State {
  time: number
  props: Prop[]
  stakes: Stake[]
  actors: Actor[]
  accounts: Record<string, Account>
}

export interface Actions {
  createProp: (prop: Prop) => Promise<void>
  createStake: (stake: Stake) => Promise<void>
  startProp: (prop: number) => Promise<void>
  endStake: (stake: Stake) => Promise<void>
  mintFound: (amount: Mint) => Promise<void>
}

export type Step = State & Actions

export interface Actor {
  signer: SignerWithAddress
  step: (state: Step) => Promise<void>
}

export interface Account {
  props: Record<number, Prop>
  stakes: Record<number, Stake>
}
