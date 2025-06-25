# google\_sign\_in\_web

The web implementation of [google_sign_in](https://pub.dev/packages/google_sign_in)

## Usage

This package is [endorsed](https://flutter.dev/to/endorsed-federated-plugin),
which means you can simply use `google_sign_in`
normally. This package will be automatically included in your app when you do,
so you do not need to add it to your `pubspec.yaml`.

However, if you `import` this package to use any of its APIs directly, you
should add it to your `pubspec.yaml` as usual.

For example, you need to import this package directly if you plan to use the
web-only `Widget renderButton()` method.

## Integration

First, go through the instructions [here](https://developers.google.com/identity/gsi/web/guides/get-google-api-clientid) to create your Google Sign-In OAuth client ID.

On your `web/index.html` file, add the following `meta` tag, somewhere in the
`head` of the document:

```html
<meta name="google-signin-client_id" content="YOUR_GOOGLE_SIGN_IN_OAUTH_CLIENT_ID.apps.googleusercontent.com">
```

For this client to work correctly, the last step is to configure the **Authorized JavaScript origins**, which _identify the domains from which your application can send API requests._ When in local development, this is normally `localhost` and some port.

You can do this by:

1. Going to the [Credentials page](https://console.developers.google.com/apis/credentials).
2. Clicking "Edit" in the OAuth 2.0 Web application client that you created above.
3. Adding the URIs you want to the **Authorized JavaScript origins**.

For local development, you must add two `localhost` entries:

* `http://localhost` and
* `http://localhost:7357` (or any port that is free in your machine)

### Starting flutter in http://localhost:7357

Normally `flutter run` starts in a random port. In the case where you need to deal with authentication like the above, that's not the most appropriate behavior.

You can tell `flutter run` to listen for requests in a specific host and port with the following:

```sh
flutter run -d chrome --web-hostname localhost --web-port 7357
```

## Authentication

This implementation returns false for `supportsAuthentication`, and will throw
if `authenticate` is called. This is because the
[Google Identity Services (GIS) SDK](https://developers.google.com/identity/gsi/web/guides/overview)
only allows signing in using UI provided by the SDK.

On the web, instead of providing custom UI that calls `authenticate`, you should
display the Widget returned by `renderButton` (from `web_only.dart`), and listen
to `authenticationEvents` to know when the user has signed in.

The GIS SDK does not renew authentication sessions. Once the token expires
(after 3600 seconds), if you need to use the `idToken` again you must trigger
a new authentication flow. In most cases, you should use the `idToken`
immediately after authentication, and track sign-in state at the application
level, or via a separate server backend.

### Migration from versions before 0.12

See [Migrating from Google Sign-In](https://developers.google.com/identity/gsi/web/guides/migration)
for information about the differences between authentication in the GIS SDK and
the SDK used in older versions of this plugin.

Since the GIS SDK does _not_ manage user sessions anymore, apps that relied on
this feature might break. If long-lived sessions are required, consider using
some user authentication system that supports Google Sign In as a federated
Authentication provider, like
[Firebase Auth](https://firebase.google.com/docs/auth/flutter/federated-auth#google).

## Authorization

The GIS SDK does not renew authorization sessions. Once the token expires
(after 3600 seconds), API requests will begin to fail, and you must re-request
user authorization. For example:

* `401`: Missing or invalid access token.
* `403`: Expired access token.

See the "Integration considerations > [UX separation for authentication and authorization](https://developers.google.com/identity/gsi/web/guides/integrate#ux_separation_for_authentication_and_authorization)
guide" in the official GIS SDK documentation for more information about this.

### Migration from versions before 0.12

See [Migrate to Google Identity Services](https://developers.google.com/identity/oauth2/web/guides/migration-to-gis)
for information about the differences between authentication in the GIS SDK and
the SDK used in older versions of this plugin.
