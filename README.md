# catbrain

A personal repository for reusable skills supporting my typical workflow, coding standards, and robotics research.

## Potential coverage

Skills may cover software development workflows, coding standards, deep reinforcement learning, robot control, whole-body control, and embodied AI. The primary research focus is deep RL and control. These are areas of interest, not predefined skill names or boundaries.

Hardware experimentation and mechatronics are also part of my work, but related skills are outside the current scope and may be added later.

## Structure

`skills/` contains one folder per skill, with a `SKILL.md` entry point declaring its name, description, and instructions.

```text
skills/
├── work-explainer/
│   └── SKILL.md
└── dev-workflow/
    ├── SKILL.md
    ├── core-coding-principle.md
    ├── agents-md-template.md
    ├── dev-machine-layout.md
    ├── dep-machine-layout.md
    ├── restricted-project-workflow.md
    ├── experiment-conventions.md
    ├── linux-hard-lessons.md
    ├── code-data-sync/
    │   ├── SKILL.md
    │   ├── code-data-sync-setup.sh
    │   ├── code-data-sync-setup.md
    │   └── sync-config.json.example
    └── progress-report/
        └── SKILL.md
```

`work-explainer/SKILL.md` contains the original research-paper explainer pipeline. Ask for a work explanation video and provide a paper or source reference; the skill produces the video and retains all intermediate files by default. `dev-workflow` applies the core coding principles to routine software development tasks and requires agents to read and follow `core-coding-principle.md` whenever the skill is used. It also covers hosts that forbid exporting code or data, where the agent works remotely and keeps project source and data on the restricted host. Installation makes the skill available; loading it automatically depends on the host agent’s skill selection mechanism.

Workflow documents:

- [Core coding principles](skills/dev-workflow/core-coding-principle.md)
- [Development machine layout](skills/dev-workflow/dev-machine-layout.md)
- [Deployment machine layout](skills/dev-workflow/dep-machine-layout.md)
- [Restricted project workflow](skills/dev-workflow/restricted-project-workflow.md)
- [Experiment conventions](skills/dev-workflow/experiment-conventions.md)
- [Progress report](skills/dev-workflow/progress-report/SKILL.md)
- [Project AGENTS.md template](skills/dev-workflow/agents-md-template.md)
- [Linux hard lessons](skills/dev-workflow/linux-hard-lessons.md)
- [Work explainer instructions](skills/work-explainer/SKILL.md) (originally `paper_intro_video_prompt.md`)
