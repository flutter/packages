# google\_sign\_in\_ios

The iOS and macOS implementation of [`google_sign_in`][1].

## Usage

This package is [endorsed][2], which means you can simply use `google_sign_in`
normally. This package will be automatically included in your app when you do,
so you do not need to add it to your `pubspec.yaml`.

However, if you `import` this package to use any of its APIs directly, you
should add it to your `pubspec.yaml` as usual.

### macOS setup

The GoogleSignIn SDK requires keychain sharing to be enabled, by [adding the
following entitlements](https://flutter.dev/to/macos-entitlements):

```xml
    <key>keychain-access-groups</key>
    <array>
        <string>$(AppIdentifierPrefix)com.google.GIDSignIn</string>
    </array>
```

Without this step, the plugin will throw a `keychain error` `PlatformException`
when trying to sign in.

[1]: https://pub.dev/packages/google_sign_in
[2]: https://flutter.dev/to/endorsed-federated-plugin

### iOS integration

1. [Create a Firebase project](https://firebase.google.com/docs/ios/setup#create-firebase-project)
    and [register your application](https://firebase.google.com/docs/ios/setup#register-app).
2. [Enable Google Sign-In for your Firebase project](https://firebase.google.com/docs/auth/ios/google-signin#enable_google_sign-in_for_your_firebase_project).
3. Make sure to download a new copy of your project's
   `GoogleService-Info.plist` from step 2. Do not put this file in your project.
4. Add the client ID from the `GoogleService-Info.plist` into your app's
    `[my_project]/ios/Runner/Info.plist` file.
   ```xml
   <key>GIDClientID</key>
   <!-- TODO Replace this value: -->
   <!-- Copied from GoogleService-Info.plist key CLIENT_ID -->
   <string>[YOUR IOS CLIENT ID]</string>
   ```
5. If you need to authenticate to a backend server you can add a
   `GIDServerClientID` key value pair in your `[my_project]/ios/Runner/Info.plist` file.
   ```xml
   <key>GIDServerClientID</key>
   <string>[YOUR SERVER CLIENT ID]</string>
   ```
6. Then add the `CFBundleURLTypes` attributes below into the
   `[my_project]/ios/Runner/Info.plist` file.

```xml
<!-- Put me in the [my_project]/ios/Runner/Info.plist file -->
<!-- Google Sign-in Section -->
<key>CFBundleURLTypes</key>
<array>
	<dict>
		<key>CFBundleTypeRole</key>
		<string>Editor</string>
		<key>CFBundleURLSchemes</key>
		<array>
			<!-- TODO Replace this value: -->
			<!-- Copied from GoogleService-Info.plist key REVERSED_CLIENT_ID -->
			<string>com.googleusercontent.apps.861823949799-vc35cprkp249096uujjn0vvnmcvjppkn</string>
		</array>
	</dict>
</array>
<!-- End of the Google Sign-in Section -->
```

As an alternative to editing the `Info.plist` in your Xcode project,
you can instead configure your app in Dart code. In this case, skip steps 4 to 5
 and pass `clientId` and `serverClientId` to the `GoogleSignIn` constructor:

<?code-excerpt "../google_sign_in/test/google_sign_in_test.dart (GoogleSignIn)"?>
```dart
final GoogleSignIn googleSignIn = GoogleSignIn(
  // The OAuth client id of your app. This is required.
  clientId: 'Your Client ID',
  // If you need to authenticate to a backend server, specify its OAuth client. This is optional.
  serverClientId: 'Your Server ID',
);
```

Note that step 6 is still required.
