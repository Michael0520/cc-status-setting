import { describe, it, expect } from 'vitest'
import { installStatuslineSystem } from './statusline'

describe('statusline core', () => {
  it('should export installStatuslineSystem function', () => {
    expect(typeof installStatuslineSystem).toBe('function')
  })
})
