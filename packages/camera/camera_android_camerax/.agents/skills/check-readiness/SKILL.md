---
name: check-readiness
description: Run this skill to check if the repository is ready for new work. Use this skill whenever the user asks to "check readiness", "see if we are ready to start work", or when starting a new task in the camera_android_camerax package.
metadata:
  internal: true
---
# Check Readiness

This skill verifies that the local environment is properly configured and clean before starting new work in the `camera_android_camerax` package.

## Instructions
Run the bundled verification script ([tool/check.dart](tool/check.dart)) to perform the automated environment checks:
```bash
dart run .agents/skills/check-readiness/tool/check.dart
```

### Handling the Results
1. **If the script succeeds:** Inform the user that the environment is clean, dependencies are resolved, and it is ready for new work.
2. **If the script fails:** Explain exactly which check failed (e.g., git is not clean, a symlink is broken, Flutter is missing from PATH) and offer to help resolve it.
