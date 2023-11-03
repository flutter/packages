# google\_sign\_in\_ios

The iOS implementation of [`google_sign_in`][1].

## Usage

This package is [endorsed][2], which means you can simply use `google_sign_in`
normally. This package will be automatically included in your app when you do,
so you do not need to add it to your `pubspec.yaml`.

However, if you `import` this package to use any of its APIs directly, you
should add it to your `pubspec.yaml` as usual.

[1]: https://pub.dev/packages/google_sign_in
[2]: https://flutter.dev/docs/development/packages-and-plugins/developing-packages#endorsed-federated-plugin

### iOS integration

1. [Get an OAuth client ID](https://developers.google.com/identity/sign-in/ios/start-integrating#get_an_oauth_client_id).
2. Add your client ID into your app's `[my_project]/ios/Runner/Info.plist` file.
   ```xml
   <key>GIDClientID</key>
   <string>[YOUR IOS CLIENT ID]</string>
   ```
3. If you need to authenticate to a backend server you can add a
   `GIDServerClientID` key value pair in your `[my_project]/ios/Runner/Info.plist` file.
   ```xml
   <key>GIDServerClientID</key>
   <string>[YOUR SERVER CLIENT ID]</string>
   ```
4. Then add your reversed client ID in the `CFBundleURLTypes` attributes into the
   `[my_project]/ios/Runner/Info.plist` file.

   The reversed client ID is shown under "iOS URL scheme" when [selecting an existing iOS OAuth client in the Cloud console](https://console.cloud.google.com/apis/credentials?project=_).

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
			<string>[YOUR REVERSED CLIENT ID]</string>
		</array>
	</dict>
</array>
<!-- End of the Google Sign-in Section -->
```

As an alternative to editing the `Info.plist` in your Xcode project,
you can instead configure your app in Dart code. In this case, skip steps 2 to 3
 and pass `clientId` and `serverClientId` to the `GoogleSignIn` constructor:

```dart
GoogleSignIn _googleSignIn = GoogleSignIn(
  ...
  // The OAuth client id of your app. This is required.
  clientId: ...,
  // If you need to authenticate to a backend server, specify its OAuth client. This is optional.
  serverClientId: ...,
);
```

Note that step 4 is still required.
