import { green, cyan, yellow } from 'kolorist'
import prompts from 'prompts'
import { logger } from '../utils/colors'
import { fileExists, paths, readJsonFile, writeJsonFile, createBackup } from '../utils/fs'
import { getSystemInfo, installHomebrew, installWithBrew, commandExists } from '../utils/system'
import { createStatuslineScript } from '../core/statusline'

interface InstallOptions {
  force?: boolean
  config?: string
}

interface ClaudeSettings {
  statusLine?: {
    type: string
    command: string
  }
  [key: string]: any
}

export async function installCommand(options: InstallOptions = {}) {
  console.log()
  console.log(green('🚀 Claude Code Status Line Setup'))
  console.log(cyan('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━'))
  console.log()

  try {
    // Step 1: System verification
    logger.step('Checking system requirements...')
    const systemInfo = await getSystemInfo()
    
    if (!systemInfo.isMacOS) {
      logger.error('This tool is designed for macOS only')
      process.exit(1)
    }
    
    logger.success('Running on macOS')

    // Step 2: Check for existing installation
    if (!options.force && await fileExists(paths.statusline)) {
      const { shouldContinue } = await prompts({
        type: 'confirm',
        name: 'shouldContinue',
        message: 'Status line already installed. Continue anyway?',
        initial: false,
      })
      
      if (!shouldContinue) {
        logger.info('Installation cancelled')
        return
      }
    }

    // Step 3: Install dependencies
    logger.step('Installing dependencies...')
    
    // Install Homebrew if needed
    if (!systemInfo.homebrew) {
      logger.step('Installing Homebrew...')
      await installHomebrew()
      logger.success('Homebrew installed')
    } else {
      logger.success('Homebrew already installed')
    }

    // Install jq
    if (!systemInfo.jq) {
      logger.step('Installing jq...')
      await installWithBrew('jq')
      logger.success('jq installed')
    } else {
      logger.success('jq already installed')
    }

    // Install ccusage
    if (!systemInfo.ccusage) {
      logger.step('Installing ccusage for cost tracking...')
      try {
        await installWithBrew('ccusage')
        logger.success('ccusage installed')
      } catch {
        logger.warn('Failed to install ccusage - cost tracking will show N/A')
        logger.dim('You can install it manually later: brew install ccusage')
      }
    } else {
      logger.success('ccusage already installed')
    }

    // Step 4: Create backup
    if (await fileExists(paths.settings)) {
      logger.step('Creating backup...')
      const backupPath = await createBackup(paths.settings)
      logger.success(`Settings backed up to ${backupPath.replace(paths.home, '~')}`)
    }

    // Step 5: Create statusline script
    logger.step('Creating status line script...')
    await createStatuslineScript()
    logger.success('Status line script created')

    // Step 6: Update Claude Code settings
    logger.step('Updating Claude Code settings...')
    
    const existingSettings = await readJsonFile<ClaudeSettings>(paths.settings) || {}
    
    const newSettings: ClaudeSettings = {
      ...existingSettings,
      statusLine: {
        type: 'command',
        command: `bash ${paths.statusline}`,
      },
    }

    await writeJsonFile(paths.settings, newSettings)
    logger.success('Claude Code settings updated')

    // Step 7: Test installation
    logger.step('Testing installation...')
    const testResult = await testStatusline()
    
    if (testResult.success) {
      logger.success('Installation test passed')
    } else {
      logger.warn(`Test warning: ${testResult.error}`)
    }

    // Success message
    console.log()
    console.log(green('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━'))
    console.log(green('✅ Installation Complete!'))
    console.log(green('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━'))
    console.log()
    console.log(cyan('Your status line will show:'))
    console.log('🕐 Time | 🤖 Claude Model | 🌿 Git Branch | 💰 Daily Cost')
    console.log()
    console.log(yellow('📝 Next steps:'))
    console.log('1. Restart Claude Code to see the new status line')
    console.log('2. Run `claude-status test` to verify everything works')
    console.log('3. Run `claude-status config` to customize settings')
    console.log()

  } catch (error) {
    logger.error(`Installation failed: ${error instanceof Error ? error.message : String(error)}`)
    console.log()
    console.log(yellow('💡 Troubleshooting:'))
    console.log('1. Ensure you have admin privileges')
    console.log('2. Check your internet connection')
    console.log('3. Run `claude-status test` for more details')
    process.exit(1)
  }
}

async function testStatusline() {
  try {
    if (!await commandExists('jq')) {
      return { success: false, error: 'jq not found' }
    }

    // Test with sample JSON
    const testJson = JSON.stringify({ model: { display_name: 'Test Model' } })
    const { execa } = await import('execa')
    const { stdout } = await execa('bash', [paths.statusline], {
      input: testJson,
      timeout: 5000,
    })

    if (stdout.includes('🕐') && stdout.includes('🤖')) {
      return { success: true }
    } else {
      return { success: false, error: 'Unexpected output format' }
    }
  } catch (error) {
    return { 
      success: false, 
      error: error instanceof Error ? error.message : 'Unknown error' 
    }
  }
}