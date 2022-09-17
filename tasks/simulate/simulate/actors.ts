import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import { Prop, Stake } from '../data'
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
