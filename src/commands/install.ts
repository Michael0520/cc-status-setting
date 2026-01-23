import { green, cyan, yellow } from 'kolorist'
import prompts from 'prompts'
import { logger } from '../utils/colors'
import { fileExists, paths, readJsonFile, writeJsonFile } from '../utils/fs'
import { getSystemInfo, installHomebrew, installWithBrew } from '../utils/system'
import { installStatuslineSystem } from '../core/statusline'

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
    if (!options.force && await fileExists(paths.statuslineDir)) {
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

    // Step 3: Install jq dependency
    logger.step('Checking dependencies...')

    if (!systemInfo.homebrew) {
      logger.step('Installing Homebrew...')
      await installHomebrew()
      logger.success('Homebrew installed')
    } else {
      logger.success('Homebrew available')
    }

    if (!systemInfo.jq) {
      logger.step('Installing jq...')
      await installWithBrew('jq')
      logger.success('jq installed')
    } else {
      logger.success('jq available')
    }

    // Step 4: Backup existing statusline
    if (await fileExists(paths.statuslineDir)) {
      logger.step('Backing up existing statusline...')
      const timestamp = new Date().toISOString().replace(/[:.]/g, '-').split('T').join('_').split('.')[0]
      const backupPath = `${paths.statuslineDir}.backup.${timestamp}`
      const { execa } = await import('execa')
      await execa('mv', [paths.statuslineDir, backupPath])
      logger.success(`Backup: ${backupPath.replace(paths.home, '~')}`)
    }

    // Step 5: Install statusline system
    logger.step('Installing statusline v2.14.0...')
    await installStatuslineSystem()
    logger.success('Statusline installed')

    // Step 6: Update Claude Code settings
    logger.step('Updating settings...')

    const existingSettings = await readJsonFile<ClaudeSettings>(paths.settings) || {}

    const newSettings: ClaudeSettings = {
      ...existingSettings,
      statusLine: {
        type: 'command',
        command: `bash ${paths.statuslineDir}/statusline.sh`,
      },
    }

    await writeJsonFile(paths.settings, newSettings)
    logger.success('Settings updated')

    // Success message
    console.log()
    console.log(green('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━'))
    console.log(green('✅ Installation Complete!'))
    console.log(green('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━'))
    console.log()
    console.log(cyan('✨ Statusline v2.14.0 Features:'))
    console.log('  • 5-line rich display')
    console.log('  • Cost tracking (5 dimensions)')
    console.log('  • MCP server monitoring')
    console.log('  • Context window usage')
    console.log('  • Catppuccin theme')
    console.log()
    console.log(yellow('⚠️  Restart Claude Code to activate'))
    console.log()
    console.log(cyan('📝 Customize:'))
    console.log(`  ${paths.statuslineDir.replace(paths.home, '~')}/Config.toml`)
    console.log()

  } catch (error) {
    logger.error(`Installation failed: ${error instanceof Error ? error.message : String(error)}`)
    console.log()
    console.log(yellow('💡 Troubleshooting:'))
    console.log('1. Ensure you have admin privileges')
    console.log('2. Check internet connection')
    console.log('3. Report issue: github.com/Michael0520/cc-status-setting')
    process.exit(1)
  }
}
