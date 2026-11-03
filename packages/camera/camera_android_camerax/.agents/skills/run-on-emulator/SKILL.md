---
name: run-on-emulator
description: Boots an Android emulator and runs the camera_android_camerax example app or its integration tests via a bundled script. Use when asked to run integration tests, launch the example app, test on an emulator, or verify (including "manually verify") a change, and at the pre-push-skill integration test step.
metadata:
  internal: true
---
# Run on Emulator

This skill boots an Android emulator and runs the `camera_android_camerax`
example app or integration tests on it. All environment checks are performed
by a bundled, deterministic script ([tool/run.dart](tool/run.dart)) that
stops at the first problem with a distinct exit code.

> [!IMPORTANT]
> CI does not run this package's integration tests on emulators (it is listed
> in `script/configs/exclude_integration_android_emulator.yaml`), so running
> them locally is the only emulator coverage a change gets before review.

## What the emulator can verify

The AVD's emulated cameras (`virtualscene` on the back shows a 3D room;
`emulated` on the front shows a test pattern) run the real CameraX stack, so
the emulator can verify:

- The preview renders (not black or frozen) and switching cameras works.
- Image capture, video recording, and image streaming produce output.
- Exposure, zoom, and focus/metering API calls and their reported ranges.
- Rotation, lifecycle (background/resume), and permission flows.

## When NOT to use the emulator

The emulator only provides generic emulated cameras (`emulated`,
`virtualscene`, or a webcam). It **cannot** verify behavior that depends on
specific hardware, for example:

- Flash or torch output.
- Real lens characteristics: optical zoom ranges, focus distance, multiple
  physical back cameras, or camera extensions (HDR, night, bokeh).
- Device-specific sensor orientations, OEM camera quirks, or performance.

If the behavior under test depends on hardware like this, tell the user that
it requires a physical device and **do not** claim it was verified. You may
still use the `app` command to confirm the change does not crash or regress
the emulator's camera flow, as long as you report that limitation.

## Instructions

Run all commands from the `camera_android_camerax` package root. Always use the
script; do not start emulators or run `flutter test` by hand to work around a
script failure, because that bypasses the checks that keep runs reliable
(e.g. pre-granting camera permissions, which otherwise hang the tests
indefinitely).

| Goal | Command |
| --- | --- |
| Check the environment only | `dart run .agents/skills/run-on-emulator/tool/run.dart check` |
| Boot an emulator | `dart run .agents/skills/run-on-emulator/tool/run.dart emulator` |
| Build, install, and launch the example app | `dart run .agents/skills/run-on-emulator/tool/run.dart app` |
| Run all integration tests | `dart run .agents/skills/run-on-emulator/tool/run.dart integration-test` |
| Run matching integration tests only | `dart run .agents/skills/run-on-emulator/tool/run.dart integration-test --plain-name="Video capture"` |

Each command performs, in order, and stops at the first failure:

1. **Android CLI check**: `android` must be on the PATH, must be the Android
   CLI (not the legacy SDK tool), and must be at least version 1.1.
2. **Tool check**: `adb` (from the SDK reported by `android info sdk`, falling
   back to the PATH) and, for `app`/`integration-test`, `flutter`.
3. **Emulator**: reuses a running emulator, otherwise starts the first AVD
   from `android emulator list` (or `--avd=<id>`) with
   `android emulator start`, then waits for `sys.boot_completed`. For
   `app`/`integration-test`, the AVD must have at least one camera.
4. **Run**: builds a debug APK, installs it with all runtime permissions
   granted (`android install --install-options=-g`), then launches the app or
   runs `flutter test`.

Other options: `--avd=<id>`, `--target=<path relative to example/>`,
`--boot-timeout=<sec>`, `--test-timeout=<sec>`, `--stop-emulator` (stops the
emulator afterwards only if the script started it), `--allow-no-camera`,
`--headless` (starts the emulator without a window; use it when the user does
not need to watch). Run with `--help` for details.

The emulator is left running by default so later runs are fast. The full
integration test suite can take more than 10 minutes, so while iterating run
only the relevant tests with `--plain-name`, and save the full suite for the
final pre-push run. Run the full suite in the background and wait for it to
complete rather than polling.

### Handling the Results

The last line of output is always `RESULT: SUCCESS ...` or
`RESULT: FAILED (exit code N)`, preceded by an `ERROR:` line on failure.

| Exit code | Meaning | What to do |
| --- | --- | --- |
| 0 | Success | Report the result (see below). |
| 2 | Android CLI missing, too old, or not the Android CLI | **Stop.** Warn the user and relay the install or update instructions from the output. Do not install or update the CLI yourself (even though the [android-cli](../android-cli/SKILL.md) skill lists install commands), and do not try other ways to start an emulator. |
| 3 | `adb` or `flutter` missing | **Stop.** Warn the user and relay the fix from the output. |
| 4 | No usable AVD (none exist, `--avd` not found, or no camera) | **Stop.** Relay the suggested fix (e.g. `android emulator create medium_phone`, or editing the AVD's camera config) and ask the user before creating or modifying AVDs. |
| 5 | Emulator failed to start or boot | **Stop.** Report the error. Suggest `android emulator start --cold <avd>` or freeing disk/RAM. |
| 6 | Example app failed to build, install, or launch | Report the build/install error or crash. For crashes, read `adb -s <serial> logcat -d -b crash`. |
| 7 | Integration tests failed or timed out | Report each failing test and its error from the output. Re-run each failing test once with `--plain-name` to tell flakes (common right after a cold boot) from real failures, and report both results. On a timeout, take a screenshot (see [Verifying a Change](#verifying-a-change)) to find what is blocking the app. |
| 64 | Invalid arguments | Fix the command and re-run. |

## Writing Verification Steps in Implementation Plans

When writing an implementation plan, write emulator-observable verification as
steps **the agent performs** with this skill, not as steps for the user. Never
write "the user should run the emulator", "launch the app and confirm...", or
"manually run the integration tests". For example:

```markdown
## Verification Plan

### Automated (performed by the agent)
- Dart/native unit tests: ...
- Integration tests: add an integration test for <behavior> and run it with
  `run-on-emulator integration-test --plain-name="<test name>"`.
- Emulator check (only for coarse visual or OS-level behavior): run
  `run-on-emulator app`, <set up the condition, e.g. rotate or background>,
  and take a screenshot showing <expected result>.

### Requires a physical device or manual check (performed by the user)
- <Only hardware-dependent checks (e.g. flash firing) or subtle visual
  properties that cannot be asserted in a test (e.g. mirroring), with the
  reason.>
```

Leave out the user section entirely if nothing needs it.

## Verifying a Change

Use this workflow when an implementation plan has a verification step
(including one labeled "Manual Verification"), or the user asks for one. Do
it yourself rather than asking the user to. Pick the first option that can
verify the behavior:

1. **Logic that can be faked → Dart unit test** in `test/`. This is the
   cheapest option and covers device configurations the emulator cannot
   produce. Rotation math in particular belongs here (see
   [Rotation Bugs](#rotation-bugs)).
2. **Behavior that needs the real CameraX stack → integration test
   (default).** Add a `testWidgets` case to
   `example/integration_test/integration_test.dart` that reproduces the bug
   through `CameraPlatform.instance` (read [TESTING.md](../../../TESTING.md)
   first), and run it with `integration-test --plain-name="<test name>"`.
   When practical, confirm it fails without the fix (e.g. `git stash` the
   `lib/`/`android/` change) and passes with it. Assert on values (preview
   size, image dimensions, exposure offset, flash mode, file length) rather
   than on what the screen looks like. The test lands with the change as a
   regression test.
3. **OS-level conditions → `adb`, then test or observe.** Use the
   [recipes](#adb-recipes) below to rotate, background the app, or change
   permissions before or during an `app` or `integration-test` run. Always
   restore any settings you change.
4. **Visual behavior → screenshot, coarse properties only.** Run `app`
   (note the `serial=` value in the `RESULT:` line), set up the state, then
   take a screenshot and view it. See [Screenshots](#screenshots) for what a
   screenshot can and cannot prove.
5. **Report** what you ran, the results (embed screenshots), and anything
   you could not verify on an emulator, with the reason and exact manual
   steps for the user.

Do not use Flutter Driver (`enableFlutterDriverExtension`) or the Dart MCP
driver tools for verification: they can only see widgets, not plugin state,
and require changes to the example app. Write an integration test instead.

### Screenshots

Take screenshots with
`android screen capture --device=<serial> -o <artifact dir>/scratch/<name>.png`
and view the PNG before doing anything else. Add `--annotate` to label UI
elements with numbered boxes (see the [android-cli](../android-cli/SKILL.md)
skill for using the labels).

| A screenshot alone is enough for | A screenshot alone is NOT enough for |
| --- | --- |
| Preview visible vs. black or frozen | Aspect ratio or stretching |
| Preview rotated by 90° or 180° (use the back `virtualscene` camera) | Mirroring, crop, or framing |
| A control, dialog, or error appearing | Brightness, exposure level, color, or focus |
| No crash after an action | Frame rate or smoothness |

For anything in the right-hand column, assert it in a test. If it cannot be
expressed as a value, report it as **not verified on the emulator** and give
the user exact manual steps; you may attach the screenshot as context, but do
not present it as proof.

### Device Recipes

For general device interaction (the `android layout` JSON fields, annotated
screenshots, `android screen resolve`, and typing text), follow the
[android-cli](../android-cli/SKILL.md) skill.

Replace `<serial>` with the value from the `RESULT:` line. The example app ID
is `io.flutter.plugins.cameraxexample`.

- **Find and tap a widget:** `android layout --device=<serial> --flat` to
  find the element. The example app's camera controls have no text or
  content descriptions, so tap by class instead, e.g.
  `android input --device=<serial> tap clz=RadioButton --match=first`
  (selects the first camera and starts the preview), or tap the element's
  `center` from the layout with `adb -s <serial> shell input tap <x> <y>`.
  Do not guess coordinates from a screenshot. If a flow needs more than about
  five taps, write an integration test instead.
- **Background and resume:** `adb -s <serial> shell input keyevent KEYCODE_HOME`,
  then `adb -s <serial> shell am start -n io.flutter.plugins.cameraxexample/.MainActivity`.
- **Permissions:** `adb -s <serial> shell pm revoke io.flutter.plugins.cameraxexample android.permission.CAMERA`
  (relaunch to see the permission flow); restore with `pm grant`.
- **Captured files:** `adb -s <serial> shell run-as io.flutter.plugins.cameraxexample ls -R`
  to find them, then
  `adb -s <serial> exec-out run-as io.flutter.plugins.cameraxexample cat <path> > <artifact dir>/scratch/<file>`.
- **Logs for this run only:** `adb -s <serial> logcat -c` before reproducing,
  then `adb -s <serial> logcat -d --pid=$(adb -s <serial> shell pidof io.flutter.plugins.cameraxexample)`.
  If the app crashed, use `adb -s <serial> logcat -d -b crash` instead.

### Rotation Bugs

Rotation is a frequent source of bugs in this plugin. To verify a rotation
fix:

1. **Start with a Dart unit test.** Preview rotation is computed in Dart
   (`lib/src/rotated_preview_delegate.dart`, `rotated_preview_utils.dart`,
   `surface_texture_rotated_preview.dart`, `image_reader_rotated_preview.dart`;
   tests in `test/preview_rotation_test.dart`). Add cases for the exact device
   orientation, sensor orientation, and lens direction from the bug report.
   This is the only way to cover sensor orientations the emulator does not
   have.
2. **Cover both preview paths.** The delegate depends on
   `surfaceProducerHandlesCropAndRotation()`: the SurfaceTexture path handles
   rotation itself, and the ImageReader path (used with Impeller on API 29+)
   does not. A fix for one path may not apply to the other, so cover both in
   unit tests and report which path the emulator exercised.
3. **Fix the orientation before the run** so screenshots and integration
   tests are deterministic:

   ```bash
   adb -s <serial> shell settings put system accelerometer_rotation 0
   adb -s <serial> shell settings put system user_rotation 1  # 0=0°, 1=90°, 2=180°, 3=270°
   # Run `app` and take a screenshot, or run `integration-test --plain-name=...`.
   adb -s <serial> shell settings put system user_rotation 0  # Always restore.
   ```

4. **To test live orientation changes** (`onDeviceOrientationChanged`),
   enable auto-rotate (`settings put system accelerometer_rotation 1`), run
   `app`, then rotate with `adb -s <serial> emu rotate` and check the
   screenshot and logs.
5. **For naturally landscape devices**, use a tablet AVD (e.g.
   `android emulator create medium_tablet`, then `--avd=<id>`). Ask the user
   before creating AVDs.

Check captured photo orientation in an integration test (decoded width vs.
height), not by eye. Front camera mirroring is a subtle property, so follow
[Screenshots](#screenshots).
