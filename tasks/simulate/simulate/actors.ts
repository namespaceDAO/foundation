import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import { BigNumber } from 'ethers'
import { Prop, Stake } from './data'

export interface State {
  time: number
  props: Prop[]
  stakes: Stake[]
  actors: Actor[]
}

export interface Actor {
  signer: SignerWithAddress
  createProp: (state: State) => Promise<Prop | null>
  createStake: (state: State) => Promise<Stake | null>
  mintFound: (state: State) => Promise<BigNumber | null>
}
