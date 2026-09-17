---
name: espresso-setup-and-usage
description: Set up and use the espresso package to write and run native Android Espresso instrumentation tests that interact with Flutter widgets.
---

# Setting Up and Using espresso

The `espresso` package provides Java/Kotlin bindings for testing Flutter Android applications using Android's native Espresso testing framework. It allows driving and asserting on Flutter widgets alongside native Android views within instrumentation tests (SDK 24+).

## 1. Installation

Add `espresso` as a `dev_dependency` in your app's `pubspec.yaml`:

```bash
flutter pub add dev:espresso
```

Or manually in `pubspec.yaml`:

```yaml
dev_dependencies:
  espresso: ^0.4.0+26
  integration_test:
    sdk: flutter
```

## 2. Android Platform and Build Configuration

### Enable Cleartext Traffic for Testing
Espresso coordinates with the Flutter test driver over a local WebSocket using cleartext traffic. Enable cleartext traffic strictly in your `debug` or `androidTest` manifest so it is not shipped in release builds.

1. Create `android/app/src/debug/res/xml/network_security_config.xml`:

```xml
<network-security-config>
    <!-- Cleartext is needed for Espresso testing. -->
    <base-config cleartextTrafficPermitted="true">
    </base-config>
</network-security-config>
```

2. Reference it in `android/app/src/debug/AndroidManifest.xml`:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <application android:networkSecurityConfig="@xml/network_security_config">
    </application>
</manifest>
```

### Add Gradle Dependencies
Add the required Android test dependencies in `android/app/build.gradle.kts` (or `build.gradle`):

```kotlin
dependencies {
    testImplementation("junit:junit:4.13.2")
    api("androidx.test:core:1.6.1")
    androidTestImplementation("androidx.test:runner:1.6.1")
    androidTestImplementation("com.google.truth:truth:1.1.3")
    androidTestImplementation("androidx.test.espresso:espresso-core:3.6.1")
}
```

### Create the Dart Integration Test Driver
Create `test_driver/integration_test.dart` in your Flutter project root:

```dart
import 'package:integration_test/integration_test_driver.dart';

Future<void> main() => integrationDriver();
```

## 3. Usage and API Examples

### Writing an Android Espresso Test for Flutter Widgets

Create a test class under `android/app/src/androidTest/java/com/example/myapp/MainActivityTest.java`:

```java
package com.example.myapp;

import static androidx.test.espresso.flutter.EspressoFlutter.onFlutterWidget;
import static androidx.test.espresso.flutter.action.FlutterActions.click;
import static androidx.test.espresso.flutter.assertion.FlutterAssertions.matches;
import static androidx.test.espresso.flutter.matcher.FlutterMatchers.withText;
import static androidx.test.espresso.flutter.matcher.FlutterMatchers.withTooltip;
import static androidx.test.espresso.flutter.matcher.FlutterMatchers.withValueKey;

import androidx.test.core.app.ActivityScenario;
import androidx.test.ext.junit.runners.AndroidJUnit4;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;

@RunWith(AndroidJUnit4.class)
public class MainActivityTest {

    @Before
    public void setUp() {
        ActivityScenario.launch(MainActivity.class);
    }

    @Test
    public void incrementCounterUpdatesText() {
        // Perform a click on a Flutter widget matched by its tooltip
        onFlutterWidget(withTooltip("Increment")).perform(click());

        // Assert that a Flutter widget with ValueKey("CountText") displays expected text
        onFlutterWidget(withValueKey("CountText"))
            .check(matches(withText("Button tapped 1 time.")));
    }
}
```

### Running Espresso Tests Locally

From your project's `android/` directory, run `connectedAndroidTest` targeting your Dart driver file:

```bash
./gradlew app:connectedAndroidTest -Ptarget=$(pwd)/../test_driver/integration_test.dart
```

### Running on Firebase Test Lab

Assemble both APKs and run instrumentation tests on Firebase Test Lab:

```bash
./gradlew app:assembleAndroidTest
./gradlew app:assembleDebug -Ptarget=$(pwd)/../test_driver/integration_test.dart

gcloud firebase test android run --type instrumentation \
  --app build/app/outputs/apk/debug/app-debug.apk \
  --test build/app/outputs/apk/androidTest/debug/app-debug-androidTest.apk \
  --timeout 2m
```
