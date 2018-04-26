# package:sentry changelog

## 2.0.1

- Invert stack frames to be compatible with Sentry's default culprit detection.

## 2.0.0

- Fixed deprecation warnings for Dart 2
- Refactored tests to work with Dart 2

## 1.0.0

- first and last Dart 1-compatible release (we may fix bugs on a separate branch if there's demand)
- fix code for Dart 2 

## 0.0.6

- use UTC in the `timestamp` field

## 0.0.5

- remove sub-seconds from the timestamp

## 0.0.4

- parse and report async gaps in stack traces

## 0.0.3

- environment attributes
- auto-generate event_id and timestamp for events

## 0.0.2

- parse and report stack traces
- use x-sentry-error HTTP response header
- gzip outgoing payloads by default

## 0.0.1

- basic ability to send exception reports to Sentry.io
