
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
  const length = props?.length || 12

  for (let i = 0; i < length; i += 1) {
    result += chars.charAt(Math.floor(Math.random() * charsLength))
  }

  return result
}

export const pickRandom = (arr: any[]): typeof arr[number] => (
  arr[Math.floor(Math.random() * arr.length)]
)
