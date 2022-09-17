import { add } from 'date-fns'
import { BigNumber } from 'ethers'
import { parseEther } from 'ethers/lib/utils'
import { CHARACTERS, randomString } from '../utils'

export interface PropOpts {
  payee: string
  time: number
  maxTextLength?: number
  maxFound?: number // in ether
  maxValue?: number // in ether
  maxDuration?: number // in seconds
}

export interface Prop {
  _type: 'PROP'
  id: number
  text: string
  expiresAt: number
  startedAt?: number | undefined
  note: {
    payee: string
    found: BigNumber // in wei
    value: BigNumber // in wei
  }
}

export const randomProp = (
  { payee, time, ...opts }: PropOpts
): Prop => {
  const maxLength = opts.maxTextLength != null ? opts.maxTextLength : 512
  const length = maxLength * Math.random()

  const characters = CHARACTERS.alphaNumeric + ' '
  const text = randomString({ characters, length })

  const maxDuration = opts?.maxDuration != null
    ? opts.maxDuration
    : 3600 * 24 * 7 * 4

  const minDuration = 3600 * 24 * 7 + 1

  const duration = maxDuration * Math.random() + minDuration
  const expiresAt = Math.floor(time + duration)

  const maxFound = opts?.maxFound != null ? opts.maxFound : 5
  const found = Math.random() * maxFound

  const maxValue = opts?.maxValue != null ? opts.maxValue : 5
  const value = Math.random() * maxValue

  const note = {
    payee,
    found: parseEther(`${found}`),
    value: parseEther(`${value}`)
  }

  return { _type: 'PROP', id: -1, text, expiresAt, note }
}
