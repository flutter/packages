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
  any new logic. For integration tests, see [flutter-add-integration-test](.agents/skills/flutter-add-integration-test/SKILL.md).
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
