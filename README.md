# Agent Harness Bundle

Installer bundle for agent-first project setup.

## Install (one line)

```bash
curl -fsSL https://raw.githubusercontent.com/talfirevic/agent-harness/main/install.sh | bash
```

The installer:
- Resolves the latest stable GitHub release.
- Compares remote `VERSION` with local `.harness-bundle-version`.
- No-ops if already current.
- Downloads `harness-bundle.tar.gz` and `sha256sums.txt`.
- Verifies checksum before extract.
- Syncs only paths listed in `MANIFEST.txt`.
- Updates `.harness-managed-files` and `.harness-bundle-version`.
- Initializes Git only if `.git` is missing.

## Quickstart in New Directory

```bash
mkdir my-project && cd my-project
curl -fsSL https://raw.githubusercontent.com/talfirevic/agent-harness/main/install.sh | bash
./scripts/harness/readiness-check.sh
./scripts/harness/check-all.sh
```

Then continue with the quickstart in `paybook.md`.

## Update Flow

Re-run the same installer command:

```bash
curl -fsSL https://raw.githubusercontent.com/talfirevic/agent-harness/main/install.sh | bash
```

Only installer-managed files are updated. Unmanaged files are untouched.

## Publishing a Release

1. Create and push a version tag:

```bash
git tag v0.1.0
git push origin v0.1.0
```

2. GitHub Actions workflow `.github/workflows/release.yml` builds and publishes:
- `harness-bundle.tar.gz`
- `sha256sums.txt`
- `VERSION`
- `MANIFEST.txt`
