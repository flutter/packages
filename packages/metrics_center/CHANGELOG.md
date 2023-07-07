## 1.0.10

* Adds retry logic when removing a `GcsLock` file lock in case of failure.

## 1.0.9

* Adds compatibility with `http` 1.0.

## 1.0.8

* Removes obsolete null checks on non-nullable values.
* Updates minimum Flutter version to 3.3.

## 1.0.7

* Updates code to fix strict-cast violations.
* Updates minimum SDK version to Flutter 3.0.

## 1.0.6

- Fixes lint warnings.

## 1.0.5

- Fix JSON parsing issue when running in sound null-safety mode.

## 1.0.4

- Fix un-await-ed Future in `SkiaPerfDestination.update`.

## 1.0.3

- Filter out host_name, load_avg and caches keys from context
  before adding to a MetricPoint object.

## 1.0.2

- Updated the GoogleBenchmark parser to correctly parse new keys added
  in the JSON schema.
- Fix `unnecessary_import` lint errors.
- Update version titles in CHANGELOG.md so plugins tooling understands them.
  - (Moved from `# X.Y.Z` to `## X.Y.Z`)

## 1.0.1

- `update` now requires taskName to scale metric writes

## 1.0.0

- Null safety support

## 0.1.1

- Update packages to null safe

## 0.1.0

- `update` now requires DateTime when commit was merged
- Removed `github` dependency

## 0.0.9

- Remove legacy datastore and destination.

## 0.0.8

- Allow tests to override LegacyFlutterDestination GCP project id.

## 0.0.7

- Expose constants that were missing since 0.0.4+1.

## 0.0.6

- Allow `datastoreFromCredentialsJson` to specify project id.

## 0.0.5

- `FlutterDestination` writes into both Skia perf GCS and the legacy datastore.
- `FlutterDestination.makeFromAccessToken` returns a `Future`.

## 0.0.4+1

- Moved to the `flutter/packages` repository
