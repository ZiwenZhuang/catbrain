# Code & Data Sync Setup

Sync project code and training data between local and remote machines via `scp`.
Each sync target is a named entry with a type, SSH host, and directory paths.

## Quick Start

```bash
# 1. Create config (interactive)
./code-data-sync-setup.sh

# 2. Upload code to remote
./code-data-sync-setup.sh --upload instinctlab

# 3. Download training data from remote
./code-data-sync-setup.sh --download training_runs
```

## Commands

| Command | Description |
|---|---|
| *(none)* | Interactive setup — create `sync-config.json` |
| `--upload <name>` | Upload a specific target to remote |
| `--download <name>` | Download a specific target from remote |
| `--download-latest <name> [pattern] [--ckpt-every N]` | Download the most recent training run folder. Optional regex filters by path. `--ckpt-every N` skips `model_*.pt` files whose iteration is not a multiple of N (always keeps first and last). |
| `--upload-all <type>` | Upload all targets matching type (`code` or `data`) |
| `--download-all <type>` | Download all targets matching type (`code` or `data`) |
| `--list` | Show configured targets |
| `--status` | Test SSH connectivity to all configured hosts |
| `--help` | Show help |

## How It Works

1. **Configuration** — Sync targets are stored in `sync-config.json` (git-ignored).
   Each target has a name, type (`code`, `data`, or `code,data`), SSH host,
   local/remote directory paths, and an optional `ignore_symlinks` flag.
   See `sync-config.json.example` for the format.

2. **Upload / Download** — Uses `scp -r` by default. When `ignore_symlinks` is
   `true`, uses `tar` piped over SSH instead to skip symbolic links.
   Creates the destination directory if needed.

3. **Bulk operations** — `--upload-all code` and `--download-all data` operate
   on every target whose `type` field contains the given keyword.

4. **Download latest** — `--download-latest <name>` SSHes into the remote, walks
   the target's `remote_dir` looking for directories containing `events.out.tfevents.*`
   files (isaaclab training runs), picks the one with the most recent mtime, and
   downloads just that folder. The relative path is preserved under `local_dir`.
   An optional regex pattern filters which run paths are considered.

## Prerequisites

- SSH host must be configured in `~/.ssh/config` with key-based auth (preferred), or set `"password"` in the target config for password-based auth via `sshpass`.
- `python3` must be available (used for JSON parsing).
- `sshpass` must be installed if any target uses password auth (`sudo apt install sshpass`).

## Manual Verification

```bash
# Check config
./code-data-sync-setup.sh --list

# Test SSH connectivity
./code-data-sync-setup.sh --status

# Inspect the remote directory (this is not a transfer dry-run)
ssh my-cluster "ls -la /home/ziwen/Projects/instinctlab"
```
