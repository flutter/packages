<?code-excerpt path-base="./example/lib"?>
# quick_actions

This Flutter plugin allows you to manage and interact with the application's
home screen quick actions.

Quick actions refer to the [eponymous
concept](https://developer.apple.com/design/human-interface-guidelines/home-screen-quick-actions)
on iOS and to the [App
Shortcuts](https://developer.android.com/guide/topics/ui/shortcuts.html) APIs on
Android.

|             | Android   | iOS  |
|-------------|-----------|------|
| **Support** | SDK 16+\* | 9.0+ |

## Usage

Initialize the library early in your application's lifecycle by providing a
callback, which will then be called whenever the user launches the app via a
quick action.

<?code-excerpt "main.dart (Initialize)"?>
```dart
const QuickActions quickActions = QuickActions();
quickActions.initialize((String shortcutType) {
  if (shortcutType == 'ios_action') {
    debugPrint('You pressed ios action');
  } else if (shortcutType == 'android_action') {
    debugPrint('You pressed android action');
  }
  // ···
});
```

Finally, manage the app's quick actions, for instance:
<?code-excerpt "main.dart (SetShortcuts)"?>
```dart
quickActions.setShortcutItems(<ShortcutItem>[
  // ···
    const ShortcutItem(type: 'ios_action', localizedTitle: 'iOS Action', icon: 'AppIcon'),
  // ···
    const ShortcutItem(type: 'android_action', localizedTitle: 'Android Action', icon: 'ic_launcher')
]).then((void _) {
  // ···
});
```

Please note, that the `type` argument should be unique within your application
(among all the registered shortcut items). The optional `icon` should be the
name of the native resource (xcassets on iOS or drawable on Android) that the app will display for the
quick action.

### Android

\* The plugin will compile and run on SDK 16+, but will be a no-op below SDK 25
(Android 7.1).

If the drawables used as icons are not referenced other than in your Dart code,
you may need to
[explicitly mark them to be kept](https://developer.android.com/studio/build/shrink-code#keep-resources)
to ensure that they will be available for use in release builds.
