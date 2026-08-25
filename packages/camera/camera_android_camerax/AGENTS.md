# Agent Guide for camera_android_camerax

## Core Workflows

- **Check Environment**: Run [check-readiness](.agents/skills/check-readiness/SKILL.md)
  when starting a new task or if you suspect environment issues.
- **Regenerate Code**:
  - Pigeon (`dart run pigeon --input pigeons/camerax_library.dart`): Run after
    modifying `pigeons/camerax_library.dart`.
  - Mocks (`dart run build_runner build -d`): Run after modifying mocked
    classes or adding new mocks. (see [dart-generate-test-mocks](.agents/skills/dart-generate-test-mocks/SKILL.md))
- **Verify Tests**: All tests must pass before landing. Add or update tests for
  any new logic.
  - **Dart Unit Tests**: See [dart-add-unit-test](.agents/skills/dart-add-unit-test/SKILL.md).
  - **Native Unit Tests**: Run `dart pub global run flutter_plugin_tools native-test --android --packages camera_android_camerax --no-integration`.
  - **Integration Tests**: See [flutter-add-integration-test](.agents/skills/flutter-add-integration-test/SKILL.md).
- **Run Pre-Push Checks**: Run [pre-push-skill](.agents/skills/pre-push-skill/SKILL.md)
  before pushing to prevent CI failures and code review blocks.

## Agent Guidelines

- Use [receiving-code-review](.agents/skills/receiving-code-review/SKILL.md)
  to technically verify review feedback before blindly implementing suggestions,
  especially if feedback seems technically questionable.
- Use `/grill-me` or `/plan` for complex features before writing code.
- Maintain high test coverage using [dart-add-unit-test](.agents/skills/dart-add-unit-test/SKILL.md)
  and [dart-collect-coverage](.agents/skills/dart-collect-coverage/SKILL.md).
- Avoid duplicating constant strings; reuse existing ones from adjacent code.
- **Testing Guidelines**: You MUST read and follow all rules in [TESTING.md](TESTING.md) BEFORE writing or modifying any tests. This is CRITICAL for preventing CI flakiness.
- **Native Unit Tests**: When modifying `.java` or `.kt` files in `android/src/main/` (excluding Pigeon generated files like `.g.java` or `.g.kt`) with logic changes, you MUST add or update corresponding native unit test files in `android/src/test/`.
- **CRITICAL**: When spawning subagents, NEVER provide absolute file paths in prompts. ALWAYS use relative paths. Passing absolute paths breaks `Workspace: branch` isolation and causes state bleed into the active workspace.
## Guiding Principles for Contributions

- **Format All Code**: Every code change must be formatted using the repository tools (`dart format`, `google-java-format`, etc.).
- **Pass All Tests**: All changes must pass linting, analysis, and all relevant tests (Dart unit tests, native Android tests, integration tests).
- **Update CHANGELOGs & Versions**: Any user-facing change or bug fix in a package requires an update to its `CHANGELOG.md` and `pubspec.yaml` version following the repository CHANGELOG style guide.
- **Follow Conventions**: Adhere to federated plugin structure and Pigeon/Mockito code generation steps.
- **Repository Guidelines**: Adhere to all repository-wide principles in the root [AGENTS.md](../../../AGENTS.md).
- **Validation**: Never run `.ci/scripts/*` or `script/tool_runner.sh` globally to validate local changes. They are slow and modify the entire repository. Always use targeted skills (like `dart-run-static-analysis` or `pre-push-skill`) to run the repo tool scoped to this package.
