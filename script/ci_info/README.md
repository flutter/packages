# CI Info Scripts

This directory contains Dart scripts for interacting with LUCI/Buildbucket to analyze CI runs in `flutter/packages`. These scripts are useful for diagnosing CI failures and flakes.

No credentials or LUCI access are needed. Flutter's builds are public, and the scripts make only unauthenticated requests to Buildbucket.

## Usage

### Setup

Run the scripts from the repository root through `run.sh`, which fetches
dependencies on first use:

```bash
script/ci_info/run.sh <script> [args...]
```

`run.sh` uses the Dart SDK bundled with Flutter directly rather than Flutter's
`dart` wrapper, so several scripts can run in parallel without waiting on
Flutter's startup lock.

### Scripts

#### `bin/find_builds.dart`

Finds LUCI builds for a given Pull Request or commit SHA.

**Usage:**
```bash
script/ci_info/run.sh find_builds [options]
```

**Options:**
- `--pr`: GitHub PR number (presubmit tryjobs).
- `--commit`: Full commit SHA (postsubmit builds).
- `--repo`: Repository `owner/name` (defaults to `flutter/packages`).
- `--project`: LUCI project (defaults to `flutter`).
- `--limit`: Max builds to retrieve (defaults to `400`).
- `--[no-]failed-only`: Only show non-successful builds.
- `--[no-]json`: Output as JSON.
- `-h`, `--help`: Print usage information.

### Common Features

- **Caching**: All scripts cache network responses under `<system-temp>/ci_info_cache` (or the directory specified by the `CI_INFO_CACHE` environment variable) to speed up repeated runs.

## Development

Shared logic lives in `lib/` and unit tests live in `test/`. When making changes,
run the unit tests, analyzer, and formatter from `script/ci_info`:

```bash
cd script/ci_info
dart pub get
dart test
dart analyze --fatal-infos
dart format .
```
