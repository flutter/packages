// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// the following ignore is needed for downgraded analyzer (casts to JSObject).
// ignore_for_file: unnecessary_cast

import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:flutter_test/flutter_test.dart';
import 'package:google_identity_services_web/id.dart';
import 'package:google_identity_services_web/oauth2.dart';
import 'package:web/web.dart' as web;

/// Function that lets us expect that a JSObject has a [name] property that matches [matcher].
///
/// Use [createExpectConfigValue] to create one of this functions associated with
/// a specific [JSObject].
typedef ExpectConfigValueFn = void Function(String name, Object? matcher);

/// Creates a [ExpectConfigValueFn] for the `config` [JSObject].
ExpectConfigValueFn createExpectConfigValue(JSObject config) {
  return (String name, Object? matcher) {
    if (matcher is String) {
      matcher = matcher.toJS;
    } else if (matcher is bool) {
      matcher = matcher.toJS;
    } else if (matcher is List) {
      final List<Object?> old = matcher;
      matcher = isA<JSAny?>().having(
          (JSAny? p0) => (p0 as JSArray<JSAny>?)
              ?.toDart
              .map((JSAny? e) => e.dartify())
              .toList(),
          'Array with matching values',
          old);
    }
    expect(config[name], matcher, reason: name);
  };
}

/// A matcher that checks if: value typeof [thing] == true (in JS).
///
/// See: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/typeof
Matcher isAJs(String thing) => isA<JSAny?>()
    .having((JSAny? p0) => p0.typeofEquals(thing), 'typeof "$thing"', isTrue);

/// Installs mock-gis.js in the page.
/// Returns a future that completes when the 'load' event of the script fires.
Future<void> installGisMock() {
  final Completer<void> completer = Completer<void>();

  final web.HTMLScriptElement script =
      web.document.createElement('script') as web.HTMLScriptElement;
  script.src = 'mock-gis.js';
  script.type = 'module';
  script.addEventListener(
      'load',
      (JSAny? _) {
        completer.complete();
      }.toJS);

  web.document.head!.appendChild(script);
  return completer.future;
}

/// Fakes authorization with the given scopes.
Future<TokenResponse> fakeAuthZWithScopes(List<String> scopes) {
  final StreamController<TokenResponse> controller =
      StreamController<TokenResponse>();
  final TokenClient client = oauth2.initTokenClient(TokenClientConfig(
    client_id: 'for-tests',
    callback: controller.add,
    scope: scopes,
  ));
  setMockTokenResponse(client, 'some-non-null-auth-token-value');
  client.requestAccessToken();
  return controller.stream.first;
}

/// Allows calling a `setMockTokenResponse` method (added by mock-gis.js)
extension on TokenClient {
  external void setMockTokenResponse(JSString? token);
}

/// Sets a mock TokenResponse value in a [client].
void setMockTokenResponse(TokenClient client, [String? authToken]) {
  client.setMockTokenResponse(authToken?.toJS);
}

/// Allows calling a `setMockCredentialResponse` method (set by mock-gis.js)
extension on GoogleAccountsId {
  external void setMockCredentialResponse(
    JSString credential,
    JSString select_by, //ignore: non_constant_identifier_names
  );
}

/// Sets a mock credential response in `google.accounts.id`.
void setMockCredentialResponse([String value = 'default_value']) {
  _getGoogleAccountsId().setMockCredentialResponse(value.toJS, 'auto'.toJS);
}

GoogleAccountsId _getGoogleAccountsId() {
  return _getDeepProperty<GoogleAccountsId>(
      web.window as JSObject, 'google.accounts.id');
}

// Attempts to retrieve a deeply nested property from a jsObject (or die tryin')
T _getDeepProperty<T>(JSObject jsObject, String deepProperty) {
  final List<String> properties = deepProperty.split('.');
  return properties.fold<JSObject?>(
    jsObject,
    (JSObject? jsObj, String prop) => jsObj?[prop] as JSObject?,
  ) as T;
}
