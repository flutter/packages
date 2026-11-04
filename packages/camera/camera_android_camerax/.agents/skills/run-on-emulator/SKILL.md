---
name: run-on-emulator
description: Boots an Android emulator and runs the camera_android_camerax integration tests or example app on it. Use to run integration tests, launch the example app, or verify a change on an emulator, including "manual verification" steps and the pre-push-skill integration test step.
metadata:
  internal: true
---
# Run on Emulator

Run all commands from the `camera_android_camerax` package root. Work through
the sections in order.

## 1. Should you use an emulator for this?

The emulator's cameras (`virtualscene` on the back shows a 3D room, `emulated`
on the front shows a test pattern) run the real CameraX stack. The examples
below are not exhaustive.

The emulator can verify, for example:

- Preview rendering and switching cameras.
- Image capture, video recording, and image streaming.
- Exposure, zoom, and focus/metering calls and their reported ranges.
- Rotation, lifecycle (background/resume), and permission flows.

It cannot verify behavior that depends on specific hardware, for example:

- Flash or torch output.
- Real lens characteristics: optical zoom, focus distance, multiple back
  cameras, or camera extensions.
- Exact resolution preset sizes (emulated cameras do not support every preset).
- Device-specific sensor orientations, OEM quirks, or performance.

If the behavior depends on specific hardware, it needs a physical device: tell
the user, and do not claim it was verified. You may still run the example app
to check that the change does not crash.

## 2. Start an emulator

Do these steps in order. If a step says to stop, stop and tell the user what is
required. Do not install or update tools, create AVDs, or start an emulator
another way, even though the [android-cli](../android-cli/SKILL.md) skill
lists commands for some of these.

1. **Check the Android CLI:** run `android --version`. It must print version
   1.1 or newer. If the command is not found or prints no version, stop: the
   [Android CLI](https://developer.android.com/tools/agents) is required. If
   the version is older, stop and ask the user to run `android update`.
2. **Reuse a running emulator:** run `adb devices` (if `adb` is not on the
   PATH, use `"$(android info sdk)/platform-tools/adb"`). If it lists
   `emulator-<port>    device`, note that serial and skip to 3a or 3b.
3. **Pick an AVD:** run `android emulator list`. If it lists none, stop and
   suggest `android emulator create medium_phone`. Otherwise use the AVD the
   user named, or the first one.
4. **Check that the AVD has a camera:** run
   `grep hw.camera ~/.android/avd/<avd>.avd/config.ini`. If `hw.camera.back`
   and `hw.camera.front` are both `none`, stop: camera tests would pass without
   testing anything. (A missing `hw.camera.back` means `emulated`.)
5. **Start it:** run `android emulator start --headless <avd>` (omit
   `--headless` if the user wants to watch) and note the serial it prints. If
   it fails, stop and suggest `android emulator start --cold <avd>`.

Leave the emulator running for later runs. If you started it, stop it with
`android emulator stop <serial>` when you are done.

## 3. Run the integration tests or the example app

Continue with the subsection that matches your task:

- **3a. Run the integration tests** to reproduce a bug or verify a fix with a
  test, or to run the full suite before pushing. Prefer this when the behavior
  can be asserted in a test.
- **3b. Run the example app** to check behavior that a test cannot assert
  (e.g., a visual change), or to confirm that a change does not crash.

### 3a. Run the integration tests

1. **Grant permissions before every test command** (each `flutter test` or
   `drive-examples` run in step 2). Otherwise the camera permission dialog
   blocks the tests indefinitely. The test command keeps these grants when it
   reinstalls the app, but uninstalls the app when it finishes, so the grants
   do not carry over to the next run.

   ```bash
   (cd example && flutter build apk --debug)
   android install --apks=example/build/app/outputs/flutter-apk/app-debug.apk --device=<serial> --install-options=-g
   ```

2. **Run the tests.**
   - While iterating, run only the relevant tests:
     `(cd example && flutter test integration_test/integration_test.dart -d <serial> --plain-name "<test name>")`
   - For the full suite (e.g., before pushing), use the same tool as CI. It
     runs on the first Android device, so make sure the emulator is the only
     device in `adb devices`:
     `dart pub global run flutter_plugin_tools drive-examples --android --packages camera_android_camerax`

   The full suite takes several minutes, so run it in the background. If it
   stops making progress, take a screenshot (3b) to see what is
   blocking the app.
3. **Report** each failing test and its error. Re-run each failure once with
   `--plain-name` to tell flakes (common right after a cold boot) from real
   failures, and report both results. Failures in the resolution preset tests
   are expected on an emulator (see section 1).

### 3b. Run the example app

1. **Build, install, and launch it** with permissions granted:

   ```bash
   (cd example && flutter build apk --debug)
   android run --apks=example/build/app/outputs/flutter-apk/app-debug.apk --device=<serial> --install-options=-g
   ```

   Confirm it is still running with
   `adb -s <serial> shell pidof io.flutter.plugins.cameraxexample`. If that
   prints nothing, the app crashed; read `adb -s <serial> logcat -d -b crash`.
2. **Interact with it** using the [android-cli](../android-cli/SKILL.md) skill
   (`android layout`, `android input`). Flutter widgets appear in
   `android layout` through their accessibility semantics, so a widget only has
   text or a description if it sets one (e.g., a tooltip). The example app's
   camera controls set neither, so tap them by class, e.g.
   `android input --device=<serial> tap clz=RadioButton --match=first` selects
   the first camera. If a flow needs more than about five taps, write an
   integration test instead. Do not add Flutter Driver to the example app.
3. **For visual changes, include a screenshot as evidence** in your report:
   `android screen capture --device=<serial> -o <artifact dir>/scratch/<name>.png`.
   A screenshot can show that the preview is visible (not black or frozen),
   that it is rotated by 90° or 180°, or that a control or error appeared. It
   cannot show aspect ratio, mirroring, cropping, exposure, color, or frame
   rate: assert those in a test, or report them as not verified.
4. **For rotation bugs**, first try to reproduce with auto-rotate as is, since
   locking can change the behavior. If you need a specific orientation, you
   can lock it, and always restore it afterwards:

   ```bash
   adb -s <serial> shell settings put system accelerometer_rotation 0
   adb -s <serial> shell settings put system user_rotation 1  # 0=0°, 1=90°, 2=180°, 3=270°
   # Launch the app or run the tests, then restore:
   adb -s <serial> shell settings put system user_rotation 0
   ```
