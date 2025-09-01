import { green, cyan } from 'kolorist'
import prompts from 'prompts'
import { logger } from '../utils/colors'
import { paths, readJsonFile, writeJsonFile } from '../utils/fs'
import { defaultConfig, type StatuslineConfig } from '../core/statusline'

interface ConfigOptions {
  reset?: boolean
}

export async function configCommand(options: ConfigOptions = {}) {
  console.log()
  console.log(green('⚙️  Configure Claude Code Status Line'))
  console.log(cyan('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━'))
  console.log()

  try {
    if (options.reset) {
      // Reset to default configuration
      await writeJsonFile(`${paths.claude}/config.json`, defaultConfig)
      logger.success('Configuration reset to defaults')
      return
    }

    // Load current config
    const currentConfig = await readJsonFile<StatuslineConfig>(`${paths.claude}/config.json`) || defaultConfig

    // Interactive configuration
    const response = await prompts([
      {
        type: 'multiselect',
        name: 'features',
        message: 'What information do you want to show?',
        choices: [
          { title: '🕐 Current time', value: 'time', selected: currentConfig.showTime },
          { title: '🤖 Claude model', value: 'model', selected: currentConfig.showModel },
          { title: '🌿 Git branch', value: 'git', selected: currentConfig.showGit },
          { title: '💰 Daily cost', value: 'cost', selected: currentConfig.showCost },
        ],
        hint: 'Space to select, Enter to confirm'
      },
      {
        type: 'select',
        name: 'colorScheme',
        message: 'Choose your color scheme:',
        choices: [
          { title: 'Default (Gray, Purple, Green, Yellow)', value: 'default' },
          { title: 'Monochrome (All white)', value: 'monochrome' },
          { title: 'Bright colors', value: 'bright' },
          { title: 'Pastel colors', value: 'pastel' },
          { title: 'Custom...', value: 'custom' },
        ],
        initial: 0
      }
    ])

    if (!response.features || !response.colorScheme) {
      logger.info('Configuration cancelled')
      return
    }

    // Build new config
    const newConfig: StatuslineConfig = {
      showTime: response.features.includes('time'),
      showModel: response.features.includes('model'),
      showGit: response.features.includes('git'),
      showCost: response.features.includes('cost'),
      colors: getColorScheme(response.colorScheme)
    }

    // Handle custom colors
    if (response.colorScheme === 'custom') {
      const customColors = await prompts([
        {
          type: 'text',
          name: 'timeColor',
          message: 'Time color (ANSI code):',
          initial: '\\033[90m',
          validate: value => value.startsWith('\\033[') ? true : 'Please enter a valid ANSI color code'
        },
        {
          type: 'text',
          name: 'modelColor',
          message: 'Model color (ANSI code):',
          initial: '\\033[35m',
          validate: value => value.startsWith('\\033[') ? true : 'Please enter a valid ANSI color code'
        },
        {
          type: 'text',
          name: 'gitColor',
          message: 'Git color (ANSI code):',
          initial: '\\033[32m',
          validate: value => value.startsWith('\\033[') ? true : 'Please enter a valid ANSI color code'
        },
        {
          type: 'text',
          name: 'costColor',
          message: 'Cost color (ANSI code):',
          initial: '\\033[33m',
          validate: value => value.startsWith('\\033[') ? true : 'Please enter a valid ANSI color code'
        }
      ])

      if (customColors.timeColor) {
        newConfig.colors = {
          time: customColors.timeColor,
          model: customColors.modelColor,
          git: customColors.gitColor,
          cost: customColors.costColor,
        }
      }
    }

    // Save configuration
    await writeJsonFile(`${paths.claude}/config.json`, newConfig)
    logger.success('Configuration saved')

    // Show preview
    console.log()
    console.log(cyan('Preview:'))
    const previewParts = []
    
    if (newConfig.showTime) previewParts.push('🕐 12:34:56')
    if (newConfig.showModel) previewParts.push('🤖 Sonnet 4')
    if (newConfig.showGit) previewParts.push('🌿 main')
    if (newConfig.showCost) previewParts.push('💰 $15.67 today')
    
    console.log(previewParts.join(' | '))
    console.log()
    
    // Ask if user wants to apply changes
    const { shouldApply } = await prompts({
      type: 'confirm',
      name: 'shouldApply',
      message: 'Apply these changes now?',
      initial: true
    })

    if (shouldApply) {
      // Regenerate statusline script with new config
      await regenerateStatuslineScript(newConfig)
      logger.success('Changes applied! Restart Claude Code to see the updates.')
    } else {
      logger.info('Configuration saved but not applied. Run `claude-status install` to apply changes.')
    }

  } catch (error) {
    logger.error(`Configuration failed: ${error instanceof Error ? error.message : String(error)}`)
    process.exit(1)
  }
}

function getColorScheme(scheme: string) {
  const schemes = {
    default: {
      time: '\\033[90m',    // Gray
      model: '\\033[35m',   // Purple
      git: '\\033[32m',     // Green
      cost: '\\033[33m',    // Yellow
    },
    monochrome: {
      time: '\\033[37m',    // White
      model: '\\033[37m',   // White
      git: '\\033[37m',     // White
      cost: '\\033[37m',    // White
    },
    bright: {
      time: '\\033[96m',    // Bright Cyan
      model: '\\033[95m',   // Bright Magenta
      git: '\\033[92m',     // Bright Green
      cost: '\\033[93m',    // Bright Yellow
    },
    pastel: {
      time: '\\033[94m',    // Light Blue
      model: '\\033[95m',   // Light Magenta
      git: '\\033[92m',     // Light Green
      cost: '\\033[93m',    // Light Yellow
    }
  }

  return schemes[scheme as keyof typeof schemes] || schemes.default
}

async function regenerateStatuslineScript(_config: StatuslineConfig) {
  // This would regenerate the statusline script with the new configuration
  // For now, we'll import and use the existing function
  const { createStatuslineScript } = await import('../core/statusline')
  await createStatuslineScript()
}