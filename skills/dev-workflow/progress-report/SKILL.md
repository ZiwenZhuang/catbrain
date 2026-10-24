---
name: progress-report
description: Write research and experiment progress reports with key figures, videos, numbers, and conclusions, as Markdown or online documents such as Feishu Docs.
---

# Research Progress Report

Ask for the period, audience, experiments to cover, and output target if unclear.

## Evidence

- Keep full run folders on the development machine under `~/Data/...` (see [experiment-conventions.md](../experiment-conventions.md)); download remote-only runs with [code-data-sync](../code-data-sync/SKILL.md).
- On restricted hosts, follow [restricted-project-workflow.md](../restricted-project-workflow.md) and ask before taking anything off the host.
- Plotting scripts, intermediate plots, and unused clips stay with the evidence.

## Report

Include only key figures, short video clips, numbers from logs, hypotheses, and conclusions. Leave out configs, raw logs, and diffs.

1. Summary: main result and current blocker.
2. Experiments: question, setup change, key result, conclusion or hypothesis.
3. Problems and next steps.
4. Evidence index: development-machine path and checkpoint for each cited run.

Caption every figure and clip with its run and checkpoint.

## Output

- Markdown: one `.md` file plus `assets/` holding only the media it uses. Link videos rather than embedding them.
- Feishu or other online docs: write the Markdown draft, then list the assets to upload and where. Do not upload unless asked.
