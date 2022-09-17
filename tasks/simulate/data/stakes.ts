import { BigNumber } from 'ethers'
import { parseEther } from 'ethers/lib/utils'
import { CHARACTERS, randomString } from '../utils'

export interface StakeOpts {
  prop: number
  account: string
  reason?: string
  maxFound?: number // in ether
  maxReasonLength?: number
}

export interface Stake {
  _type: 'STAKE'
  id: number
  account: string
  prop: number
  reason: string
  amount: BigNumber
  startedAt: number
  endedAt?: number | undefined
}

export const randomStake = (
  opts: StakeOpts
): Stake => {
  const maxLength = opts?.maxReasonLength != null ? opts.maxReasonLength : 64
  const length = maxLength * Math.random()
  const characters = CHARACTERS.alphaNumeric + ' '
  const text = randomString({ characters, length })

  const maxFound = opts?.maxFound != null ? opts.maxFound : 5
  const found = Math.random() * maxFound

  return {
    _type: 'STAKE',
    id: -1,
    prop: opts.prop,
    account: opts.account,
    reason: text,
    amount: parseEther(`${found}`),
    startedAt: Math.floor(new Date().getTime() / 1000)
  }
}
