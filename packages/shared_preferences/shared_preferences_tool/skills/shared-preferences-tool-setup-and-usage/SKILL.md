---
name: shared-preferences-tool-setup-and-usage
description: Use, develop, and build the Flutter DevTools extension for inspecting and editing shared_preferences keys at runtime.
---

# Using and Developing shared_preferences_tool

`shared_preferences_tool` is the Flutter DevTools extension bundled with `package:shared_preferences`. It enables developers to inspect, search, edit, add, and remove key-value pairs stored in `SharedPreferences`, `SharedPreferencesAsync`, and `SharedPreferencesWithCache` at runtime.

## 1. Installation and Setup

### For App Developers
You do not need to install `shared_preferences_tool` separately. It is pre-compiled and distributed automatically inside `package:shared_preferences` (under `extension/devtools/`).

When running a Flutter app in debug or profile mode that depends on `shared_preferences`:
1. Open **Flutter DevTools**.
2. Navigate to the **shared_preferences** extension tab.
3. Inspect and modify preferences (`String`, `int`, `double`, `bool`, `List<String>`) live.

## 2. Running and Developing the Extension Locally

If you are contributing to `shared_preferences_tool` in the Flutter packages repository:

1. Start a debug session of a Flutter app using `shared_preferences` (such as the example app in `packages/shared_preferences/shared_preferences/example`) and note its VM Service / Debug URL.
2. Run the DevTools extension web app in Chrome with a simulated DevTools environment:

```shell
flutter run -d chrome --dart-define=use_simulated_environment=true
```

## 3. Building and Publishing the Extension Asset

Before publishing a new version of `package:shared_preferences` with updated DevTools extension changes, compile and copy the web assets into the `shared_preferences` package:

```shell
# 1. Build the extension and copy assets to shared_preferences
dart run devtools_extensions build_and_copy \
  --source=. \
  --dest=../shared_preferences/extension/devtools

# 2. Validate extension configuration
dart run devtools_extensions validate --package=../shared_preferences
```
