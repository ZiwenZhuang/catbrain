# instinct_onboard Dependency Notes

Use [SKILL.md](SKILL.md) for workspace selection, commands, and activation. Check the target checkout's implementation before applying these notes.

## ROS packages

- Build Box-Robotics `ros2_numpy` with colcon using the branch matching `ROS_DISTRO`; inspect existing checkouts before reuse. Avoid pip variants whose NumPy pin conflicts with the project.
- Link `motion_target_msgs` from the source checkout into `colcon_ws/src/`.
- `rclpy` comes from the system ROS installation; the environment's Python must be compatible with those binaries.
- If some vendor packages are required, only install necessary message packages in development machine. But ask for a fully installed deploy machine, or refer to external instruction to install them.

## ONNX Runtime and OpenCV

- Some installer revisions preinstall `onnxruntime-gpu` on aarch64 from `https://pypi.jetson-ai-lab.io/jp6/cu126`. Verify the actual Jetson, CUDA, cuDNN, and Python versions first; aarch64 alone does not establish compatibility. Do not assume a `JETPACK_VERSION` override exists.
- On x86_64, `setup.py` may select CPU/GPU ONNX Runtime through CUDA detection; inspect support for `FORCE_CPU=1` and `FORCE_GPU=1` in that revision.
- Respect the checkout's NumPy constraints. Choose compatible OpenCV/ONNX Runtime versions rather than relying on a forced NumPy downgrade; check dependency consistency and relevant imports.
- Pip OpenCV is CPU-only. For GPU OpenCV, decline that install and follow the checkout README's source-build instructions.
- Missing CUDA libraries can cause CPU fallback. Verify the actual inference provider and latency before accepting that for deployment.
- Install `pyrealsense2` only where RealSense hardware requires it.
