# quick\_actions\_android

The Android implementation of [`quick_actions`][1].

## Usage

This package is [endorsed][2], which means you can simply use `quick_actions`
normally. This package will be automatically included in your app when you do,
so you do not need to add it to your `pubspec.yaml`.

However, if you `import` this package to use any of its APIs directly, you
should add it to your `pubspec.yaml` as usual.

## Usage with launcher activities

If your app implements an activity that launches the main `FlutterActivity`
(`MainActivity.java`/`MainActivity.kt` by default), then you may need to change
the launch mode of your launcher activity and/or modify the `Intent` flags used
to launch the main `FlutterActivity` in order to achieve the desired back press
behavior and task management.

If your launcher activity only launches the main `FlutterActivity` without any
additional relevant logic (like the code sample provided in the description of
https://github.com/flutter/flutter/issues/152883), to have your app maintain the
same behavior of `quick_actions_android` with/without a launcher activity, set
the launch mode of your launcher activity to `singleInstance` in
`your_app/android/app/src/mainAndroidManifest.xml`:

```xml
<activity
        ...
        android:launchMode="singleInstance">
```

See the [Tasks and the back stack][4] Android documentation for more information
on the different launch modes and `Intent` flags you may need.

## Contributing

If you would like to contribute to the plugin, check out our [contribution guide][3].

[1]: https://pub.dev/packages/quick_actions
[2]: https://flutter.dev/to/endorsed-federated-plugin
[3]: https://github.com/flutter/packages/blob/main/CONTRIBUTING.md
[4]: https://developer.android.com/guide/components/activities/tasks-and-back-stack#TaskLaunchModes
