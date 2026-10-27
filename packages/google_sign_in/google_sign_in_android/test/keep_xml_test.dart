import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('plugin uses uniquely named keep.xml to avoid app collisions', () {
    // Determine the path to the android directory
    // When running tests, the current directory is typically the package root.
    final Directory androidDir = Directory('android/src/main/res/raw');

    // Fallback path in case the test is run from a different working directory
    // (e.g. from the monorepo root)
    final Directory fallbackAndroidDir = Directory(
      'packages/google_sign_in/google_sign_in_android/android/src/main/res/raw',
    );

    final Directory targetDir = androidDir.existsSync() ? androidDir : fallbackAndroidDir;

    expect(
      targetDir.existsSync(),
      isTrue,
      reason: "Could not find android/src/main/res/raw directory.",
    );

    final File genericKeepXml = File('${targetDir.path}/keep.xml');
    final File uniqueKeepXml = File('${targetDir.path}/google_sign_in_keep.xml');

    // Assert that the generic keep.xml does NOT exist.
    // If it did, an app's keep.xml would overwrite it during resource merging,
    // causing the shrinker to strip the plugin's kept resources (like default_web_client_id).
    expect(
      genericKeepXml.existsSync(),
      isFalse,
      reason:
          "The plugin must not use a generic keep.xml file, as it will be overwritten by the app's keep.xml during resource merging.",
    );

    // Assert that the uniquely named keep.xml DOES exist.
    expect(
      uniqueKeepXml.existsSync(),
      isTrue,
      reason:
          "The plugin must provide a uniquely named keep.xml (google_sign_in_keep.xml) to preserve resources.",
    );
  });
}
