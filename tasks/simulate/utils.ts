export const CHARACTERS = {
  alphaNumeric: 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789'
}

export const randomString = (props?: {
  characters?: string
  length?: number
}): string => {
  let result = ''
  const chars = props?.characters != null
    ? props.characters
    : CHARACTERS.alphaNumeric

  const charsLength = chars.length
  const length = props?.length != null ? props.length : 12

  for (let i = 0; i < length; i += 1) {
    result += chars.charAt(Math.floor(Math.random() * charsLength))
  }

  return result
}

export const shuffle = <T extends any>(arr: T[]): T[] => (
  arr.map((value) => ({ value, sort: Math.random() }))
    .sort((a, b) => a.sort - b.sort)
    .map(({ value }) => value)
)

export const pickRandom = <T extends any>(arr: T[]): T => (
  arr[Math.floor(Math.random() * arr.length)]
)

export const parseTime = (time: number): string => {
  const date = new Date(time * 1000)
  return date.toISOString()
}
