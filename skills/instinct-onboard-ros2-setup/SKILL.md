---
name: instinct-onboard-ros2-setup
description: Install or troubleshoot instinct_onboard with ROS2 and colcon dependencies on development machines or deployment robots.
---

# instinct_onboard ROS2 Setup

## Select the target

Inspect the target checkout's `instinct_onboard.sh`, `setup.py`, and README; worktrees and deployed revisions may differ.

- Development: follow the [development layout](../dev-workflow/dev-machine-layout.md). Use `~/workspace/<name>_ws/instinct_onboard` as a symlink to source, including source in an auto-sync folder; keep colcon builds and environments local.
- Deployment: follow the [deployment layout](../dev-workflow/dep-machine-layout.md) on the actual robot.

## Setup

Choose the installed ROS distro, a dedicated environment separate from `instinctlab`, and CPU or GPU OpenCV. Resolve unspecified choices with the user.

Run from the selected source entry:

| Command | Purpose |
| --- | --- |
| `./instinct_onboard.sh -c [NAME]` | Create Conda environment; prompts for omitted name. Maps Humble to Python 3.10 and Jazzy to 3.12. |
| `./instinct_onboard.sh -i` | Install into the active environment; prompts about CPU OpenCV. |
| `./instinct_onboard.sh -r` | Install apt dependencies and build `ros2_numpy` and `motion_target_msgs`. |
| `./instinct_onboard.sh -f` / `-p` | Run pre-commit / the environment's Python. |

Export `ROS_DISTRO` for the full sequence (default `humble`). Create and activate the environment before `-i`; for uv/venv, create it manually and skip `-c`. Verify the selected interpreter is compatible with ROS.

Before `-r`, inspect its computed sibling `colcon_ws` path and existing package links. It must target the selected workspace, including when source is symlinked. If it does not, use the checkout README's manual colcon procedure there. `-r` performs installations and changes links; it is not a path probe.

Activate in order: Python environment → `/opt/ros/$ROS_DISTRO/setup.bash` → the workspace's `colcon_ws/install/setup.bash`. Use an explicit workspace path in the machine's activation script.

For package-specific details, read [dependency notes](instinct-onboard-ros2-setup.md). The target checkout's README is the manual setup reference.
