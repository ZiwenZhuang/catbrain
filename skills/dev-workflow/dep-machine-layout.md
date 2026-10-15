# Deployment Machine Layout

Use these conventions for code and runtime environments on robots that run policies in real time. Inspect the existing layout before setting up or changing a deployment workspace.

A deployment machine may also be a development machine. In that case, also read [dev-machine-layout.md](dev-machine-layout.md). If the conventions conflict for the requested change, ask the user which to apply before changing the affected paths or environment.

## 1. Deployment workspaces

Give each deployment project a dedicated workspace named `<name>_ws`. The workspace groups the project checkout and any ROS build workspace. Multiple people may use it through the same machine account, so preserve existing shared paths and environments unless changing them is part of the requested task.

Use the existing workspace location when available. If creating a new workspace and its location is not specified or evident, ask the user where it belongs.

```text
<name>_ws/
├── instinct_onboard/                   # Project checkout for an instinctlab deployment
│   ├── activate_in_<machine-name>.sh
│   └── <project-name>-uvenv/           # Only when using a project-local uv environment
└── colcon_ws/                         # Only when building ROS packages
    └── src/
        └── <message-package> -> ../../instinct_onboard/<message-package-path>
```

Use the actual project name for other deployment projects. The environment and ROS workspace entries are conditional, not directories to create for every deployment. Replace the message-package placeholders with the actual package name and its path inside the project checkout.

## 2. Runtime environments

- Prefer a dedicated Conda environment for the deployment project. Conda manages its environment directory; it does not need to live in the deployment workspace.
- If Conda is unsuitable, use a uv-managed virtual environment inside the project checkout, such as `<project-name>-uvenv/`.
- If the project already uses a standard Python virtual environment, keep it inside the project checkout, such as `<project-name>-venv/`.
- Reuse an existing compatible environment when appropriate. Inspect its dependencies before changing an environment shared by other users or deployments.

Project-local virtual environments belong inside the project checkout, rather than beside it at the workspace root.

## 3. Dependency safety

- Inspect the project's dependency declarations and the machine's existing environments before installing packages. Prefer existing compatible dependencies and respect project version constraints.
- If a dependency is missing, select a version compatible with the deployment stack and install it in the project's isolated environment first. Use the latest version only when it is compatible; a missing dependency does not justify upgrading unrelated packages.
- Prefer Conda or uv for environment dependencies. Keep system-level requirements separate from the project's Python environment.
- Before an installation requiring `sudo`, explain the proposed system change and obtain user approval unless that specific change is already authorized. If it conflicts with installed system packages, explain the conflict and wait for a decision. If the user cannot resolve it, leave the installation pending until someone familiar with the machine can help.

## 4. Activation scripts and ROS packages

Keep the machine-specific activation script at `<project>/activate_in_<machine-name>.sh`. It should select the intended runtime environment and any ROS setup required by that deployment. The script is typically synchronized with the deployment code using `rsync`; check its paths on the destination machine before using it.

When specific ROS packages must be built, use `<name>_ws/colcon_ws`. If message packages come from `instinct_onboard`, symlink their package directories into `colcon_ws/src/` rather than duplicating the source. Calculate each relative link from `colcon_ws/src/` to the actual package directory.

## 5. Verification

After an authorized setup or layout change, verify that the selected environment, activation-script paths, and ROS package links resolve on the deployment machine. Run any relevant environment or build checks there. Starting the robot or running a policy requires the user's authorization for that operation.
