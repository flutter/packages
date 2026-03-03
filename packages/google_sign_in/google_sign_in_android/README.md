# google\_sign\_in\_android

The Android implementation of [`google_sign_in`][1].

## Usage

This package is [endorsed][2], which means you can simply use `google_sign_in`
normally. This package will be automatically included in your app when you do,
so you do not need to add it to your `pubspec.yaml`.

However, if you `import` this package to use any of its APIs directly, you
should add it to your `pubspec.yaml` as usual.

[1]: https://pub.dev/packages/google_sign_in
[2]: https://flutter.dev/to/endorsed-federated-plugin

## Integration

To use Google Sign-In, you'll need to register your application, either
[using Firebase](https://firebase.google.com/docs/android/setup), or
[directly with Google Cloud Platform](https://developer.android.com/identity/sign-in/credential-manager-siwg#set-google).

* If you are using the `google-services.json` file and Gradle-based registration
  system, no identifiers need to be provided in Dart when initializing the
  `GoogleSignIn` instance when running on Android, as long as your
  `google-services.json` contains a web OAuth client entry.
* If you are not using `google-services.json`, you need to pass the client
  ID of the *web* application you registered as the `serverClientId` when
  initializing the `GoogleSignIn` instance.

You will also need to enable any OAuth APIs that you want, using the
[Google Cloud Platform API manager](https://console.developers.google.com/). For
example, if you want to mimic the behavior of the Google Sign-In example app,
you'll need to enable the
[Google People API](https://developers.google.com/people/).

### Troubleshooting

If you encounter persistent errors, check that you have followed all of the
registration steps in the instructions above. Common signs of configuration
errors include:
* `GoogleSignInException`s with a code of
  `GoogleSignInExceptionCode.clientConfigurationError`.
* Unexpected `GoogleSignInException`s with a code of
  `GoogleSignInExceptionCode.canceled` after selecting an account during the
  authentication process.
  * Some configuration errors will cause the underlying
    Android `CredentialManager` SDK to return a "canceled" error in this flow,
    and unfortunately the `google_sign_in` plugin has no way to distinguish this
    case from the user canceling sign-in, so cannot return a more accurate error
    message.
* Sign-in working in one build configuration but not another.

Common sources of configuration errors include:
* Missing or incorrect signing SHA for one or more build configurations.
* Incorrect Android package name on the server side.
* Missing or incorrect `serverClientId`.

If you are using `google-services.json` and receive a "serverClientId must be
provided on Android" error message, check that:
  * Your `google-services.json` contains a web OAuth client, which should be an
    `oauth_client` entry with `client_type: 3`. This should have been created
    automatically when enabling Google Sign In using the Firebase console, but
    if not (or if it was later removed), add a web app to the project and then
    re-download `google-services.json`.
  * You correctly followed all of the Gradle configuration steps in the Firebase
    integration documentation.
