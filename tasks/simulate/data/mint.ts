import { BigNumber } from 'ethers'
import { parseEther } from 'ethers/lib/utils'

export interface MintOpts {
  maxAmount?: number // in ether
}

export const randomMint = (opts?: MintOpts): BigNumber => {
  const maxAmount = opts?.maxAmount != null ? opts.maxAmount : 1
  const amount = maxAmount * Math.random()
  return parseEther(`${amount}`)
}
