#!/usr/bin/env node

// Generate legacy shell script from TypeScript CLI
import { readFile, writeFile } from 'fs/promises'
import { join } from 'path'

const packageRoot = join(process.cwd())
const originalShellScript = join(packageRoot, 'setup-claude-statusline.sh')
const distDir = join(packageRoot, 'dist')
const outputScript = join(distDir, 'install.sh')

async function generateShellScript() {
  console.log('📦 Generating legacy shell script...')
  
  try {
    // Read the original shell script as template
    const shellContent = await readFile(originalShellScript, 'utf-8')
    
    // Add header comment
    const header = `#!/bin/bash
# Claude Code Status Line Setup - Legacy Shell Script
# Generated from TypeScript CLI
# For modern installation, use: npx @michael0520/claude-status install

`
    
    const finalScript = header + shellContent
    
    // Write to dist directory
    await writeFile(outputScript, finalScript, 'utf-8')
    
    console.log('✅ Legacy shell script generated at dist/install.sh')
  } catch (error) {
    console.warn('⚠️ Could not generate shell script:', error.message)
    // This is not critical, so don't fail the build
  }
}

generateShellScript().catch(console.error)