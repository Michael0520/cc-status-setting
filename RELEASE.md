# Release Guide

This project uses automated release workflow inspired by [@antfu](https://github.com/antfu).

## Quick Release (Recommended)

```bash
pnpm release
```

This will:
1. ✅ Run `bumpp` to update version (interactive prompt)
2. ✅ Create git commit and tag
3. ✅ **Build and publish to npm** (via `prepublishOnly`)
4. ✅ Push tag to GitHub
5. ✅ **GitHub Actions automatically** generates changelog with `changelogithub`

## Setup (First Time Only)

### 1. Configure Git (if not already)

```bash
git config user.name "Michael0520"
git config user.email "michael860520@gmail.com"
```

## Manual Steps (if needed)

### Update Version Only
```bash
npx bumpp
```

### Build Locally
```bash
pnpm run build
```

### Test Before Release
```bash
pnpm run test
pnpm run typecheck
pnpm run lint
```

## Release Types

When running `pnpm release`, you'll be prompted:

- **patch** (2.0.4 → 2.0.5) - Bug fixes
- **minor** (2.0.4 → 2.1.0) - New features
- **major** (2.0.4 → 3.0.0) - Breaking changes

## Workflow (antfu's approach)

```
Local: pnpm release
  ↓
bumpp: Update version → Commit → Tag
  ↓
pnpm publish: Build (prepublishOnly) → Publish to npm
  ↓
bumpp: Push tag to GitHub
  ↓
GitHub Actions: Generate changelog (changelogithub)
  ↓
Done: Check https://github.com/Michael0520/cc-status-setting/releases
```

**Key difference from typical CI/CD:**
- ✅ Publishing happens **locally** (more control, faster)
- ✅ CI only generates changelog (lightweight)

## Troubleshooting

### npm publish failed?

Common issues:
- ❌ Not logged in → Run `npm login`
- ❌ Build failed → Check `pnpm run build` locally
- ❌ Tests failed → Run `pnpm test` first
- ❌ Version already exists → Bump version again

### Changelog not generated?

Check GitHub Actions:
https://github.com/Michael0520/cc-status-setting/actions

- ❌ Tag not pushed → Check `git push --tags`
- ❌ Workflow failed → Check GITHUB_TOKEN permissions

### Rollback a Release

```bash
# Delete tag locally
git tag -d v2.0.5

# Delete tag on GitHub
git push origin :refs/tags/v2.0.5

# Unpublish from npm (within 72 hours)
npm unpublish @michael0520/claude-status@2.0.5
```

## Best Practices

1. ✅ Always run tests before release: `pnpm test`
2. ✅ Check build works: `pnpm run build`
3. ✅ Use conventional commit messages
4. ✅ Update README if API changes
5. ✅ Wait for GitHub Actions to complete before announcing

---

**Reference**: This workflow is inspired by [antfu's packages](https://github.com/antfu).