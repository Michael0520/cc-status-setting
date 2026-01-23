import { cyan, dim, green, red, yellow } from 'kolorist'

export const logger = {
  info: (message: string) => console.log(cyan('ℹ'), message),
  success: (message: string) => console.log(green('✓'), message),
  warn: (message: string) => console.log(yellow('⚠'), message),
  error: (message: string) => console.log(red('✗'), message),
  step: (message: string) => console.log(cyan('→'), message),
  dim: (message: string) => console.log(dim(message)),
}