# quick\_actions\_android

The Android implementation of [`quick_actions`][1].

## Usage

This package is [endorsed][2], which means you can simply use `quick_actions`
normally. This package will be automatically included in your app when you do,
so you do not need to add it to your `pubspec.yaml`.

However, if you `import` this package to use any of its APIs directly, you
should add it to your `pubspec.yaml` as usual.

## Usage with launcher activities

If you have an activity that launches a `FlutterActivity` (this is
`MainActivity.java`/`MainActivity.kt` by default), then you might need to
modify the launch configuration of that activity to have the back press
behavior and task back stack that you expect. Common use cases of having
such a launcher activity are in an add to app project or if your Flutter
project contains multiple Android activities.

For example, consider the case where you have two different quick actions
shortcuts for your app and a launcher activity that launches the
`FlutterActivity`. If the launcher activity uses the [`singleTop`][4] launch
mode (as Flutter's default `MainActivity.java`/`MainActivity.kt` do by default)
and the user

1. Launches your app from the first shortcut
2. Moves your app into the background by exiting the app
3. Re-launches your app from the second shortcut

then the user will see what the first shortcut launched, not what the second
shortcut was supposed to launch. To fix this, you may set the launch mode of
the launcher activity to `singleInstance` (see [Android documentation][5] for
more information on this mode) in 
`your_app/android/app/src/mainAndroidManifest.xml`:

```xml
<activity
        ...
        android:launchMode="singleInstance">
```

See [this issue][6] for more context on this exact scenario and its solution.

Depending on your use case, you may additionally need to set the proper launch
mode `Intent` flags in the `Intent` that launches the `FlutterActivity` to
achieve your expected back press behavior and task back stack. For example,
if `MainActivity.java` is the `FlutterActivity` that your launcher activity
launches:

```java
public final class LauncherActivity extends Activity {

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);

    Intent mainActivityIntent = new Intent(this, MainActivity.class);
    mainActivityIntent.putExtras(getIntent());

    // Add any additional launch mode Intent flags you need:
    mainActivityIntent.addFlags(...);

    startActivity(mainActivityIntent);
    finish();
  }

  ...
}
```

See [Tasks and the back stack][5] for more documentation about the different
launch modes and related `Intent` flags that Android provides.

## Contributing

If you would like to contribute to the plugin, check out our [contribution guide][3].

[1]: https://pub.dev/packages/quick_actions
[2]: https://flutter.dev/to/endorsed-federated-plugin
[3]: https://github.com/flutter/packages/blob/main/CONTRIBUTING.md
[4]: https://developer.android.com/reference/android/content/Intent?authuser=1#FLAG_ACTIVITY_SINGLE_TOP
[5]: https://developer.android.com/guide/components/activities/tasks-and-back-stack#TaskLaunchModes
[6]: https://github.com/flutter/flutter/issues/152883#issuecomment-2305906933
