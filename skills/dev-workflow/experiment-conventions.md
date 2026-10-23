# Experiment System Conventions

## Scope

- Apply these conventions to every experiment, including cluster training and real-robot deployment.
- Give every run its own timestamped log folder containing the evidence needed to reproduce and inspect it.
- Organize every experiment system around three explicit parts: dataset, code, and configuration.

## Experiment Components

### Dataset

- Use publicly available datasets as versioned inputs; datasets are typically immutable.
- Keep source datasets separate from code, configuration, and generated run artifacts.
- Identify the dataset used in the configuration; keep derived data separate from its source.

### Code

- Keep training and deployment pipeline logic in Git-tracked repositories.
- Express pipeline behavior through configuration instead of editing code for each experiment.
- Save relevant repository commit identifiers, Git status, and diffs in the run folder.
- Git status and diffs do not archive untracked file contents; keep experiment logic Git-tracked.

### Configuration

- Always define configuration through reusable, Git-tracked templates with explicit parameters.
- Let configuration select pipeline behavior, including data, model, optimizer, environment, and deployment settings.
- Save the effective configuration content, including overrides needed to recover the run settings.
- For deployment, include runtime settings and the policy configuration used by the robot.
- Record which existing model or training run is used when resuming or deploying.

## Per-Run Log Folder (aka. Data)

- Create a separate timestamped folder for each experiment run, with an optional descriptive run name.
- Keep the run's Git records, configuration, and applicable outputs together; avoid reusing earlier run folders.
- Follow the project's existing naming and file layout rather than requiring identical folder names across projects.
- Because most timestamps only reach second-level precision, launch batched experiment variants one by one with at least 2 seconds between launches.

### Required Contents

| Artifact | Training run | Real-robot deployment run |
| --- | --- | --- |
| Git records | Commit, status, and diffs, such as `git/*.diff` | Commit, branch, status, and diff, such as `git_status_*.txt` |
| Configuration | Effective environment and agent settings, such as `params/*.yaml` | Deployment settings, policy configuration, and training-product provenance |
| Run outputs | Model checkpoints and TensorBoard events | ROS bags containing joint-state data recoverable offline, optional odometry with its extrinsic to a robot link, and other available trajectory and monitoring data |

ROS bags can serve both trajectory recording and monitoring; a separate trajectory
export or curve file is not required. A deployment can reference an existing model
artifact without copying the model into every run folder.

## Training Recording

- Save checkpoint snapshots at configured intervals and at normal completion.
- Use the runner's checkpoint format for model and supported training state.
- Save training curves through TensorBoard events or the project's equivalent logger.

## Robot Deployment Recording

- Deployment typically consumes a training product; log the exact product actually loaded for each policy.
- Record its artifact identifier or path and its source training run and checkpoint iteration, for example `20261020_113000_walk/model_2000.pt`.
- For exported products such as ONNX models, preserve the link from the exported artifact to that training run and checkpoint.
- Save this provenance in the deployment run folder, for example in `deployment_info.yaml`; a mutable alias such as `latest` alone is insufficient.
- Record available robot trajectory data through the deployment's configured ROS topics.
- Always record joint-state data, in whatever topics and message types the robot provides, such that the actual robot joint states can be reconstructed offline.
  - Raw or robot-specific data, such as motor-level states, is acceptable; record it rather than converting it at runtime.
  - Save what the offline conversion needs alongside the bag, such as joint order and naming, motor-to-joint mapping, offsets, directions, and gear ratios, when they are not already in the recorded messages.
- Odometry is optional, since the robot may not have a reliable estimate. When it is recorded, also record the extrinsic transform from the frame the odometry tracks, such as a camera, lidar, IMU, or motion-capture marker frame, to a robot link in the URDF, as a static transform or in the run's metadata. Without that extrinsic the odometry cannot be connected to the robot model.
- Also include commands, feedback, and available sensor/debug topics relevant to the experiment.
- After a run, check with `ros2 bag info` that the joint-state data, and any odometry data, are present with nonzero message counts, and that recorded odometry has its extrinsic in the bag or run metadata.
- Keep the bag data and its metadata in the run folder.

## Parallel Agents in Isolated Environments

- Give each agent its own Git worktree or clone and branch; never let parallel agents edit one checkout.
- Isolate runtime environments and Python packages per agent, preferably with Docker; fall back to a per-worktree venv when Docker is impractical.
- Keep configuration changes inside the agent's own checkout; do not edit shared configuration in place.
- Datasets and per-run log folders may be shared across agents:
  - Mount `~/Datasets` read-only; write derived data elsewhere.
  - Include the agent or worktree name in run names, since parallel launches can share a timestamp.
- In containers, mount `~/Data`, `~/Datasets`, and the main repository's `.git` at their host paths so symlinks and worktree Git records resolve.

## Example Layout

The checked `instinctlab` training entrypoint and `instinct_rl` runner produce:

```text
<log_dir>/
  git/*.diff
  params/env.yaml
  params/agent.yaml
  model_<iteration>.pt
  events.out.tfevents.*
```

The checked `instinct_onboard` deployment scripts use this layout when logging is enabled:

```text
deployment_logs/<timestamp>_<run_name>/
  git_status_*.txt
  deployment_info.yaml
  rosbag/
```

Some deployment scripts additionally archive policy YAML files under `policy_configs/` and
records model/motion file fingerprints without copying those assets. Simpler
deployment scripts record selected settings and a source log path; that alone
does not guarantee fully recoverable configuration content.

These layouts illustrate existing behavior. Some deployment scripts allow logging
to be disabled, and their timestamp helper can reuse a folder for the same name
within one minute. Neither behavior satisfies the per-experiment-folder convention.
Do not assume complete source archives, dependency manifests, console capture,
random-number-state recovery, or recording of every possible ROS topic.
