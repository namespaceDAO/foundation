import { ethers } from 'hardhat'

export const dateToTime = (date: Date): number => Math.floor(date.getTime() / 1000)

export const getCurrentDateTime = async (): Promise<{ date: Date, time: number }> => {
  const blockNum = await ethers.provider.getBlockNumber()
  const { timestamp } = await ethers.provider.getBlock(blockNum)
  return { date: new Date(timestamp * 1000), time: timestamp }
}
