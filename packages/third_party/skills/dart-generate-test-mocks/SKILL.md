description: Define and generate mock objects for external dependencies using `package:mockito` and `build_runner`. Use when unit testing classes that depend on complex external services like APIs or databases.
metadata:
  model: models/gemini-3.1-pro-preview
  last_modified: Fri, 24 Apr 2026 15:13:58 GMT
---
# Testing and Mocking Dart Applications

## Contents
- [Structuring Code for Testability](#structuring-code-for-testability)
- [Managing Dependencies](#managing-dependencies)
- [Generating Mocks](#generating-mocks)
- [Implementing Unit Tests](#implementing-unit-tests)
- [Workflow: Creating and Running Mocked Tests](#workflow-creating-and-running-mocked-tests)
- [Examples](#examples)

## Structuring Code for Testability
Design Dart classes to support dependency injection. Isolate complex external dependencies (like API clients or databases) so they can be replaced with mock objects during testing.

- Inject external services (e.g., `http.Client`) through class constructors.
- Represent URLs strictly as `Uri` objects using `Uri.parse(string)`.
- Utilize Dart's object-oriented features (classes, mixins) to define clear interfaces for external interactions.

## Managing Dependencies
Configure the `pubspec.yaml` file with the necessary testing and code generation packages.

- Add runtime dependencies (e.g., `package:http`) using `dart pub add http`.
- Add testing dependencies using `dart pub add dev:test dev:mockito dev:build_runner`.
- Import HTTP libraries with a prefix to avoid namespace collisions: `import 'package:http/http.dart' as http;`.

## Generating Mocks
Use `package:mockito` and `build_runner` to automatically generate mock classes for fixed scenarios and behavior verification.

- Always use the `@GenerateNiceMocks` annotation (preferable to `@GenerateMocks` to avoid missing stub exceptions).
- Place the annotation in the test file, passing a list of `MockSpec<Type>()` objects.
- Import the generated file using the `.mocks.dart` extension.
- Execute `build_runner` to generate the mock files: `dart run build_runner build`.

## Implementing Unit Tests
Isolate the system under test using the generated mock objects. Use `package:test` to structure the test suite.

- **Stubbing:** Configure mock behavior before interacting with the system under test.
  - Use `when(mock.method()).thenReturn(value)` for synchronous methods.
  - **CRITICAL:** Always use `thenAnswer((_) async => value)` for methods

