# quick\_actions\_android

The Android implementation of [`quick_actions`][1].

## Usage

This package is [endorsed][2], which means you can simply use `quick_actions`
normally. This package will be automatically included in your app when you do,
so you do not need to add it to your `pubspec.yaml`.

However, if you `import` this package to use any of its APIs directly, you
should add it to your `pubspec.yaml` as usual.

## Usage with launcher activities

If you have an activity that launches the `FlutterActivity` (`MainActivity.java`/`MainActivity.kt` by default), like you may have in an add to app project or if you have other Android activities besides the main
`FlutterActivity` in your app, Then you might need to change your launch mode
configuration to have the back press behavior and back task stack that you expect.

For example, if you have two shortcuts to different layouts of your app, and
a launcher activity that launches the `FlutterActivity`,
if the launcher activity uses the `singleTop` launch mode (as the default `FlutterActivity`s `MainActivity.java`/`MainActivity.kt` do by default), then when the user launches your app from the first shortcut, leaves the app, then tries
to launch the app from the second shortcut, then the user will not see the layout that the second shortcut launches. To
fix that,set
the launch mode of your launcher activity to `singleInstance` in
`your_app/android/app/src/mainAndroidManifest.xml`:

```xml
<activity
        ...
        android:launchMode="singleInstance">
```

Depending on your use case, you may additionally/instead need to set the proper launch mode related `Intent` flags
in the `Intent` that launches the `FlutterActivity` to achieve your expected back press behavior and back task stack.
See [Tasks and the back stack][4] for more documentation about the different launch modes and related `Intent` flags
that Android provides.

## Contributing

If you would like to contribute to the plugin, check out our [contribution guide][3].

[1]: https://pub.dev/packages/quick_actions
[2]: https://flutter.dev/to/endorsed-federated-plugin
[3]: https://github.com/flutter/packages/blob/main/CONTRIBUTING.md
[4]: https://developer.android.com/guide/components/activities/tasks-and-back-stack#TaskLaunchModes
