import { describe, it, expect } from 'vitest'
import { logger } from './colors'

describe('colors utility', () => {
  it('should have logger methods', () => {
    expect(typeof logger.info).toBe('function')
    expect(typeof logger.success).toBe('function')
    expect(typeof logger.warn).toBe('function')
    expect(typeof logger.error).toBe('function')
    expect(typeof logger.step).toBe('function')
    expect(typeof logger.dim).toBe('function')
  })
})
