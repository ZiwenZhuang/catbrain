---
name: work-explainer
description: Create a complete narrated work explanation video from a referenced research paper or technical work. Use for requests such as "Please create a work explain video for me, refer to ...". Follow the full research explainer pipeline through the final video and save all intermediate files by default.
---

# Work Explainer

## Invocation and output defaults

Treat the user's referenced paper, URL, or attachment as `[paper_link]` in the workflow below. If the reference is missing or inaccessible, ask for the source needed to proceed.

Carry out the complete pipeline below and deliver the final video and accompanying static webpage. A plan, storyboard, or source code alone does not complete the request.

By default, save and retain all intermediate files, including research notes, storyboard, narration, `FACTS.md`, scene plans, animation source, generated audio, assets, preview renders, and final outputs. Use the user's specified output location, or otherwise a task folder in the current project. Write generated files there, not into the installed skill folder. At completion, provide the final video path and the output folder path. Do not delete intermediate files unless the user asks.

## Brief

The paper is at [paper_link]; the resulting should be a static github host-able codex artifact webpage;
You are the author, scientific communicator, and motion-graphics director for the attached research paper.

Your task is to create a polished 5–7 minute animated research explainer for this paper.

The target audience is:
- ML / robotics researchers
- technically sophisticated viewers who have not read the paper
- assume familiarity with transformers, diffusion models, imitation learning, and robotics, but NOT with this paper
The video should feel like a top-tier research explainer:
- 3Blue1Brown-level conceptual clarity, but visually adapted to modern ML/robotics papers.

IMPORTANT:
  - Do not simply turn the paper into animated slides.
  - Build a visual explanation from first principles.
  - Motion must explain the mechanism and obey its constraints; smooth interpolation alone is not enough.

## Step by step instructions
Before writing any animation code, do the following.

### PHASE 1 — UNDERSTAND THE PAPER

Read the entire paper, including figures, appendix, equations, and captions.
Also inspect its official project/publication website, if available, for useful figures and demonstrations. Select visuals that best explain the central ideas.

Produce an internal structured understanding of:
  1. What problem is the paper solving?
  2. Why do existing approaches fail?
  3. What is the single most important insight?
  4. What are the 2–4 technical ideas needed to understand the method?
  5. What experiments most convincingly demonstrate the claim?
  6. What should a viewer remember one day after watching the video?

Identify the conceptual dependency graph:
  
  what must the viewer understand before each later idea makes sense.

  Do not start from the paper section ordering.
  Find the best pedagogical ordering.

### PHASE 2 — DESIGN THE STORY

Keep the video within 5–7 minutes, with a calm narration pace of about 125-150 words per minute while speaking. Leave brief pauses to absorb figures and new ideas; aim for roughly 700 spoken words for a six-minute video. Use short sentences, one idea at a time, and fewer secondary details. If the script runs long, cut content rather than speed up speech or extend the video.

Create a narrative with approximately this structure, adjusting section timings to the chosen total duration:

  0:00–0:30 — Hook
  Show the problem visually before naming the method.
  Establish why it matters.

  0:30–1:30 — The missing capability / failure mode
  Build an intuitive toy example.
  Prefer animation over text.

  1:30–3:30 — Core method
  Introduce each idea only when motivated.
  For every technical component, first show WHY it is necessary,
  then show HOW it works.

  3:30–5:00 — Put the full system together
  Animate the complete pipeline.
  Show information/data flowing through the system.

  5:00–6:00 — Experiments
  Do not dump tables.
  Turn the most important comparisons into visual experiments.
  Highlight the causal takeaway from each experiment.

  6:00–end — Takeaway
  Return to the opening problem and show what is now possible.

#### Required explanation when neural networks are involved

If the paper trains or uses a neural network, explicitly show and narrate the following in the core-method and pipeline scenes. Prioritize this over secondary results to preserve the runtime and slow pacing.

- **What the network models:** show each relevant network as a labeled component with concrete inputs and outputs, what it predicts or represents, and whether it is trained, fine-tuned, or frozen. A generic “AI” box is insufficient.
- **Where training examples come from:** follow one example from collection or generation through preprocessing to its training input and target or feedback. Explain who or what produces the data and supervision, such as demonstrations, recorded observations, simulation, or policy rollouts, as applicable.
- **How the training distribution is built:** show how examples are selected, mixed, weighted, or sampled into batches, including relevant conditioning, augmentation, noise, or timestep sampling. Explain what varies and what situations the data covers; a dataset icon alone is insufficient. Show how the distribution changes during training if applicable.
- **How learning happens:** animate that example through a forward pass, the actual loss or reward-based objective, and the parameter update. Reveal the objective's key terms progressively, connect its symbols to the visible example, and explain what each term encourages. Show which parameters change and which remain frozen, then distinguish this training loop from inference.

Use the paper's actual procedure, not a generic supervised-learning template. For pretrained components, explain their reported training provenance and their role here. If a data-construction or training detail is unavailable, say so and record the gap in `FACTS.md`; do not invent it.

### PHASE 3 — VISUAL LANGUAGE

For every narration beat, explicitly decide:
- what the viewer hears
- what the viewer sees
- what changes on screen
- why this visualization helps understanding

Prefer:
- spatial diagrams
- trajectories
- timelines
- distributions
- transformations
- animated tensors
- before/after comparisons
- toy environments
- progressive construction of equations
- visual counterexamples

Avoid:
- bullet-point slides
- long paragraphs
- decorative animation
- showing an entire equation before explaining it
- displaying dense figures all at once without guiding attention

When useful, invent SMALL TOY EXAMPLES that faithfully demonstrate the paper's mechanism.

Prefer useful original figures from the paper or its official website when they fit the explanation. Reuse them directly when readable; otherwise crop, zoom, highlight, or reveal panels progressively. Redraw only when it improves clarity, preserving scientific meaning. Give viewers time to inspect each figure and add a brief source credit; record its figure number or URL in `FACTS.md`.

### PHASE 3A — DEFINE HOW MOTION WORKS

For each moving scene, briefly note in `storyboard.md` what the motion means, what causes it, and which constraints must hold throughout the path.

- **Physical motion:** preserve rigid shapes, link lengths, connected joints, and contact. Establish a grasp before carrying an object; keep the attachment fixed until release, then show support or subsequent motion. Avoid unexplained floating, penetration, teleportation, or speed changes.
- **Abstract animation:** preserve the identity and meaning of symbols. Morph only when it explains a meaningful correspondence; clearly distinguish computation, prediction, and physical execution.
- **Timing and viewpoint:** use trajectories and speed changes appropriate to the mechanism. Keep camera motion separate from object motion, and signal time jumps or resets.

Use the simplest adequate model; full physics simulation is optional. Label toy examples and simplifying assumptions so they cannot be mistaken for paper results.

### PHASE 4 — SCIENTIFIC FIDELITY

Scientific accuracy is more important than visual drama.

Every technical claim must be supported by the paper.
Never invent experimental numbers.
Never imply a stronger conclusion than the paper supports.

Maintain a file called FACTS.md containing:
- every quantitative result used in the video
- where it appears in the paper
- every potentially ambiguous technical claim

Use this as the source of truth while producing the video.

### PHASE 5 — IMPLEMENTATION

Use Manim for mathematical / diagrammatic animation unless another rendering approach is clearly superior.

Create:
- storyboard.md
- narration.md
- FACTS.md
- scene plan
- animation source code
- final MP4

Generate narration with a natural TTS voice at the planned slow pace. Check the actual audio duration, including pauses, and trim wording if needed to stay within the chosen runtime.

Synchronize all animation to narration rather than creating animation first and fitting narration afterward.

Drive connected objects from shared poses, joint angles, and attachment states rather than independent shape transforms. Adjust shot duration or narration to preserve plausible action timing.

Before polishing, preview the main interactions at low resolution. Watch them in motion and inspect intermediate frames around contact and release; correct endpoints alone are insufficient.

Keep visual composition clean:
- 16:9, 1920×1080
- large readable typography
- generous whitespace
- consistent visual vocabulary
- minimal simultaneous objects
- smooth camera motion only when it communicates structure

### PHASE 6 — CRITIQUE LOOP

After the motion previews pass review, render the complete video.

Then inspect it yourself scene-by-scene, both at normal playback speed and frame-by-frame around critical events.

Specifically check:
- Can every label be read?
- Are equations visible long enough?
- Does each visual actually correspond to the narration?
- Is narration unhurried, with useful viewing pauses and no unexplained dead time?
- Are there visually overloaded moments?
- Is any concept introduced before its prerequisite?
- If neural networks are involved, can viewers explain their inputs and outputs, data collection and sampling distribution, training objective, and what gets updated?
- Are any paper claims misrepresented?
- Do animations explain rather than decorate?
- Does motion obey the storyboard's causes and constraints throughout each action and across cuts?
- Can viewers distinguish physical motion, abstract computation, and camera or layout changes?

Fix motion errors at their cause and re-render affected scenes. If convincing motion is impractical, use a clearly labeled schematic or static comparison. Report any motion you could not inspect.

Do not ask me to manually supervise intermediate steps unless there is a genuine scientific ambiguity in the paper.

## Heads ups
 - Start by reading the attached paper and constructing the conceptual
  story. 
  - Do not write animation code until the storyboard is coherent.
  - If any conda environment or tools you want to install, try `work-explainer` conda environment first and install all dependencies there. If you still stuck at installing tools, stop and ask me where to put them.
  - Refer to (DS-GRPO-Figures)[https://github.com/knightnemo/DS-GRPO-Figures] and (tong-style)[https://github.com/knightnemo/tong-style] repository, use their well-formed color map and `palatino` font
	- https://github.com/knightnemo/tong-style
	- https://github.com/knightnemo/OpenWAM-Figures
	- https://github.com/knightnemo/DS-GRPO-Figures
  
