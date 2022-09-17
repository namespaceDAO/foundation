import { BigNumber } from 'ethers'
import { parseEther } from 'ethers/lib/utils'

export interface MintOpts {
  maxAmount?: number // in ether
}

export interface Mint {
  _type: 'MINT'
  amount: BigNumber
}

export const randomMint = (opts?: MintOpts): Mint => {
  const maxAmount = opts?.maxAmount != null ? opts.maxAmount : 1
  const amount = maxAmount * Math.random()
  return { _type: 'MINT', amount: parseEther(`${amount}`) }
}
