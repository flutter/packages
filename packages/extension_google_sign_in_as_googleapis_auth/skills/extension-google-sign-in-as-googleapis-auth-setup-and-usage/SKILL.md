---
name: extension-google-sign-in-as-googleapis-auth-setup-and-usage
description: Use extension_google_sign_in_as_googleapis_auth to create authenticated googleapis_auth AuthClient instances directly from GoogleSignIn credentials for calling Google APIs.
---

# Setting Up and Using extension_google_sign_in_as_googleapis_auth

`extension_google_sign_in_as_googleapis_auth` is a bridge package between Flutter's [`google_sign_in`](https://pub.dev/packages/google_sign_in) plugin and Dart's [`googleapis`](https://pub.dev/packages/googleapis) / [`googleapis_auth`](https://pub.dev/packages/googleapis_auth) packages. It provides an extension method on `GoogleSignInClientAuthorization` to create an `AuthClient` that can be passed directly to any generated Google API client (such as `PeopleServiceApi`, `DriveApi`, `CalendarApi`, or `GmailApi`).

## 1. Installation

Add `extension_google_sign_in_as_googleapis_auth`, `google_sign_in`, `googleapis`, and `googleapis_auth` to your `pubspec.yaml`:

```yaml
dependencies:
  extension_google_sign_in_as_googleapis_auth: ^3.0.0
  google_sign_in: ^7.2.0
  googleapis: ^13.2.0
  googleapis_auth: ^1.6.0
```

## 2. Platform-Specific Configuration

Configure `google_sign_in` for your target platforms (Android, iOS, macOS, Web) with your OAuth 2.0 Client IDs. In the [Google Cloud Console](https://console.cloud.google.com/apis/library), ensure you enable the specific Google APIs your application calls (for example, the **Google People API** or **Google Drive API**).

## 3. Usage and API Examples

Import `package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart` to enable the `.authClient(scopes: ...)` extension method on `GoogleSignInClientAuthorization`.

### Authenticating and Calling a Google API (`PeopleServiceApi`)

```dart
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/people/v1.dart';
import 'package:googleapis_auth/googleapis_auth.dart' as auth show AuthClient;

const List<String> _scopes = <String>[
  PeopleServiceApi.contactsReadonlyScope,
];

Future<List<String>> fetchUserContacts(GoogleSignInAccount user) async {
  // 1. Obtain authorization for the required scopes from the signed-in user.
  GoogleSignInClientAuthorization? authorization =
      await user.authorizationClient.authorizationForScopes(_scopes);

  // If not already authorized, request interactive authorization.
  authorization ??= await user.authorizationClient.authorizeScopes(_scopes);

  // 2. Use the extension method to create an authenticated googleapis_auth AuthClient.
  final auth.AuthClient client = authorization.authClient(scopes: _scopes);

  // 3. Pass the AuthClient to any googleapis client class.
  final PeopleServiceApi peopleApi = PeopleServiceApi(client);

  final ListConnectionsResponse response =
      await peopleApi.people.connections.list(
    'people/me',
    personFields: 'names',
  );

  final List<String> contactNames = <String>[];
  final List<Person>? connections = response.connections;
  if (connections != null) {
    for (final Person person in connections) {
      final String? displayName = person.names?.firstOrNull?.displayName;
      if (displayName != null) {
        contactNames.add(displayName);
      }
    }
  }

  return contactNames;
}
```
