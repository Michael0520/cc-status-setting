import { green, yellow, red } from 'kolorist'
import { logger } from '../utils/colors'
import { fileExists, paths } from '../utils/fs'
import { getSystemInfo, commandExists } from '../utils/system'

interface TestOptions {
  verbose?: boolean
}

export async function testCommand(options: TestOptions = {}) {
  console.log()
  console.log(green('🧪 Claude Code Status Line - Test Suite'))
  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━')
  console.log()

  let passedTests = 0
  let totalTests = 0

  function runTest(name: string, fn: () => Promise<boolean> | boolean) {
    return async () => {
      totalTests++
      logger.step(`Testing ${name}...`)
      
      try {
        const result = await fn()
        if (result) {
          logger.success(`${name} ✅`)
          passedTests++
        } else {
          logger.error(`${name} ❌`)
        }
        return result
      } catch (error) {
        logger.error(`${name} ❌ - ${error instanceof Error ? error.message : String(error)}`)
        return false
      }
    }
  }

  // Test 1: System requirements
  await runTest('System requirements', async () => {
    const systemInfo = await getSystemInfo()
    if (options.verbose) {
      console.log(`  Platform: ${systemInfo.platform}`)
      console.log(`  macOS: ${systemInfo.isMacOS}`)
    }
    return systemInfo.isMacOS
  })

  // Test 2: Required files
  await runTest('Required files exist', async () => {
    const statuslineExists = await fileExists(paths.statusline)
    const settingsExists = await fileExists(paths.settings)
    
    if (options.verbose) {
      console.log(`  statusline-command.sh: ${statuslineExists}`)
      console.log(`  settings.json: ${settingsExists}`)
    }
    
    return statuslineExists && settingsExists
  })

  // Test 3: Dependencies
  await runTest('Dependencies installed', async () => {
    const hasJq = await commandExists('jq')
    const hasBrew = await commandExists('brew')
    const hasCcusage = await commandExists('ccusage')
    
    if (options.verbose) {
      console.log(`  Homebrew: ${hasBrew}`)
      console.log(`  jq: ${hasJq}`)
      console.log(`  ccusage: ${hasCcusage}`)
    }
    
    return hasJq && hasBrew
  })

  // Test 4: Status line script
  await runTest('Status line script execution', async () => {
    try {
      const testJson = JSON.stringify({ model: { display_name: 'Test Model' } })
      const { execa } = await import('execa')
      const { stdout } = await execa('bash', [paths.statusline], {
        input: testJson,
        timeout: 5000,
      })

      const hasCorrectFormat = stdout.includes('🕐') && 
                              stdout.includes('🤖') && 
                              stdout.includes('🌿') && 
                              stdout.includes('💰')

      if (options.verbose) {
        console.log(`  Output: ${stdout}`)
        console.log(`  Format check: ${hasCorrectFormat}`)
      }

      return hasCorrectFormat
    } catch {
      return false
    }
  })

  // Test 5: Claude settings
  await runTest('Claude Code settings', async () => {
    try {
      const { readJsonFile } = await import('../utils/fs')
      const settings = await readJsonFile(paths.settings)
      
      const hasStatusLine = settings?.statusLine?.type === 'command' &&
                           settings?.statusLine?.command?.includes('statusline-command.sh')

      if (options.verbose) {
        console.log(`  Has statusLine config: ${hasStatusLine}`)
        console.log(`  Command: ${settings?.statusLine?.command}`)
      }

      return hasStatusLine
    } catch {
      return false
    }
  })

  // Results
  console.log()
  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━')
  console.log(`Tests passed: ${passedTests}/${totalTests}`)
  
  if (passedTests === totalTests) {
    console.log(green('✅ All tests passed!'))
    console.log()
    console.log('Your Claude Code status line is working correctly.')
    console.log(yellow('💡 If you don\'t see the status line, try restarting Claude Code.'))
  } else {
    console.log(red(`❌ ${totalTests - passedTests} tests failed`))
    console.log()
    console.log(yellow('💡 Troubleshooting suggestions:'))
    console.log('1. Run `claude-status install --force` to reinstall')
    console.log('2. Check if you have proper permissions')
    console.log('3. Ensure Claude Code is properly installed')
  }
  
  console.log()
}