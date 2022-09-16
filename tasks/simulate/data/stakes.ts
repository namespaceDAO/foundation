import { BigNumber } from 'ethers'
import { parseEther } from 'ethers/lib/utils'
import { CHARACTERS, randomString } from '../utils'

export interface StakeOpts {
  id: number
  prop: number
  reason?: string
  maxFound?: number // in ether
  maxReasonLength?: number
}

export interface Stake {
  id: number
  prop: number
  reason: string
  amount: BigNumber
}

export const randomStake = (
  prop: number, opts?: StakeOpts
): Stake => {
  const maxLength = opts?.maxReasonLength != null ? opts.maxReasonLength : 64
  const length = maxLength * Math.random()
  const characters = CHARACTERS.alphaNumeric + ' '
  const text = randomString({ characters, length })

  const maxFound = opts?.maxFound != null ? opts.maxFound : 5
  const found = Math.random() * maxFound

  return {
    id: -1,
    prop,
    reason: text,
    amount: parseEther(`${found}`)
  }
}
