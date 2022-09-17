import { Initialization, Actor } from '../world'
import { createRandomActor } from './random'

export const createActors = (init: Initialization): Actor[] => (
  init.signers.map(signer => createRandomActor(signer, init))
)
