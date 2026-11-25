---
name: run-on-emulator
description: Use to boot an Android emulator and then run the camera_android_camerax integration tests, launch the example app on it, or verify changes on it, including "manual verification" steps and the pre-push-skill integration test step.
metadata:
  internal: true
---
# Run on Emulator

Run all commands from the `camera_android_camerax` package root. Work through
the sections in order.

## 1. Should you use an emulator for this?

Yes, unless the behavior depends on specific hardware. The emulator's cameras
run the real CameraX stack: the back camera (`virtualscene`) shows a 3D room,
and the front camera (`emulated`) shows a test pattern that changes over time.
The examples below are not exhaustive.

The emulator can verify, for example:

- Preview rendering and switching cameras, including whether the preview is
  live or frozen.
- Image capture, video recording, and image streaming, including CameraX
  stream sharing (e.g., recording while streaming images).
- Exposure, zoom, and focus/metering calls and their reported ranges.
- Rotation, lifecycle (background/resume), and permission flows.
- Both preview backends: `ImageReader` (the default on API 29+) and
  `SurfaceTexture` (used below API 29; see 3b).

It cannot verify behavior that depends on specific hardware, for example:

- Flash or torch output.
- Real lens characteristics: optical zoom, focus distance, multiple back
  cameras, or camera extensions.
- Exact resolution preset sizes (emulated cameras do not support every preset).
- Device-specific sensor orientations, OEM quirks, or performance.
- On Apple silicon hosts, video recording on API 28: the arm64 API 28 images'
  video encoder crashes as soon as recording starts. To cover the
  `SurfaceTexture` preview backend that API 28 uses, see 3b.

If the behavior depends on specific hardware, it needs a physical device: tell
the user, and do not claim it was verified (you may still run the example app
to check that the change does not crash). Otherwise, verify it yourself, even
plan steps labeled "manual" or addressed to the user, and write
implementation plans that way. If you are not sure whether the emulator can
reproduce a bug, try it on the emulator before deciding.

## 2. Start an emulator

Do these steps in order. If a step says to stop, stop and tell the user what is
required. Ask the user before installing or updating tools or creating AVDs,
even though the [android-cli](../android-cli/SKILL.md) skill lists commands
for these: they change the user's machine and can download gigabytes. If a
step fails, report it instead of working around it with other tools, so the
user learns about the broken setup.

1. **Check the Android CLI:** run `android --version`. It must print version
   1.1 or newer, which added the `android install --install-options`,
   `android screen capture --device`, and `android input` commands this skill
   uses. If the command is not found or prints no version, stop: the
   [Android CLI](https://developer.android.com/tools/agents) is required. If
   the version is older, stop and ask the user to run `android update`.
2. **Reuse a running emulator:** run `adb devices` (if `adb` is not on the
   PATH, use `"$(android info sdk)/platform-tools/adb"`). If it lists
   `emulator-<port>    device`, note that serial, get its AVD name with
   `adb -s <serial> emu avd name`, run step 4 for that AVD, and then skip to 3a
   or 3b.
3. **Pick an AVD:** run `android emulator list --long`. If it lists none, stop
   and suggest `android emulator create medium_phone`. Otherwise use the AVD
   the user named, or the one with the highest API level. To test the
   `SurfaceTexture` preview backend, you do not need an older API level (see
   3b). If the task needs an API level that no AVD has, stop and ask the user
   to approve creating one. Once they approve, run (for example, for API 30):

   ```bash
   android sdk install system-images/android-30/google_apis/arm64-v8a
   "$(android info sdk)/cmdline-tools/latest/bin/avdmanager" create avd -n Pixel_API_30 -k "system-images;android-30;google_apis;arm64-v8a" -d pixel_6
   ```

   Use `x86_64` instead of `arm64-v8a` on Intel hosts. Then set
   `hw.camera.back` and `hw.camera.front` to `emulated` in the new AVD's
   `config.ini` (see step 4).
4. **Check that the AVD has a camera:** run
   `grep hw.camera ~/.android/avd/<avd>.avd/config.ini`. If `hw.camera.back`
   and `hw.camera.front` are both `none`, stop: camera tests would pass without
   testing anything. Ask the user to approve setting them to `emulated` in
   that file (with the emulator stopped), or to use or create another AVD
   (step 3). (A missing `hw.camera.back` means `emulated`.)
5. **Start it:** run `android emulator start --headless <avd>` (omit
   `--headless` if the user wants to watch) and note the serial it prints. If
   it fails, stop and suggest `android emulator start --cold <avd>`.

Keep the emulator running while you work. When your task is finished, stop it
with `android emulator stop <serial>` if you started it.

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

   On older API levels, `android install` may log a crash from its on-device
   installer before falling back to a standard install. That is harmless if
   the command succeeds.

2. **Run the tests.** The repo's tooling runs these tests with `flutter test`,
   not `flutter drive`, so use these commands rather than the `flutter drive`
   command in the flutter-add-integration-test skill.
   - While iterating, run only the relevant tests:
     `(cd example && flutter test integration_test/integration_test.dart -d <serial> --plain-name "<test name>")`
   - For the full suite (e.g., before pushing), use the same tool as CI. It
     runs on the first Android device, so make sure the emulator is the only
     device in `adb devices`:
     `dart pub global run flutter_plugin_tools drive-examples --android --packages camera_android_camerax`.
     If another device is attached, run
     `(cd example && flutter test integration_test -d <serial>)` instead.

   The full suite takes several minutes, so run it in the background. If it
   stops making progress, take a screenshot (3b) to see what is
   blocking the app. If you kill a test run, delete `example/build/test/`
   afterwards: the generated test files left there fail the repo's
   pre-commit analysis. If logcat shows
   `Failed to close CameraDevice ... The camera is likely in a bad state`,
   the emulator's camera service is stuck, not the code under test: stop and
   start the emulator again (section 2, step 5), grant permissions, and rerun.
3. **Report** each failing test and its error. Re-run each failure once with
   `--plain-name` to tell flakes (common right after a cold boot) from real
   failures, and report both results. Failures in the two resolution preset
   tests ("Preview takes expected resolution from preset" and "Images from
   streaming have expected resolution from preset") are expected on an
   emulator (see section 1).

When a test checks that video recording kept going, note that a recorded
file's duration includes its audio track, so it does not prove video frames
kept arriving. Record with audio disabled when asserting on duration, and check
for CameraX errors: run `adb -s <serial> logcat -c` before the test and search
`adb -s <serial> logcat -d` afterwards (e.g., for
`Downstream node failed to provide Surface`).

### 3b. Run the example app

1. **Build, install, and launch it** with permissions granted. Always
   rebuild first: the APK at that path may be out of date, or it may be an
   integration test build (`flutter test` writes one there), which only
   shows a splash screen when launched.

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
   controls set neither, so find them in
   `android layout --device=<serial> --flat` and tap the reported `center`
   with `adb -s <serial> shell input tap <x> <y>`. For the camera selectors,
   `android input --device=<serial> tap clz=RadioButton --match=first` also
   works. The controls, in layout order:
   - **Top row (5 buttons):** take picture, record video, pause/resume
     *recording*, stop recording, and pause/resume *preview* (the rightmost;
     disabled until a camera is selected, red while the preview is paused).
   - **Second row (5 buttons):** flash mode, exposure mode, focus mode, audio
     on/off, and orientation lock.
   - **Bottom row:** one radio button per camera, in `availableCameras()`
     order. On the `Pixel_9` AVD, the first is the front camera.

   If the check needs more than a few taps, or you will need to repeat it,
   write an integration test instead so it is repeatable. Do not add Flutter
   Driver to the example app.
3. **For visual changes, include a screenshot as evidence** in your report:
   `android screen capture --device=<serial> -o <file>.png`, saved to a scratch
   directory outside the repository. A screenshot can show that the preview is
   visible (not black), that it is rotated by 90° or 180°, or that a control or
   error appeared. To tell whether the preview is live or frozen, take two
   screenshots of the front camera a few seconds apart (its test pattern changes
   over time) and compare only the preview area, by viewing both or by diffing
   that region. Do not compare whole files or hashes: the status bar clock
   changes between screenshots. A screenshot cannot show aspect ratio,
   mirroring, cropping, exposure, color, or frame rate: assert those in a test,
   or report them as not verified. To check short-lived effects (e.g., a flash
   when pausing), record the screen with
   `adb -s <serial> shell screenrecord --time-limit <sec> /sdcard/<name>.mp4`,
   pull it with `adb -s <serial> pull`, and inspect its frames (e.g., with
   `ffmpeg`, if it is installed).
4. **For lifecycle bugs**, background and resume the app with
   `adb -s <serial> shell input keyevent KEYCODE_HOME`, then
   `adb -s <serial> shell am start -n io.flutter.plugins.cameraxexample/.MainActivity`.
5. **For rotation bugs**, first try to reproduce with auto-rotate as is, since
   locking can change the behavior. If you need a specific orientation, you
   can lock it, and always restore it afterwards:

   ```bash
   adb -s <serial> shell settings get system accelerometer_rotation  # Note the original value.
   adb -s <serial> shell settings put system accelerometer_rotation 0
   adb -s <serial> shell settings put system user_rotation 1  # 0=0°, 1=90°, 2=180°, 3=270°
   # Launch the app or run the tests, then restore:
   adb -s <serial> shell settings put system user_rotation 0
   adb -s <serial> shell settings put system accelerometer_rotation <original value>
   ```
6. **To test the `SurfaceTexture` preview backend** (used below API 29) on a
   newer emulator, temporarily force it in the example app's `MainActivity`
   and rebuild. Do not commit this change:

   ```kotlin
   import android.os.Bundle
   import io.flutter.embedding.engine.renderer.FlutterRenderer

   // In MainActivity:
   override fun onCreate(savedInstanceState: Bundle?) {
     FlutterRenderer.debugForceSurfaceProducerGlTextures = true
     super.onCreate(savedInstanceState)
   }
   ```

   To confirm the switch took effect, open a camera and check that
   `adb -s <serial> logcat -d | grep 'Surface(name=android.graphics.SurfaceTexture'`
   prints a match. This covers the backend, not other API-level differences.
   If those matter, ask the user to approve an AVD with the API level you need
   (section 2, step 3).
