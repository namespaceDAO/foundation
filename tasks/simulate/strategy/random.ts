import { randomMint, randomProp, randomStake, Stake } from '../data'
import { Actor, State } from '../simulate'
import { Initialization } from '../initialize'
import { Bit, pickRandom } from '../utils'
import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'

export const createRandomActor = (
  signer: SignerWithAddress,
  { found }: Initialization
): Actor => {
  const getStake = async ({ props, time }: State): Promise<Stake | null> => {
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
  }

  const step = async (state: State): Promise<Array<Bit | null>> => {
    const mint = Math.random() > 1 / 40 ? null : randomMint()

    const prop = Math.random() > 1 / 40
      ? null
      : randomProp(signer.address, {
        maxFound: 5,
        maxValue: 5,
        maxTextLength: 512
      })

    const stake = Math.random() > 1 / 40 ? null : await getStake(state)

    return [mint, prop, stake]
  }

  return { step, signer }
}
