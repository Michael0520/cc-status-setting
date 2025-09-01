import { green, cyan, yellow, red } from 'kolorist'
import prompts from 'prompts'
import { unlink } from 'node:fs/promises'
import glob from 'fast-glob'
import { logger } from '../utils/colors'
import { fileExists, paths, readJsonFile, writeJsonFile } from '../utils/fs'

interface UninstallOptions {
  keepBackup?: boolean
}

interface ClaudeSettings {
  statusLine?: {
    type: string
    command: string
  }
  [key: string]: any
}

export async function uninstallCommand(options: UninstallOptions = {}) {
  console.log()
  console.log(red('🗑️  Uninstall Claude Code Status Line'))
  console.log(cyan('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━'))
  console.log()

  try {
    // Confirm uninstallation
    const { shouldUninstall } = await prompts({
      type: 'confirm',
      name: 'shouldUninstall',
      message: 'Are you sure you want to uninstall the status line?',
      initial: false
    })

    if (!shouldUninstall) {
      logger.info('Uninstallation cancelled')
      return
    }

    let removedItems = 0

    // Remove statusline script
    if (await fileExists(paths.statusline)) {
      logger.step('Removing status line script...')
      await unlink(paths.statusline)
      logger.success('Status line script removed')
      removedItems++
    }

    // Remove configuration file
    const configPath = `${paths.claude}/config.json`
    if (await fileExists(configPath)) {
      logger.step('Removing configuration...')
      await unlink(configPath)
      logger.success('Configuration removed')
      removedItems++
    }

    // Update Claude Code settings
    if (await fileExists(paths.settings)) {
      logger.step('Updating Claude Code settings...')
      
      const settings = await readJsonFile<ClaudeSettings>(paths.settings)
      if (settings?.statusLine) {
        // Remove statusLine configuration
        delete settings.statusLine
        await writeJsonFile(paths.settings, settings)
        logger.success('Claude Code settings updated')
        removedItems++
      } else {
        logger.info('No status line configuration found in settings')
      }
    }

    // Handle backup files
    if (!options.keepBackup) {
      const { shouldRemoveBackups } = await prompts({
        type: 'confirm',
        name: 'shouldRemoveBackups',
        message: 'Remove backup files as well?',
        initial: false
      })

      if (shouldRemoveBackups) {
        logger.step('Finding backup files...')
        const backupFiles = await glob(`${paths.settings}.backup.*`)
        
        if (backupFiles.length > 0) {
          logger.step(`Removing ${backupFiles.length} backup files...`)
          for (const backupFile of backupFiles) {
            await unlink(backupFile)
          }
          logger.success(`${backupFiles.length} backup files removed`)
          removedItems += backupFiles.length
        } else {
          logger.info('No backup files found')
        }
      } else {
        const backupFiles = await glob(`${paths.settings}.backup.*`)
        if (backupFiles.length > 0) {
          console.log()
          logger.info(`${backupFiles.length} backup files preserved:`)
          backupFiles.forEach(file => {
            console.log(`  ${file.replace(paths.home, '~')}`)
          })
        }
      }
    }

    // Show restoration option
    const backupFiles = await glob(`${paths.settings}.backup.*`)
    if (backupFiles.length > 0) {
      const { shouldRestore } = await prompts({
        type: 'confirm',
        name: 'shouldRestore',
        message: 'Restore from a backup file?',
        initial: false
      })

      if (shouldRestore) {
        const backupChoices = backupFiles.map(file => ({
          title: file.replace(paths.home, '~'),
          value: file
        }))

        const { selectedBackup } = await prompts({
          type: 'select',
          name: 'selectedBackup',
          message: 'Choose backup to restore:',
          choices: backupChoices
        })

        if (selectedBackup) {
          const backupContent = await readJsonFile(selectedBackup)
          if (backupContent) {
            await writeJsonFile(paths.settings, backupContent)
            logger.success('Settings restored from backup')
          }
        }
      }
    }

    // Final message
    console.log()
    console.log(green('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━'))
    if (removedItems > 0) {
      console.log(green('✅ Uninstallation Complete!'))
      console.log(`Removed ${removedItems} items`)
    } else {
      console.log(yellow('⚠️  Nothing to uninstall'))
      console.log('Status line was not found or already removed')
    }
    console.log(green('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━'))
    console.log()
    
    console.log(yellow('📝 Next steps:'))
    console.log('1. Restart Claude Code to see changes')
    console.log('2. Dependencies (jq, ccusage) are still installed')
    console.log('3. Run `claude-status install` to reinstall if needed')
    console.log()

  } catch (error) {
    logger.error(`Uninstallation failed: ${error instanceof Error ? error.message : String(error)}`)
    process.exit(1)
  }
}