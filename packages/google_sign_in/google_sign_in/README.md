[![pub package](https://img.shields.io/pub/v/google_sign_in.svg)](https://pub.dev/packages/google_sign_in)

A Flutter plugin for [Google Sign In](https://developers.google.com/identity/).

|             | Android | iOS   | macOS  | Web |
|-------------|---------|-------|--------|-----|
| **Support** | SDK 21+ | 12.0+ | 10.15+ | Any |

## Setup

### Import the package

To use this plugin, follow the
[plugin installation instructions](https://pub.dev/packages/google_sign_in/install),
then follow the platform integration steps below for all platforms you support.

### Platform integration

* **Android**: Please see [the `google_sign_in_android` README](https://pub.dev/packages/google_sign_in_android#integration).
* **iOS**: Please see [the `google_sign_in_ios` README](https://pub.dev/packages/google_sign_in_ios#ios-integration).
* **macOS**: Please see [the `google_sign_in_ios` README](https://pub.dev/packages/google_sign_in_ios#macos-integration) (which also supports macOS).
* **Web**: Please see [the `google_sign_in_web` README](https://pub.dev/packages/google_sign_in_web#integration).

## Usage

### Initialization and authentication

Initialize the `GoogleSignIn` instance, and (optionally) start the lightweight
authentication process:

<?code-excerpt "example/lib/main.dart (Setup)"?>
```dart
final GoogleSignIn signIn = GoogleSignIn.instance;
unawaited(
  signIn.initialize(clientId: clientId, serverClientId: serverClientId).then((
    _,
  ) {
    signIn.authenticationEvents
        .listen(_handleAuthenticationEvent)
        .onError(_handleAuthenticationError);

    /// This example always uses the stream-based approach to determining
    /// which UI state to show, rather than using the future returned here,
    /// if any, to conditionally skip directly to the signed-in state.
    signIn.attemptLightweightAuthentication();
  }),
);
```

If the user isn't signed in by the lightweight method, you can show UI to
start a sign-in flow. This uses `authenticate` on platforms that return true
for `supportsAuthenticate`, otherwise applications should fall back to a
platform-specific approach. For instance, user-initiated sign in on web must
use a button rendered by the sign in SDK, rather than application-provided
UI:

<?code-excerpt "example/lib/main.dart (ExplicitSignIn)"?>
```dart
if (GoogleSignIn.instance.supportsAuthenticate())
  ElevatedButton(
    onPressed: () async {
      try {
        await GoogleSignIn.instance.authenticate();
      } catch (e) {
        // ···
      }
    },
    child: const Text('SIGN IN'),
  )
else ...<Widget>[
  if (kIsWeb)
    web.renderButton()
  // ···
],
```

## Authorization

### Checking if scopes have been granted

If the user has previously authorized the scopes required by your application,
you can silently request an access token for those scopes:

<?code-excerpt "example/lib/main.dart (CheckAuthorization)" plaster="none"?>
```dart
const List<String> scopes = <String>[
  'https://www.googleapis.com/auth/contacts.readonly',
];
    final GoogleSignInAccount? user = // ...
    final GoogleSignInClientAuthorization? authorization = await user
        ?.authorizationClient
        .authorizationForScopes(scopes);
```

[Full list of available scopes](https://developers.google.com/identity/protocols/googlescopes).

### Requesting more scopes when needed

If an app determines that the user hasn't granted the scopes it requires, it
should initiate an Authorization request. On platforms where
`authorizationRequiresUserInteraction()` returns true,
this request **must be initiated from a user interaction** like a button press.

<?code-excerpt "example/lib/main.dart (RequestScopes)"?>
```dart
final GoogleSignInClientAuthorization authorization = await user
    .authorizationClient
    .authorizeScopes(scopes);
```

### Authorization expiration

In the web, **the `accessToken` is no longer refreshed**. It expires after 3600
seconds (one hour), so your app needs to be able to handle failed REST requests,
and update its UI to prompt the user for a new Authorization round.

This can be done by combining the error responses from your REST requests with
the authorization methods described above.

For more details, take a look at the
[`google_sign_in_web` package](https://pub.dev/packages/google_sign_in_web).

### Requesting a server auth code

If your application needs to access user data from a backend server, you can
request a server auth code to send to the server:

<?code-excerpt "example/lib/main.dart (RequestServerAuth)"?>
```dart
final GoogleSignInServerAuthorization? serverAuth = await user
    .authorizationClient
    .authorizeServer(scopes);
```

Server auth codes are not always available on all platforms. For instance, on
some platforms they may only be returned when a user initially signs in, and
not for subsequent authentications via the lightweight process. If you
need a server auth code you should request it as soon as possible after initial
sign-in, and manage server tokens for that user entirely on the server side
unless the signed in user changes.

On platforms where `authorizationRequiresUserInteraction()` returns true,
this request **must be initiated from a user interaction** like a button press.

## Example

The
[Google Sign-In example application](https://github.com/flutter/packages/blob/main/packages/google_sign_in/google_sign_in/example/lib/main.dart) demonstrates one approach to using this
package to sign a user in and authorize access to specific user data.

## Migration from pre-7.0 versions

If you used version 6.x or earlier of `google_sign_in`, see
[the migration guide](https://github.com/flutter/packages/blob/main/packages/google_sign_in/google_sign_in/MIGRATION.md)
for more information about the changes.
