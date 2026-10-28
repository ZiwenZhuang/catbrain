# Project AGENTS.md Template

Write a project's `AGENTS.md` with setup, lint, test, and build commands, architecture boundaries, deployment and environment rules, and domain-specific safety requirements.

## Hosts

- Name each host by hostname or computer name, and state what only runs there: training on the cluster, a policy on the robot, installs on the robot.
- Some operations only happen on another host. Check your hostname before running commands and do not run those operations locally.
- Ask for how to connect to another host if it is not known.
- A local `AGENTS.md` may differ from the project `AGENTS.md` on the other host; follow both.
- If a project lives on a restricted host, follow [restricted-project-workflow.md](restricted-project-workflow.md) and confirm the agent runtime is approved before reading the code.

## Folders

- `AGENTS.md` is the first file for agents to read.
- `agents/computation/` holds git-ignored files describing all available development and test resources. In a new repository, add it to `.gitignore` with a `.gitkeep` file so the folder stays in the repository.
