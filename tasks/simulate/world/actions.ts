import { Setup } from './initialize'
import { Actions, Actor, State } from './types'

export const createActions = (
  actor: Actor,
  { govt, found }: Setup,
  { accounts, props, stakes }: State
): Actions => {
  const createProp: Actions['createProp'] = async (prop) => {
    await govt.connect(actor.signer).createProp(prop)
    prop.id = await govt.propCount()

    accounts[actor.signer.address].props[prop.id] = prop
    props[prop.id - 1] = prop
  }

  const mintFound: Actions['mintFound'] = async ({ amount }) => {
    await found.connect(actor.signer).mint(actor.signer.address, { value: amount })
  }

  const createStake: Actions['createStake'] = async (stake) => {
    await govt.connect(actor.signer).createStake(stake)
    stake.id = await govt.stakeCount()
    stake.startedAt = Math.floor(new Date().getTime() / 1000)
    accounts[actor.signer.address].stakes[stake.id] = stake
    stakes[stake.id - 1] = stake
  }

  const startProp: Actions['startProp'] = async (prop) => {
    await govt.connect(actor.signer).startProp(prop)
    const startedAt = Math.floor(new Date().getTime() / 1000)
    accounts[actor.signer.address].props[prop].startedAt = startedAt
    props[prop].startedAt = startedAt
  }

  const endStake: Actions['endStake'] = async (stake) => {
    await govt.connect(actor.signer).endStake(stake.id)
    const { interest, penalty } = await govt.getStake(stake.id)

    const endedAt = Math.floor(new Date().getTime() / 1000)

    accounts[actor.signer.address].stakes[stake.id].endedAt = endedAt
    accounts[actor.signer.address].stakes[stake.id].interest = interest
    accounts[actor.signer.address].stakes[stake.id].penalty = penalty
    stakes[stake.id - 1].endedAt = endedAt
    stakes[stake.id - 1].interest = interest
    stakes[stake.id - 1].penalty = penalty
  }

  return {
    endStake,
    createProp,
    createStake,
    mintFound,
    startProp
  }
}
