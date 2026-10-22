---
name: dev-workflow
description: Apply the user's coding principles during routine development, configure development or robot deployment layouts, and synchronize code or training data with SSH hosts.
---

# Development Workflow

Always read and follow [core-coding-principle.md](core-coding-principle.md).

Read other guides only as needed:

- [Development layout](dev-machine-layout.md): workstations, cluster nodes, source links, datasets, and logs.
- [Deployment layout](dep-machine-layout.md): robot workspaces and runtime environments.
- [Experiment conventions](experiment-conventions.md): run folders, provenance, and parallel agent isolation.
- [Code/data sync](code-data-sync/SKILL.md): transfers using named SSH targets.

Identify the target machine and checkout first; different paths may be worktrees of one repository. Inspect deployment state on the robot. For machines serving both roles, read both layout guides and ask about conflicts before changing affected paths or environments.
