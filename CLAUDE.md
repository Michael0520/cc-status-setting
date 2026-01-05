# CLAUDE.md

Project-specific instructions for Claude Code.

## Project Overview

CLI tool for managing Claude Code status line configuration on macOS.

## Tech Stack

- TypeScript + Node.js (ESM)
- CLI: `cac`
- Build: `tsup`
- Test: `vitest`
- Lint: `oxlint`
- Package Manager: `pnpm`

## Commands

```bash
pnpm dev          # Run in development
pnpm build        # Build for production
pnpm test         # Run tests
pnpm lint         # Lint code
pnpm typecheck    # Type check
```

## Release

Uses [npm Trusted Publishers](https://docs.npmjs.com/trusted-publishers) with OIDC authentication - no npm tokens required.

```bash
pnpm run release  # bumpp updates version, commits, and pushes tag
```

GitHub Actions automatically:
1. `release.yml` - Generates changelog
2. `publish.yml` - Publishes to npm via OIDC

### Trusted Publisher Config (npmjs.com)

| Field | Value |
|-------|-------|
| Organization/user | `Michael0520` |
| Repository | `cc-status-setting` |
| Workflow filename | `publish.yml` |
| Environment | (empty) |

## Project Structure

```
src/
  index.ts          # CLI entry point
  commands/         # CLI commands (install, config, test, uninstall)
  core/             # Core logic (statusline script generation)
  utils/            # Utilities (fs, system, colors)
.github/workflows/
  ci.yml            # CI: lint, typecheck, test, build
  release.yml       # Generate changelog on tag push
  publish.yml       # Publish to npm via OIDC
```
