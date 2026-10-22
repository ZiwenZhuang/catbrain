# Development Machine Layout

## Directories

| Path | Purpose |
| --- | --- |
| `~/Projects` | Default source checkout location; other locations, including auto-sync folders, are also valid. |
| `~/workspace/<name>_ws/` | Machine-local project workspace, linking to source checkouts. |
| `~/Data/` | Machine-local external storage for project outputs, caches, and backups; layout under it is per project. |
| `~/Datasets/` | Shared public or generated datasets. |

Home-level entry points may be directories or symlinks to other disks or NAS storage. Preserve existing source locations.

## Workspaces

### For example developing deploy code locally

```text
~/workspace/<name>_ws/
├── instinct_onboard -> <source checkout or worktree, possibly in an auto-sync folder>
└── colcon_ws/
    ├── src/
    │   └── motion_target_msgs -> ../../instinct_onboard/motion_target_msgs
    ├── build/
    ├── install/
    └── log/
```

Keep build artifacts and machine-specific environments outside auto-sync source folders. Conda manages its own environments; uv/venv environments can live in the workspace. Edits through the source link affect the checkout and may sync to other machines.

Create source links for each machine's actual checkout location. Before running location-dependent setup scripts, verify that their colcon destination is the workspace above; otherwise use the project's manual build procedure there.

## Logs and datasets

- `~/Data` is a stable entry point, not a naming scheme. Folder names and structure under it vary by project (e.g. `<project>_logs`, `<project>_outputs`, model caches, backup archives); preserve existing names.
- Projects (or workspaces) reach their external storage only through symlinks via `~/Data`, the same way on every host. Code synced to any run host then keeps valid links once that host provides the same `~/Data/...` entries.
- Keep output directories (logs, outputs, caches) out of the checkout as real directories; link them, preserving repository naming conventions. Separate checkouts may intentionally share a target. Colcon build logs stay in its workspace.
- Link shared datasets through `~/Datasets`; keep original archives for backup.
- For one archive, place it directly under `~/Datasets` beside an extracted directory with the same base name, excluding `.zip`, `.tar.gz`, etc.
- For multiple archives, use one dataset-named directory containing all archive parts and extracted data; preserve original extracted directory names.

## Symlinks

Use relative targets through the stable `~/Data` and `~/Datasets` entry points, not their backing storage paths. For example, `~/Projects/my-project/logs` can point to `~/Data/my-project_logs`. Literal `~` is not expanded in a symlink target.

Calculate targets from the physical directory containing each link, including links inside symlinked checkouts. Recheck them after moves or synchronization to another machine.

## Applying the layout

Inspect existing storage, checkouts, and links first. Recognition alone does not require reorganizing files. When setup is requested, create the workspace and required links, ask about unresolved storage choices, and verify that links resolve correctly.
