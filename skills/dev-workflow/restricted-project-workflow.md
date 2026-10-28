# Restricted Project Workflow

Use this guide when a project lives on a restricted host: a company, customer, or air-gapped machine whose owner forbids exporting the project. The agent host only issues commands; all work happens on the restricted host. If the agent runs on the restricted host itself, drop the `ssh <alias>` transport; every other rule still applies.

## Terms

- **Restricted host:** the machine holding the project. The project exists only there.
- **Agent host:** the machine running the agent, including its disk, temporary directories, clipboard, caches, shell history, and sync clients.
- **Agent runtime:** the model and service that process the agent's context, transcript, and logs.
- **Project content:** the project's source, configuration, data, logs, and anything derived from them, including file names and paths.
- **Skill folder:** the generic, public skill repository containing this guide. It may exist on the agent host, the restricted host, or both, and never contains project content.
- **Owner:** whoever controls the restricted host and its export policy.

## Rule

Never copy project source, data, or logs from the restricted host to the agent host. The agent reads project content only as terminal output, preferably captured from a `tmux` pane. Derived outputs such as reports may be written on the agent host. If a tool needs project files on the agent host, change the tool, not the rule.

## Before working

Confirm with the owner, and stop if any item is unresolved:

- [ ] Access is authorized, and the agent host may connect.
- [ ] The agent runtime is approved for project content; whatever the agent reads enters it. If not, stop: an approved runtime, such as an on-prem model, is required, and moving the agent onto the restricted host does not change the runtime.
- [ ] The export policy names what may leave, such as aggregate metrics or redacted errors, and through which channel. The default is nothing.
- [ ] The approved Git remotes.

Then check on the restricted host yourself:

- [ ] The SSH alias works with key-based auth, and no credentials for it are stored in synced files, including `sync-config.json`.
- [ ] `git remote -v` in the project shows only the approved remotes.
- [ ] The project's build and test toolchain and `tmux` are available.

Record approvals in the owner's system. Agent memory holds only the host classification described in [SKILL.md](SKILL.md).

## Boundary

| Direction | Allowed | Prohibited |
| --- | --- | --- |
| Agent host → restricted host | Skill folder, commands, patches | None |
| Restricted host → agent runtime | Terminal output the agent must read, preferably captured from `tmux` | Bulk dumps when a region is enough |
| Restricted host → agent host | Owner-approved derived outputs such as reports | Project source, data, logs, and other project files |
| Restricted host → anywhere else | Owner-approved outputs through the owner's channel, never via the agent host; pushes to approved remotes | Web search, paste services, issue trackers, external chat, CI, package registries, gists, screenshots |

Never write project content into the skill folder on either host; it must stay generic and public.

## Project AGENTS.md

Add this to the project's `AGENTS.md` on the restricted host, beside its build and test instructions:

```markdown
## Restricted host

- Keep this project's content on this machine; ask before exporting anything, including error text.
- If unsure, stop and ask the owner.
```

Installing the skill folder on the restricted host is optional. If it is installed, use a stable path such as `~/skills/catbrain`, upload it with `scp`, `rsync`, or a `code` sync target whose remote directory holds only the skill folder, and add a line pointing to `~/skills/catbrain/skills/dev-workflow/SKILL.md`. Never point a sync target at the project checkout.

## Operating through tmux

Run every command, including file reads, inside a named `tmux` session on the restricted host, then capture the pane to read the result. The user can attach to watch or intervene, and work survives an unstable connection. Use direct `ssh` command output only when `tmux` is unavailable, and direct `ssh` stdin only for piping patches.

```bash
# Create the session once.
ssh <alias> 'tmux has-session -t agent-<project> 2>/dev/null || tmux new -d -s agent-<project>'

# Run a command. Piping it through a tmux buffer keeps quotes and $variables intact for the remote shell.
printf '%s\n' '<command>' | ssh <alias> 'tmux load-buffer -b agent - && tmux paste-buffer -d -b agent -t agent-<project>'

# Read recent output.
ssh <alias> 'tmux capture-pane -p -t agent-<project> -S -50'

# User: watch or intervene.
ssh -t <alias> tmux attach -t agent-<project>
```

- Use one named session per project or agent, and tell the user its name.
- Capture only the lines needed, and follow log files with targeted `tail` and `grep` instead of streaming them.
- After a disconnect, reconnect and read the pane before re-running anything; the previous command may still be running or may have finished.
- Do not kill a session the user is attached to or that holds a running job without asking.

## Working

- Read files by running `grep -n`, `sed -n 'a,bp'`, `git diff`, or `git status` in the session and capturing only the needed region.
- Edit by piping a patch from a heredoc to `ssh <alias> 'cd <project> && git apply'`, never from a patch file on the agent host; review the result with `git diff` in the session.
- Build, lint, and test on the restricted host.
- Keep `PROGRESS.md` and run folders on the restricted host, following [experiment-conventions.md](experiment-conventions.md).
- Commit only when asked, following [core-coding-principle.md](core-coding-principle.md).
- If the restricted host is unreachable, stop and tell the user. The project exists only there, so there is nothing on the agent host to continue from.

## Reporting

- Report the commands run and the results observed on the restricted host. Never claim an unverified result.
- The conversation may carry what the approved runtime allows. Derived outputs such as a report may be written on the agent host; source, data, and logs stay on the restricted host.
