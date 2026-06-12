description: Configures Flutter Driver for app interaction and converts MCP actions into permanent integration tests. Use when adding integration testing to a project, exploring UI components via MCP, or automating user flows with the integration_test package.
metadata:
  model: models/gemini-3.1-pro-preview
  last_modified: Tue, 21 Apr 2026 18:29:20 GMT
---
# Implementing Flutter Integration Tests

## Contents
- [Project Setup and Dependencies](#project-setup-and-dependencies)
- [Interactive Exploration via MCP](#interactive-exploration-via-mcp)
- [Test Authoring Guidelines](#test-authoring-guidelines)
- [Execution and Profiling](#execution-and-profiling)
- [Workflow: End-to-End Integration Testing](#workflow-end-to-end-integration-testing)
- [Examples](#examples)

## Project Setup and Dependencies

Configure the project to support integration testing and Flutter Driver extensions.

1. Add required development dependencies to `pubspec.yaml`:
   ```bash
   flutter pub add 'dev:integration_test:{"sdk":"flutter"}'
   flutter pub add 'dev:flutter_test:{"sdk":"flutter"}'
   ```
2. Enable the Flutter Driver extension in your application entry point (typically `lib/main.dart` or a dedicated `lib/main_test.dart`):
   - Import `package:flutter_driver/driver_extension.dart`.
   - Call `enableFlutterDriverExtension();` before `runApp()`.
3. Add `Key` parameters (e.g., `ValueKey('login_button')`) to critical widgets in the application code to ensure reliable targeting during tests.

## Interactive Exploration via MCP

Use the Dart/Flutter MCP server tools to interactively explore and manipulate the application state before writing static tests.

- **Launch**: Execute `launch_app` with `target: "lib/main_test.dart"` to start the application and acquire the DTD URI.
- **Inspect**: Execute `get_widget_tree` to discover available `Key`s, `Text` nodes, and widget `Type`s.
- **Interact**: Execute `tap`, `enter_text`, and `scroll` to simulate user flows.
- **Wait**: Always execute `waitFor` or verify state with `get_health` when navigating or triggering animations.
- **Troubleshoot Unmounted Widgets**: If a widget is not found in the tree, it may be lazily loaded in a `SliverList` or `ListView`. Execute `scroll` or `scrollIntoView` to force the widget to mount before interacting with it.

## Test Authoring Guidelines

Structure integration tests using the `flutter_test` API paradigm. 

- Create a dedicated `integration_test/` directory at the project root.
- Name all test files using the `<name>_test.dart` convention.
- Initialize the binding by calling `IntegrationTestWidgetsFlutterBinding.ensureInitialized();` at the start of `main()`.
- Load the application UI using `await tester.pumpWidget(MyApp());

