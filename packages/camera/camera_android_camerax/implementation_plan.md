# Plan: fix preview not resuming after pausing while recording with image streaming (option B)

**Issue:** [flutter/flutter#195832](https://github.com/flutter/flutter/issues/195832)
**Package:** `packages/camera/camera_android_camerax`. No changes to the `camera` package, native code or Pigeon.
**Code references:** upstream `main` @ `66688c0534`. Line numbers are approximate; search by name.

## 1. The bug
While recording with image streaming, four use cases are bound: `Preview`, `ImageCapture`, `ImageAnalysis` and `VideoCapture`. CameraX serves that combination with **stream sharing**, where one camera stream feeds both `Preview` and `VideoCapture`.

Today the plugin pauses and resumes the preview by changing which use cases are bound:
- `pausePreview` (~L952) unbinds `Preview`.
- `resumePreview` (~L999) rebinds it through `_bindUseCaseToLifecycle` (~L1388).

Rebinding `Preview` in the middle of a recording moves `VideoCapture` back into stream sharing, which fails with `The provider's size(720x1280) must match the parent(1280x720)`. Pausing *before* recording and resuming *during* it fails the same way. On current code, stopping the recording after that failure has also crashed the example app (`AssertionError: Unexpectedly invoke onConfigured() in a STOPPING state` in CameraX's `Recorder`).

The bug reproduces on the `Pixel_9` emulator (API 36).

## 2. Approach: freeze during recordings, unbind otherwise
**Rule: never change the bound use cases while a recording is active.**

| State | `pausePreview` | `resumePreview` |
| --- | --- | --- |
| Not recording | Unbind `Preview` (today's behavior) **and** freeze the `Texture` | Unfreeze, then bind `Preview` if it isn't bound |
| Recording | Freeze the `Texture` only; `Preview` stays bound | Unfreeze only; `Preview` is already bound |

Two transitions keep this consistent:
- **Recording starts while paused:** `startVideoCapturing` binds `Preview` *before* binding `VideoCapture` (and before the recording starts), so stream sharing is set up once. The texture stays frozen.
- **Recording ends while paused** (stop, or failure to start): after `VideoCapture` is unbound, unbind `Preview` again, so the paused, not-recording state matches the first row.

**Why not freeze only (option A)?** The `SurfaceTexture` preview backend ignores `Texture.freeze`. That backend is used below API 29, on some devices with AHardwareBuffer defects, or when forced. Freezing alone would make pause stop working entirely on those devices, even when not recording. Unbinding outside recordings avoids that regression.

An engine fix is planned separately (see §7). Once the plugin's minimum Flutter version includes it, we can simplify to "always freeze, never unbind".

**Known limitation to document:** on the `SurfaceTexture` backend, pausing *during a recording* won't visibly freeze the preview until the engine fix lands. It no longer crashes, and the recording continues.

## 3. Code changes: `lib/src/android_camera_camerax.dart`
1. **Pause state** (~L124): replace `bool _previewIsPaused` with a `ValueNotifier<bool>`, so the widget returned by `buildPreview` reacts to pause and resume without the caller rebuilding it. That matches today's contract, where pausing affects the preview immediately. Add a short `///` comment explaining why.
2. **`buildPreview`** (~L1009):
   - Wrap the existing `RotatedPreviewDelegate` in a `ValueListenableBuilder<bool>` that builds `Texture(textureId: cameraId, freeze: isPaused)`.
   - Keep `Texture` as the delegate's direct child, because `test/preview_rotation_test.dart` asserts on that.
   - Create the orientation stream once, outside the builder, so pausing doesn't hand the rotation widgets a new stream.
3. **`pausePreview`:** set paused to `true`. If `recording == null`, also unbind `Preview` (`_unbindUseCaseFromLifecycle`). Add a comment explaining why `Preview` stays bound during recordings (stream sharing).
4. **`resumePreview`:** set paused to `false`, then bind `Preview` only if it isn't bound. Remove the `useCaseIsPausedPreview` guard from `_bindUseCaseToLifecycle` (~L1390) so callers decide whether to bind.
5. **`startVideoCapturing`** (~L1207): before `_bindUseCaseToLifecycle(videoCapture!, ...)`, bind `Preview` if it isn't bound (because it was paused). The paused flag stays `true`, so the texture stays frozen.
6. **When a recording ends**, add a small private helper, something like `_unbindPausedPreviewIfNotRecording()`, and call it:
   - in `stopVideoRecording` (~L1291), after `VideoCapture` is unbound;
   - in `_waitForRecordingToStart` (~L1262), after it unbinds `VideoCapture` because the recording finalized before it started.
7. **`setDescriptionWhileRecording`** (~L963): always include `preview!` in the rebind list, since `Preview` is always bound during recordings. The texture stays frozen if paused.
8. **`initializeCamera`** (~L502) and **`dispose`** (~L533): reset paused to `false`.
9. **Docs:** update the `///` comments on `pausePreview` and `resumePreview` to describe the behavior and the `SurfaceTexture` limitation.

Expected size: about 60–90 library lines and no new files.

## 4. Tests
Read and follow `packages/camera/camera_android_camerax/TESTING.md` first. In particular, wait at least 4 s before stopping any recording in integration tests.

### Unit tests: `test/android_camera_camerax_test.dart`
Update the existing pause/resume tests (search for `pausePreview`) and add the following. Each "✅" test must fail on current code.

| # | Test | Fails before fix? |
| --- | --- | --- |
| U1 | `pausePreview` while not recording unbinds `Preview` (existing behavior, kept) | No (regression guard) |
| U2 | `pausePreview` while recording does **not** unbind anything | ✅ |
| U3 | `resumePreview` while recording does **not** call `bindToLifecycle` | ✅ |
| U4 | `startVideoCapturing` while paused binds `Preview` **before** `VideoCapture` (use `verifyInOrder`) | ✅ |
| U5 | `stopVideoRecording` while paused unbinds `Preview` after `VideoCapture` | ✅ |
| U6 | A recording that finalizes before starting, while paused, unbinds `Preview` again | ✅ |
| U7 | `setDescriptionWhileRecording` rebinds `Preview` even when paused (update the existing test) | ✅ (the existing assertion flips) |
| U8 | `resumePreview` while not recording binds `Preview` (existing behavior, kept) | No (regression guard) |
| U9 | `initializeCamera` resets the paused state | Regression guard |

Some binding tests from the earlier attempt (commit `307d186f5e`, `git show 307d186f5e -- test/android_camera_camerax_test.dart`) may be reusable for U2, U3 and U7. Adapt them; don't copy that commit's snapshot logic.

### Widget tests
| # | Test |
| --- | --- |
| W1 | The widget from `buildPreview` has `Texture.freeze == true` after `pausePreview` and `false` after `resumePreview`, **without rebuilding the parent** (pump the widget once, then just `pump()`) |
| W2 | `buildPreview` called while paused builds a frozen `Texture` |

### Integration tests: `example/integration_test/integration_test.dart`
Keep these to two or three, with no pixel-threshold or screenshot assertions:

| # | Test | Fails before fix? |
| --- | --- | --- |
| I1 | Record with image streaming (`ResolutionPreset.high`, audio disabled). Pause the preview, wait, then resume: `resumePreview` must not throw. Wait at least 4 s, then stop: `stopVideoRecording` must succeed, and the video must be valid with a duration covering the recording. | ✅ |
| I2 | Pause the preview, start recording with image streaming, resume during the recording, wait at least 4 s, stop: no throw, valid video. | ✅ |
| I3 (optional) | Pause during a recording, stop the recording while paused, resume: preview resumes and `takePicture` succeeds | Regression guard |

## 5. Verification (agent does all of this itself)
Follow the `run-on-emulator` skill. Nothing here needs physical hardware.
1. **Reproduce first:** add I1 and I2, then run them against unmodified code with run-on-emulator 3a and `--plain-name`. Grant permissions before every run. Expected:
   - `resumePreview` throws the error from the issue;
   - or the app crashes when the recording stops, and the test reports "did not complete". That counts as a reproduction.

   Run `adb logcat -c` before and search `logcat -d` after for the stream-sharing error lines (for example `Downstream node failed to provide Surface`).
2. **Implement, then run the Dart unit and widget tests.** Confirm the new "✅" tests fail without the fix and pass with it.
3. **Green on both preview backends:**
   - Run I1–I3 on the default backend (`ImageReader`).
   - Run them again with the `SurfaceTexture` backend forced (run-on-emulator 3b.6). Don't commit that `MainActivity` change.
   - Logcat should have no CameraX surface errors.
4. **Example app check** (run-on-emulator 3b), on the default backend:
   - Start recording with the record button.
   - Pause the preview: the rightmost top-row button turns red, and the preview freezes. Compare only the preview area of screenshots taken a few seconds apart, after first confirming the live preview changes over the same interval.
   - Resume, then stop. The app must not crash, and the video must be saved.
   - Also check that pausing while *not* recording still freezes the preview.
5. **Full suite:** run `drive-examples`. The two resolution-preset tests are expected to fail on an emulator.

## 6. Repository standards
- **Release info:** run `update-release-info --version=minimal --base-branch=<upstream>/main`. Upstream is already at `0.7.6+2`, so expect `0.7.6+3`. Suggested CHANGELOG entry: "Fixes the preview failing to resume after pausing it while recording video with image streaming."
- **Pre-push:** run format, analyze, `dart-test`, `native-test --no-integration` (to confirm nothing broke), `validate`, `publish-check`, `license-check`, and finally the `pre-push-skill`.
- **Branch:** work on `camx_195832_take3`, which is stacked on `camx_emulator` so the skill is available. Merge `upstream/main` into it first. When opening the PR, rebase onto `upstream/main` so only the fix commit remains, and don't commit plan files to the package.
- **PR description:** draft it for the user to post. Link #195832, explain the freeze-during-recording design and the `SurfaceTexture` limitation, link the engine issue, and list what was verified on the emulator.

## 7. Follow-ups (outside this PR)
- **Engine:** make the `SurfaceTexture` external texture honor `Texture.freeze` (separate plan: `engine_texture_freeze_plan.md`). Link the engine issue in the PR and in the `pausePreview` docs once it's filed.
- **After the engine fix reaches the plugin's minimum Flutter version:** simplify to always freeze and never unbind for pausing. File a tracking issue for that.
- **Separate plugin bug** found during the earlier attempt: a recording abandoned by `dispose` can finalize late, and its event lands on the *next* recording. File it separately; don't fix it here.

## 8. Decisions already made (don't revisit)
- Use the middle design (§2), not freeze-only, and not the snapshot overlay from `307d186f5e`.
- No new files, no pixel-diff integration tests, and no native or Pigeon changes.
