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
└── instinct-workflow/
    ├── SKILL.md
    └── core_coding_principle.md
```

`work-explainer/SKILL.md` contains the original research-paper explainer pipeline. Ask for a work explanation video and provide a paper or source reference; the skill produces the video and retains all intermediate files by default. `instinct-workflow` applies the core coding principles to routine software development tasks and requires agents to read and follow `core_coding_principle.md` whenever the skill is used. Installation makes the skill available; loading it automatically depends on the host agent’s skill selection mechanism.

Workflow documents:

- [Core coding principles](skills/instinct-workflow/core_coding_principle.md)
- [Work explainer instructions](skills/work-explainer/SKILL.md) (originally `paper_intro_video_prompt.md`)
