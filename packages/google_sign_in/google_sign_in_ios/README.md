# google\_sign\_in\_ios

The iOS and macOS implementation of [`google_sign_in`][1].

## Usage

This package is [endorsed][2], which means you can simply use `google_sign_in`
normally. This package will be automatically included in your app when you do,
so you do not need to add it to your `pubspec.yaml`.

However, if you `import` this package to use any of its APIs directly, you
should add it to your `pubspec.yaml` as usual.

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
you can instead configure your app in Dart code. In this case, skip steps 4 and
5 and pass `clientId` and `serverClientId` to the `GoogleSignIn` initialization:

<?code-excerpt "example/integration_test/google_sign_in_test.dart (IDsInCode)"?>
```dart
final GoogleSignInPlatform signIn = GoogleSignInPlatform.instance;
await signIn.init(
  const InitParameters(
    // The OAuth client ID of your app. This is required.
    clientId: 'Your Client ID',
    // If you need to authenticate to a backend server, specify the server's
    // OAuth client ID. This is optional.
    serverClientId: 'Your Server ID',
  ),
);
```

Note that step 6 is still required.

#### App Store requirements

Apple's App Review Guidelines impose
[extra login option requirements](https://developer.apple.com/app-store/review/guidelines/#login-services)
on apps that include Google Sign-In. Other packages, such as the Flutter Favorite
[`sign_in_with_apple`](https://pub.dev/packages/sign_in_with_apple), may
be useful in satisfying the review requirements.

### macOS integration

Follow the steps above for iOS integration, but using the `Info.plist` in the
`macos` directory.

In addition, the GoogleSignIn SDK requires keychain sharing to be enabled, by
[adding the following entitlements](https://flutter.dev/to/macos-entitlements):

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
