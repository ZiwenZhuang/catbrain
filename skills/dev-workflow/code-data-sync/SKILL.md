---
name: code-data-sync
description: Synchronize project code and training data between the local machine and SSH-accessible hosts using named transfer targets. Use for uploads, downloads, and latest training-run retrieval.
---

# Code Data Synchronization

`code-data-sync` synchronizes project code and training data between this machine and SSH-accessible hosts. Run [code-data-sync-setup.sh](code-data-sync-setup.sh) from this folder. See [code-data-sync-setup.md](code-data-sync-setup.md) for the setup guide and [sync-config.json.example](sync-config.json.example) for sample targets.

## Configuration

The script reads `sync-config.json` beside itself, or the file specified by `SYNC_CONFIG`. The local config is Git-ignored because it contains machine-specific paths and may contain credentials. Each named target has a `type` (`code`, `data`, or `code,data`), an SSH host alias, and absolute local and remote directories. Optional `ignore_symlinks: true` excludes symbolic links during full transfers; optional `password` enables `sshpass` instead of key-based SSH.

```json
{
  "training_runs": {
    "type": "data",
    "ssh_host": "my-cluster",
    "local_dir": "/path/to/local/training",
    "remote_dir": "/path/to/remote/training",
    "ignore_symlinks": false
  }
}
```

Run the script with no arguments for interactive setup, or copy `sync-config.json.example` to `sync-config.json` and edit it. The existing local config contains machine-specific targets; use `--list` to see their current names and paths rather than relying on a copied list. Keep the config private, especially if it contains plaintext passwords; SSH keys are preferable.

## Commands

Run from this skill directory. To use a config elsewhere, set `SYNC_CONFIG` to its absolute path:

```bash
./code-data-sync-setup.sh --list
./code-data-sync-setup.sh --status
./code-data-sync-setup.sh --upload instinctlab
./code-data-sync-setup.sh --download training_runs
./code-data-sync-setup.sh --upload-all code
./code-data-sync-setup.sh --download-all data
./code-data-sync-setup.sh --download-latest training_runs
./code-data-sync-setup.sh --download-latest training_runs 'experiment_01' --ckpt-every 5000
./code-data-sync-setup.sh --help
```

- `--upload` and `--download` transfer one named target. The `--all` variants select every target whose `type` includes the requested `code` or `data` value.
- Full transfers use `scp -r` by default. With `ignore_symlinks: true`, they use a `tar` stream over SSH that omits symbolic links. They create the destination directory and copy into it; they do **not** remove extra files already there.
- `--download-latest` searches under the target's `remote_dir` for run directories containing `events.out.tfevents.*`, selects the run whose event file has the newest modification time, and downloads it with `rsync` under the same relative path in `local_dir`. An optional regex filters relative run paths.
- `--ckpt-every N` on `--download-latest` omits `model_<iteration>.pt` checkpoints not divisible by `N`, but keeps the numerically first and last checkpoints. It filters the transfer; it does not clean up previously downloaded local files.
- `--status` checks SSH reachability. It does not verify directory contents or preview a transfer.

## Before transferring

Confirm the target name and paths with `--list`, then check SSH with `--status`. The host alias must be available in `~/.ssh/config`. The script needs Bash, Python 3, SSH/SCP, and `tar` for symlink-ignoring full transfers; latest-run downloads additionally need Python 3 on the remote host and `rsync`. Password-based targets need `sshpass`. There is no built-in dry-run, so inspect the target paths before running an upload or download.
