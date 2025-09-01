import { platform } from 'node:os'
import { execa } from 'execa'

export function isMacOS(): boolean {
  return platform() === 'darwin'
}

export async function commandExists(command: string): Promise<boolean> {
  try {
    await execa('which', [command])
    return true
  }
  catch {
    return false
  }
}

export async function getSystemInfo() {
  const isMac = isMacOS()
  const hasHomebrew = await commandExists('brew')
  const hasJq = await commandExists('jq')
  const hasCcusage = await commandExists('ccusage')
  const hasGit = await commandExists('git')
  
  return {
    platform: platform(),
    isMacOS: isMac,
    homebrew: hasHomebrew,
    jq: hasJq,
    ccusage: hasCcusage,
    git: hasGit,
  }
}

export async function installWithBrew(packageName: string): Promise<void> {
  await execa('brew', ['install', packageName], {
    stdio: 'inherit',
  })
}

export async function installHomebrew(): Promise<void> {
  const script = '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
  await execa('bash', ['-c', script], {
    stdio: 'inherit',
  })
  
  // Add Homebrew to PATH for current session
  const brewPaths = ['/opt/homebrew/bin/brew', '/usr/local/bin/brew']
  
  for (const brewPath of brewPaths) {
    try {
      await execa(brewPath, ['--version'])
      const { stdout } = await execa(brewPath, ['shellenv'])
      // Apply shellenv to current process
      const envVars = stdout.split('\n').filter(line => line.startsWith('export'))
      for (const envVar of envVars) {
        const [, key, value] = envVar.match(/export ([^=]+)="([^"]*)"/) || []
        if (key && value) {
          process.env[key] = value
        }
      }
      break
    }
    catch {
      // Continue to next path
    }
  }
}