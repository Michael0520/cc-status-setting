#!/usr/bin/env node

import process from 'node:process'
import { cac } from 'cac'
import { cyan, green } from 'kolorist'
import { version } from '../package.json'
import { installCommand } from './commands/install'
import { configCommand } from './commands/config'
import { testCommand } from './commands/test'
import { uninstallCommand } from './commands/uninstall'

const cli = cac('claude-status')

cli
  .version(version)
  .help()

cli
  .command('install', 'Install Claude Code status line')
  .option('--force', 'Force reinstall even if already installed')
  .option('--config <config>', 'Custom configuration file path')
  .action(installCommand)

cli
  .command('config', 'Configure status line settings')
  .option('--reset', 'Reset to default configuration')
  .action(configCommand)

cli
  .command('test', 'Test current installation')
  .option('--verbose', 'Show detailed test output')
  .action(testCommand)

cli
  .command('uninstall', 'Remove Claude Code status line')
  .option('--keep-backup', 'Keep backup files')
  .action(uninstallCommand)

// Global error handler
process.on('uncaughtException', (error) => {
  console.error(cyan('❌ Unexpected error:'), error.message)
  process.exit(1)
})

process.on('unhandledRejection', (error) => {
  console.error(cyan('❌ Unhandled promise rejection:'), error)
  process.exit(1)
})

// Add default command for when no arguments are provided
cli
  .command('[...args]', '', { ignoreOptionDefaultValue: true })
  .action(async (args) => {
    if (args.length === 0) {
      console.log(green('🚀 Starting Claude Code status line installation...'))
      await installCommand({ force: false })
    }
  })

// Parse CLI arguments
cli.parse()