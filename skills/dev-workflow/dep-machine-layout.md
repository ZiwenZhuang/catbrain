# Deployment Machine Layout

Inspect the actual robot's checkout and environment. For development workspaces with linked source, use [dev-machine-layout.md](dev-machine-layout.md). If a machine serves both roles, resolve layout conflicts before making changes.

## Workspace

Give each deployment project a `<name>_ws` workspace. Preserve existing shared locations; ask where a new workspace belongs if unspecified.

```text
<name>_ws/
├── deploy_code/                    # e.g. instinct_onboard
│   └── activate_in_<machine-name>.sh
├── <project-name>-uvenv/           # Optional project-local environment
├── deploy_logs/                    # All deployment running logs
└── colcon_ws/                     # Only when building ROS packages
    └── src/
        └── motion_target_msgs -> ../../deploy_code/motion_target_msgs
```

Use the actual project/package names. Symlink message packages from the checkout rather than copying them.

## Environments and dependencies

- Prefer a dedicated Conda environment in Conda's managed location. Otherwise use uv, or retain an existing venv, in the workspace (not inside `deploy_code`).
- For development source in auto-sync folders, keep environments outside that source as described in the development guide.
- Reuse compatible dependencies and respect project version constraints. Install missing dependencies in the isolated environment; avoid unrelated upgrades.
- Explain and obtain approval for `sudo` installations unless already authorized. Stop on system-package conflicts until a resolution is agreed.

Keep `activate_in_<machine-name>.sh` in the project; it selects the environment and ROS setup. It is typically rsynced with deployment code, so verify its paths on the robot.

After setup, check environment activation, package links, and relevant builds on the target machine. Running a robot policy requires authorization for that operation; follow [real-robot-deployment.md](real-robot-deployment.md).
