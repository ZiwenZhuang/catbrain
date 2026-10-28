---
name: dev-workflow
description: Apply the user's coding principles during routine development, configure development, robot deployment, or restricted-host layouts, and synchronize code or training data with SSH hosts.
---

# Development Workflow

Always read and follow [core-coding-principle.md](core-coding-principle.md).

Default path: a routine code change in a local checkout needs only this guide and the core rules. Read the other guides when the task involves hosts, deployment, robots, experiments, sync, or reports.

Read other guides only as needed:

- [Development layout](dev-machine-layout.md): workstations, cluster nodes, source links, datasets, and logs.
- [Deployment layout](dep-machine-layout.md): robot workspaces and runtime environments.
- [Real robot deployment](real-robot-deployment.md): read before any work that could lead to running a controller or policy on a physical robot.
- [Restricted projects](restricted-project-workflow.md): hosts that forbid exporting code or data, worked remotely with project source and data kept off the agent host.
- [Experiment conventions](experiment-conventions.md): run folders, provenance, and parallel agent isolation.
- [Code/data sync](code-data-sync/SKILL.md): transfers using named SSH targets.
- [Progress report](progress-report/SKILL.md): research and experiment progress reports with figures and videos, as Markdown, online documents, or a static HTML site.
- [Linux hard lessons](linux-hard-lessons.md): read before helping with kernel upgrades, driver installs, or reboots on Linux hosts.

## Host classification

Identify each host by hostname, or by the computer name the user calls it. Add the MAC address only when names are ambiguous, since IP addresses and SSH aliases change:

```bash
hostname
cat "/sys/class/net/$(ip route show default | awk '{print $5; exit}')/address"
```

- The machine the agent runs on is not restricted unless the user says otherwise.
- Ask about any other host you have not seen before, before touching a project on it.
- Remember only the identifier and the answer, nothing else about the host or its projects:

  ```text
  <hostname> (<MAC>): restricted | not restricted
  ```

- Keep in mind that some operations only run on another host, such as cluster training, a policy on the robot, or robot-side installs. Do not run them where you are.
- For a restricted host, follow [restricted-project-workflow.md](restricted-project-workflow.md).

## Target machine

Identify the target machine and checkout first; different paths may be worktrees of one repository. If the project's host is restricted, read the restricted guide before working on it and confirm the agent runtime is approved. Inspect deployment state on the robot. For machines serving both roles, read both layout guides and ask about conflicts before changing affected paths or environments.
