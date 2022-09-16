import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import { sign } from 'crypto'
import { task } from 'hardhat/config'
import { Actor } from './actors'
import { randomMint, randomProp, randomStake } from './data'
import { Initialization, initialize } from './initialize'
import { simulate } from './simulate'
import { pickRandom } from './utils'

// `createProp`, `createStake`, and `mintFound` run every step
// each actor can implement their own strategy, the default is random.
const createActors = ({ found, signers }: Initialization): Actor[] => (
  signers.map(signer => ({
    signer,
    createProp: async () => {
      if (Math.random() > 1 / 40) return null

      return randomProp(signer.address, {
        maxFound: 5,
        maxValue: 5,
        maxTextLength: 200
      })
    },
    createStake: async ({ time, props }) => {
      if (Math.random() > 1 / 40) return null

      const possible = props.filter(prop => prop.expiresAt > time)
      if (possible.length === 0) return null

      const prop = pickRandom(possible)

      const stake = randomStake(prop.id)
      const balance = await found.balanceOf(signer.address)

      const diff = stake.amount.sub(balance)

      if (diff.gt(0)) {
        await found.mint(signer.address, { value: diff })
      }

      return stake
    },
    mintFound: async () => {
      if (Math.random() > 1 / 40) return null
      return randomMint()
    }
  }))
)

task('simulate', 'Simulates contract interactions', async (_, { ethers }) => {
  const init = await initialize({ ethers })

  const config = {
    duration: 24,
    secondsPerStep: 3600 * 6,
    verbose: true
  }

  await simulate({
    ...init,
    ...config,
    actors: createActors(init)
  })
})
