Core rules for all work. Read the project's `AGENTS.md` first, then these rules, then any task-specific guide.

## Core Rules

- understand the code and the requirement before making changes
- prefer the smallest correct change over broad rewrites
- follow existing project patterns unless there is a strong reason to change them
- keep code clear, readable, and maintainable
- verify important changes with tests or checks when possible
- never claim something was tested if it was not
- do not overwrite or revert unrelated work
- state assumptions, risks, and limitations clearly
- always log the current progress in `PROGRESS.md` if the file is present
- when several pipelines run at once, give each its own worktree and Docker environment; never `pip install` from different worktrees into one Conda environment.
- when fixing bugs, or issues, explain to the user on what the root causes are before propose the fixing operation.
- The `scripts/` directory holds entry scripts only: a script may import other modules, but code under `scripts/` must never be imported by other code. Put reusable code in a `pip`-installable package instead.
	- Minor or historical deviations from a convention are allowed only as clearly stated exceptions. Do not add callers or otherwise broaden the deviation.

## Code of Conduct Following Linus's Coding Taste
This is a primary engineering constraint, not a style preference.
### Default Direction
- Prefer simple, direct data flow and control flow. Do not add abstraction layers for theoretical elegance.
- Solve real problems first. Do not pre-build complex frameworks for imagined future cases.
- Eliminate complexity in the design instead of hiding it behind names like manager, factory, or coordinator.
### Must Follow
- Prefer small, clear interfaces.
- Compose existing stable modules first. Do not add universal layers, unified abstraction layers, `Base*` classes, or over-generalized wrappers without a concrete need.
- Prefer better data structures that remove special cases instead of piling on more `if`/`else` branches.
- Names must be plain and precise. They should describe the real semantics, ownership, lifetime, and failure path.
- Do not silently smooth over bad state. When something is invalid, expose where the invariant was broken.
- A new abstraction must prove that it reduces overall complexity. If it only moves complexity around, do not add it.
### Code vs. Configuration
- Code that just works for the current requirements is very different from code that absorbs new requirements through configuration. Design for the latter: a new requirement should be met by writing a new configuration or making minimal changes to an existing configuration file, not by changing the code logic.
- Code and configuration are different concepts. Code implements mechanisms: algorithms, data flow, and invariants. Configuration selects and parameterizes them: which components, which values, and which combination.
- Keep code generalizable and modular to make this possible. Expose the axes along which requirements vary (e.g., datasets, robots, models, terms, hyperparameters) as configuration, using `func` or `class_type` fields where a component must be swappable.
- Do not hard-code values or branch on specific cases (e.g., `if robot == "g1":`) when that variation belongs in configuration.
- This does not license speculative frameworks. Generalize along axes that are real or clearly anticipated in the project, and keep the interface small. If it is unclear which axes will vary, ask.
### Explicitly Discouraged
- Adding architectural layers only to make patterns look uniform.
- Excessive object orientation, inheritance, configuration, or generic abstraction.
- Splitting complex interactions into many weakly related small files.
- Using silent fallbacks, implicit synchronization, or magic defaults to keep the surface looking clean.
- Adding adapters only to avoid changing old code.
## Working Style

Before editing:

- read the relevant files
- look for existing helpers or patterns or code snippets to reuse
- prefer reusing an existing snippet, wrapping it only when that is clearly the fit
- mention it when the task is inconsistent, ambiguous, risky, or conflicts with project conventions
- prefer a `func` or `class_type` configuration value when it clearly removes special-case branches
- In python files, trust the type lint.
- Do not write too many protective code. If really necessary, stop and ask the user.

When editing:

- fix the root cause when practical
- avoid unrelated cleanup
- avoid unnecessary dependencies and abstractions
- add proper comments to function implementation if the name does not directly reflects its design and functionality
- write code that is easy for the next engineer to understand
- only update the comments if they are inconsistent with the logic
- do not edit the clean code if editing the dirty code can solve the current issue

After editing:

- run the smallest useful verification
- update tests or docs if the change needs it
- summarize what changed and anything still uncertain
- never commit, amend, push, or create a PR unless the user explicitly asked for it in this conversation
- if `pre-commit` is configured in the repository, run `pre-commit run --files <changed files>`. When `--all-files` rewrites pre-existing violations, keep those fixes in a dedicated commit; ask the user to make it when committing is not authorized.

### Python specific coding

Importing packages and modules:

- When the module is in the same package and in the same folder, use import start with `.`
- When the module is in the same package but not in the same folder or subfolder, use the complete import path starting with the package name.
- When the module is just from another package, do remember to write complete informative import path.

## Ask Before Proceeding

Stop and ask if:

- requirements are unclear
- the change is destructive or hard to reverse
- the task affects security, data, billing, privacy, or production infrastructure
- local user changes create a conflict

When writing or updating a project's `AGENTS.md`, use [agents-md-template.md](agents-md-template.md).
