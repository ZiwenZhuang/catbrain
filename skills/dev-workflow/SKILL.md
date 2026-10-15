---
name: dev-workflow
description: Apply the user's core coding principles to routine software development, recognize or set up development and robot deployment machine layouts, and synchronize project code or training data with SSH hosts. Use for planning, implementing, debugging, refactoring, reviewing, or testing code, even when coding standards are not explicitly requested.
---

# Development Workflow

Before starting work, read and follow [core-coding-principle.md](core-coding-principle.md), located alongside this `SKILL.md` in the installed skill folder.

Treat these principles as required instructions throughout the task, not optional reference material. Apply them by default whenever this skill is used; do not wait for the user to ask you to read or apply them.

## Machine layouts

Read the relevant layout guide when the task involves machine setup, project or data placement, or deployment environments:

- [dev-machine-layout.md](dev-machine-layout.md) for development workstations and cluster nodes, including project locations, shared datasets, logs, and portable symlinks.
- [dep-machine-layout.md](dep-machine-layout.md) for robots running policies in real time, including deployment workspaces, dependency isolation, activation scripts, and ROS package workspaces.

If a machine serves both roles, read both guides. Preserve intentional existing paths; if the conventions conflict for the requested change, ask the user which layout to use before changing the affected paths or environment. Inspecting a layout does not authorize reorganizing the machine.

## Code and data synchronization

For synchronizing project code or training data with SSH-accessible hosts, read [code-data-sync/SKILL.md](code-data-sync/SKILL.md). Use its named targets to identify the transfer paths; use the relevant machine layout guide when creating or changing those paths.
