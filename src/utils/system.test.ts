import { describe, it, expect } from 'vitest'
import { isMacOS, commandExists, getSystemInfo } from './system'

describe('system utilities', () => {
  it('should detect macOS correctly', () => {
    const result = isMacOS()
    expect(typeof result).toBe('boolean')
  })

  it('should check command existence', async () => {
    const exists = await commandExists('echo')
    expect(typeof exists).toBe('boolean')
    expect(exists).toBe(true)

    const notExists = await commandExists('this-command-definitely-does-not-exist-12345')
    expect(typeof notExists).toBe('boolean')
    expect(notExists).toBe(false)
  })

  it('should get system info', async () => {
    const info = await getSystemInfo()
    expect(info).toHaveProperty('platform')
    expect(info).toHaveProperty('isMacOS')
    expect(info).toHaveProperty('homebrew')
    expect(info).toHaveProperty('jq')
    expect(typeof info.isMacOS).toBe('boolean')
    expect(typeof info.homebrew).toBe('boolean')
  })
})
