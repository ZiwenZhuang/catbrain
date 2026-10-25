# Real Robot Deployment

A real robot can injure people and damage itself. Safety comes before speed, and the user must always know whether the robot can move.

## Two hard rules

1. **You launch only in dry-run mode.** Any entry script you start yourself must run in dry-run mode, so that no command reaches the motors. Before launching, check in the code that dry run is in effect for this exact command: the default is dry run, no flag such as `--nodryrun` is passed, and dry-run commands go to a dummy topic or nowhere. If you can't confirm this, don't launch.
2. **You never launch with motor control enabled.** When the user explicitly asks for no-dry-run mode, give them the exact launch command to run themselves, and stop. Do not run it, not even after they approve it, and not through a script, alias, chain (`&&`, `;`), background job, or retry loop.

These rules apply to every command that can power motors, enable joints, or send commands to the robot. If you are unsure whether a command can, treat it as one that can.

## Know when control actually starts

Read the entry script before giving the user a no-dry-run command. Control often starts earlier than the policy:

- Many entry scripts move the robot at launch, for example a cold-start or stand-up phase that ramps joints to a default pose. That motion is control, even though no policy is running yet.
- The policy itself often starts later, on a controller button. Each such step is a separate motion the user must expect.

Find out from the code:

- each phase, what moves, and what triggers it (launch, a button, a timer),
- every way to stop: the controller e-stop button or combo, Ctrl-C, and any automatic protection (joint limits, timeouts),
- what happens at the end (hold pose, motors off, process exits).

If the script has no dry-run default or no user-side e-stop, point that out.

## Handing over a no-dry-run command

In one message, give the user:

1. **A plain warning** that this command moves the robot as soon as it launches, and which phase moves first.
2. **The exact command**, including gain and startup flags, and the environment activation it needs.
3. **The phases and the expected motion**, as found above.
4. **How to stop it**, as found above.
5. **A checklist:** e-stop within reach, area clear of people and obstacles, robot secured (gantry, hoist, or stand) when the run calls for it.

Before this, use dry runs to check activation, agent loading, and that robot-side data (joint states, IMU, controller input) is live and sane. Suggest stages: a short run on a secured robot with confirmed gains before free motion.

## After a run

- When a run ends unexpectedly, don't assume it crashed. The user may have stopped it on purpose, for example with `pkill -9`, the e-stop, or by cutting the robot's power. Ask the user what happened before proposing a re-run.
- If the logs show anything wrong (unexpected joint values, NaNs, missing sensor data, high latency, warnings), report it before suggesting another run.
- Save logs to `deploy_logs/` as described in [dep-machine-layout.md](dep-machine-layout.md).
