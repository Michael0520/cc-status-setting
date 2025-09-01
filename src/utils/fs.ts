import { readFile, writeFile, access, mkdir, copyFile } from 'node:fs/promises'
import { constants } from 'node:fs'
import { dirname, join } from 'node:path'
import { homedir } from 'node:os'

export const paths = {
  home: homedir(),
  claude: join(homedir(), '.claude'),
  settings: join(homedir(), '.claude', 'settings.json'),
  statusline: join(homedir(), '.claude', 'statusline-command.sh'),
} as const

export async function fileExists(path: string): Promise<boolean> {
  try {
    await access(path, constants.F_OK)
    return true
  }
  catch {
    return false
  }
}

export async function ensureDir(path: string): Promise<void> {
  const dir = dirname(path)
  await mkdir(dir, { recursive: true })
}

export async function readJsonFile<T = any>(path: string): Promise<T | null> {
  try {
    const content = await readFile(path, 'utf-8')
    return JSON.parse(content) as T
  }
  catch {
    return null
  }
}

export async function writeJsonFile(path: string, data: any): Promise<void> {
  await ensureDir(path)
  await writeFile(path, JSON.stringify(data, null, 2), 'utf-8')
}

export async function createBackup(originalPath: string): Promise<string> {
  const timestamp = new Date().toISOString().replace(/[:.]/g, '-').split('T')
  const backupPath = `${originalPath}.backup.${timestamp[0]}_${timestamp[1]?.split('.')[0]?.replace(/-/g, '') || 'unknown'}`
  
  if (await fileExists(originalPath)) {
    await copyFile(originalPath, backupPath)
  }
  
  return backupPath
}