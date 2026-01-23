import { green, cyan, yellow } from 'kolorist'
import { logger } from '../utils/colors'
import { paths, fileExists } from '../utils/fs'

interface ConfigOptions {
  reset?: boolean
}

export async function configCommand(_options: ConfigOptions = {}) {
  console.log()
  console.log(green('⚙️  Configure Claude Code Status Line'))
  console.log(cyan('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━'))
  console.log()

  const configPath = `${paths.statuslineDir}/Config.toml`

  if (!await fileExists(configPath)) {
    logger.error('Statusline not installed. Run `npx @michael0520/claude-status` first.')
    process.exit(1)
  }

  console.log(cyan('📝 Configuration File:'))
  console.log(`  ${configPath.replace(paths.home, '~')}`)
  console.log()
  console.log(cyan('✨ What you can customize:'))
  console.log('  • Theme (catppuccin, ocean, garden, classic)')
  console.log('  • Display lines (1-9)')
  console.log('  • Features (cost tracking, MCP status, etc.)')
  console.log('  • Line components')
  console.log()
  console.log(yellow('📖 Available commands:'))
  console.log('  # List available themes')
  console.log(`  ${paths.statuslineDir.replace(paths.home, '~')}/statusline.sh --list-themes`)
  console.log()
  console.log('  # Preview a theme')
  console.log(`  ${paths.statuslineDir.replace(paths.home, '~')}/statusline.sh --preview-theme ocean`)
  console.log()
  console.log('  # Validate your config')
  console.log(`  ${paths.statuslineDir.replace(paths.home, '~')}/statusline.sh --validate`)
  console.log()
  console.log('  # Interactive setup wizard')
  console.log(`  ${paths.statuslineDir.replace(paths.home, '~')}/statusline.sh --setup-wizard`)
  console.log()
  console.log(cyan('💡 Tip:'))
  console.log(`  Edit ${configPath.replace(paths.home, '~')} with your favorite editor`)
  console.log('  Restart Claude Code to apply changes')
  console.log()
}
