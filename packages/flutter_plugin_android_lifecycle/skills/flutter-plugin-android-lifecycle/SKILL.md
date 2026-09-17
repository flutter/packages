---
name: flutter-plugin-android-lifecycle
description: Set up and use flutter_plugin_android_lifecycle to access Android androidx.lifecycle.Lifecycle objects within custom Flutter Android plugins.
---

# Setting Up and Using flutter_plugin_android_lifecycle

The `flutter_plugin_android_lifecycle` plugin allows other Flutter Android plugins to access `androidx.lifecycle.Lifecycle` objects from the `ActivityPluginBinding`. Including this package as a dependency ensures that plugins declare an explicit pub version constraint corresponding to the major version of the Android `Lifecycle` API they require.

## 1. Installation

Add `flutter_plugin_android_lifecycle` to the `dependencies` section of your Flutter plugin's `pubspec.yaml`:

```bash
flutter pub add flutter_plugin_android_lifecycle
```

Or manually in `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_plugin_android_lifecycle: ^2.0.35
```

## 2. Platform Configuration

- **Minimum Android SDK**: Requires Android SDK 24 or higher.
- Ensure your plugin's Android implementation implements both `FlutterPlugin` and `ActivityAware` from `io.flutter.embedding.engine.plugins`.

## 3. Usage and API Examples

### Accessing `Lifecycle` in an Android Plugin (Kotlin)

Use `FlutterLifecycleAdapter.getActivityLifecycle(binding)` inside your plugin's `onAttachedToActivity` callback to obtain the `Lifecycle` instance and register a `DefaultLifecycleObserver` or `LifecycleEventObserver`:

```kotlin
package com.example.my_plugin

import androidx.lifecycle.DefaultLifecycleObserver
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleOwner
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.embedding.engine.plugins.lifecycle.FlutterLifecycleAdapter

class MyPlugin : FlutterPlugin, ActivityAware, DefaultLifecycleObserver {
    private var lifecycle: Lifecycle? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        // Initialize plugin channels or resources.
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        // Clean up engine-level resources.
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        lifecycle = FlutterLifecycleAdapter.getActivityLifecycle(binding).also {
            it.addObserver(this)
        }
    }

    override fun onDetachedFromActivityForConfigChanges() {
        onDetachedFromActivity()
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        onAttachedToActivity(binding)
    }

    override fun onDetachedFromActivity() {
        lifecycle?.removeObserver(this)
        lifecycle = null
    }

    override fun onResume(owner: LifecycleOwner) {
        // Handle Activity onResume lifecycle event.
    }

    override fun onPause(owner: LifecycleOwner) {
        // Handle Activity onPause lifecycle event.
    }
}
```

### Accessing `Lifecycle` in an Android Plugin (Java)

```java
package com.example.my_plugin;

import androidx.annotation.NonNull;
import androidx.lifecycle.DefaultLifecycleObserver;
import androidx.lifecycle.Lifecycle;
import androidx.lifecycle.LifecycleOwner;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.embedding.engine.plugins.lifecycle.FlutterLifecycleAdapter;

public class MyPlugin implements FlutterPlugin, ActivityAware, DefaultLifecycleObserver {
  private Lifecycle lifecycle;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {}

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {}

  @Override
  public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
    lifecycle = FlutterLifecycleAdapter.getActivityLifecycle(binding);
    lifecycle.addObserver(this);
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {
    onDetachedFromActivity();
  }

  @Override
  public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
    onAttachedToActivity(binding);
  }

  @Override
  public void onDetachedFromActivity() {
    if (lifecycle != null) {
      lifecycle.removeObserver(this);
      lifecycle = null;
    }
  }

  @Override
  public void onResume(@NonNull LifecycleOwner owner) {
    // React to activity resume.
  }
}
```
