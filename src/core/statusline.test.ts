import { describe, it, expect } from 'vitest'
import { statuslineTemplate, defaultConfig, createStatuslineScript } from './statusline'

describe('statusline core', () => {
  it('should have statusline template with expected content', () => {
    expect(statuslineTemplate).toContain('#!/bin/bash')
    expect(statuslineTemplate).toContain('TIME=$(date +%H:%M:%S)')
    expect(statuslineTemplate).toContain('git branch --show-current')
    expect(statuslineTemplate).toContain('ccusage statusline')
    expect(statuslineTemplate).toContain('echo -e')
  })

  it('should have default config with all options enabled', () => {
    expect(defaultConfig).toEqual({
      showTime: true,
      showModel: true,
      showGit: true,
      showCost: true,
      colors: {
        time: expect.any(String),
        model: expect.any(String),
        git: expect.any(String),
        cost: expect.any(String),
      },
    })
  })

  it('should export createStatuslineScript function', () => {
    expect(typeof createStatuslineScript).toBe('function')
  })
})