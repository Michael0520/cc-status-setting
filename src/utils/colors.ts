import { cyan, dim, green, red, yellow } from 'kolorist'

export const logger = {
  info: (message: string) => console.log(cyan('ℹ'), message),
  success: (message: string) => console.log(green('✓'), message),
  warn: (message: string) => console.log(yellow('⚠'), message),
  error: (message: string) => console.log(red('✗'), message),
  step: (message: string) => console.log(cyan('→'), message),
  dim: (message: string) => console.log(dim(message)),
}

export const statusColors = {
  time: '\\033[90m',     // Light gray
  model: '\\033[35m',    // Purple  
  git: '\\033[32m',      // Green
  cost: '\\033[33m',     // Yellow
  reset: '\\033[0m',     // Reset
} as const

export function formatStatusLine(
  time: string,
  model: string, 
  git: string,
  cost: string,
): string {
  return `${statusColors.time}🕐 ${time}${statusColors.reset} | ${statusColors.model}🤖 ${model}${statusColors.reset} | ${statusColors.git}🌿 ${git}${statusColors.reset} | ${statusColors.cost}💰 ${cost}${statusColors.reset}`
}