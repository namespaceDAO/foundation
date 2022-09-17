import { Initialization } from '../initialize'
import { createRandomActor } from './random'
import { Actor } from '../simulate'

export const createActors = (init: Initialization): Actor[] => (
  init.signers.map(signer => createRandomActor(signer, init))
)
