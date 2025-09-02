import { describe, it, expect } from 'vitest'
import { formatStatusLine, statusColors, logger } from './colors'

describe('colors utility', () => {
  it('should format status line with all components', () => {
    const result = formatStatusLine('12:34:56', 'Sonnet 4', 'main', '$1.23 today')
    expect(result).toContain('🕐 12:34:56')
    expect(result).toContain('🤖 Sonnet 4')
    expect(result).toContain('🌿 main')
    expect(result).toContain('💰 $1.23 today')
    expect(result).toContain('\\033[') // ANSI color code
  })

  it('should have status colors defined', () => {
    expect(statusColors).toHaveProperty('time')
    expect(statusColors).toHaveProperty('model')
    expect(statusColors).toHaveProperty('git')
    expect(statusColors).toHaveProperty('cost')
    expect(statusColors).toHaveProperty('reset')
  })

  it('should have logger methods', () => {
    expect(typeof logger.info).toBe('function')
    expect(typeof logger.success).toBe('function')
    expect(typeof logger.warn).toBe('function')
    expect(typeof logger.error).toBe('function')
    expect(typeof logger.step).toBe('function')
    expect(typeof logger.dim).toBe('function')
  })
})