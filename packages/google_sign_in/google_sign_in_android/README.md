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

* If you are use the `google-services.json` file and Gradle-based registration
  system, no identifiers need to be provided in Dart when initializing the
  `GoogleSignIn` instance when running on Android.
* If you are not using `google-services.json`, you need to pass the client
  ID of the *web* application you registered as the `serverClientId` when
  initializing the `GoogleSignIn` instance.

If you encounter `APIException` errors, double-check that you have followed all
of the registration steps in the instructions above.

You will also need to enable any OAuth APIs that you want, using the
[Google Cloud Platform API manager](https://console.developers.google.com/). For
example, if you want to mimic the behavior of the Google Sign-In example app,
you'll need to enable the
[Google People API](https://developers.google.com/people/).
