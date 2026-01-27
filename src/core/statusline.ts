import { cp, mkdir, chmod } from 'node:fs/promises'
import { join, dirname } from 'node:path'
import { fileURLToPath } from 'node:url'
import { paths } from '../utils/fs'

/**
 * Install lightweight statusline v3.0.0
 * Copies statusline.sh from the package to ~/.claude/statusline
 */
export async function installStatuslineSystem(): Promise<void> {
  // Find the statusline directory in the package
  // The statusline directory should be at the package root
  // When built: dist/ is created, but statusline/ stays at root
  // So from dist/index.js, we need to go up one level to find statusline/

  // Get the directory containing the compiled code (dist/)
  const distDir = dirname(fileURLToPath(import.meta.url))

  // Go up one level to the package root
  const packageRoot = join(distDir, '..')

  // The statusline directory is in the package root
  const statuslineSource = join(packageRoot, 'statusline')

  // Create target directory
  await mkdir(paths.statuslineDir, { recursive: true })

  // Copy entire statusline directory
  await cp(statuslineSource, paths.statuslineDir, {
    recursive: true,
    force: true,
  })

  // Make statusline.sh executable
  const statuslineScript = join(paths.statuslineDir, 'statusline.sh')
  await chmod(statuslineScript, 0o755)
}