---
name: dev-workflow
description: Apply the user's coding principles during routine development, configure development, robot deployment, or restricted-host layouts, and synchronize code or training data with SSH hosts.
---

# Development Workflow

Always read and follow [core-coding-principle.md](core-coding-principle.md).

Read other guides only as needed:

- [Development layout](dev-machine-layout.md): workstations, cluster nodes, source links, datasets, and logs.
- [Deployment layout](dep-machine-layout.md): robot workspaces and runtime environments.
- [Real robot deployment](real-robot-deployment.md): read before any work that could lead to running a controller or policy on a physical robot.
- [Restricted projects](restricted-project-workflow.md): hosts that forbid exporting code or data, worked remotely with no project content on the agent host.
- [Experiment conventions](experiment-conventions.md): run folders, provenance, and parallel agent isolation.
- [Code/data sync](code-data-sync/SKILL.md): transfers using named SSH targets.
- [Progress report](progress-report/SKILL.md): research and experiment progress reports with figures and videos, as Markdown, online documents, or a static HTML site.
- [Linux hard lessons](../Linux-hard-lessons.md): read before helping with kernel upgrades, driver installs, or reboots on Linux hosts.

## Host classification

Whenever a host appears that is not in your persistent memory, whether the agent host or one reached over SSH, ask the user whether it is a restricted host before touching any project on it.

- Identify each host by hostname and MAC address; IP addresses and SSH aliases can change. On Linux, run on that host:

  ```bash
  hostname
  cat "/sys/class/net/$(ip route show default | awk '{print $5; exit}')/address"
  ```

  Air-gapped hosts may have no default route; then use the primary wired interface's MAC from `ip -br link`.

- Treat a host as new if either the hostname or the MAC address does not match a remembered entry.
- Remember only the identifier and the answer, nothing else about the host or its projects:

  ```text
  <hostname> (<MAC>): restricted | not restricted
  ```

- For a restricted host, follow [restricted-project-workflow.md](restricted-project-workflow.md).

## Target machine

Identify the target machine and checkout first; different paths may be worktrees of one repository. If the project's host is restricted, read the restricted guide before working on it and confirm the agent runtime is approved. Inspect deployment state on the robot. For machines serving both roles, read both layout guides and ask about conflicts before changing affected paths or environments.
