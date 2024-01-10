// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@TestOn('browser') // Uses package:web
library;

import 'dart:async';
import 'dart:js_interop';

import 'package:google_identity_services_web/loader.dart';
import 'package:google_identity_services_web/src/js_loader.dart';
import 'package:test/test.dart';
import 'package:web/web.dart' as web;

// NOTE: This file needs to be separated from the others because Content
// Security Policies can never be *relaxed* once set.
//
// In order to not introduce a dependency in the order of the tests, we split
// them in different files, depending on the strictness of their CSP:
//
// * js_loader_test.dart : default TT configuration (not enforced)
// * js_loader_tt_custom_test.dart : TT are customized, but allowed
// * js_loader_tt_forbidden_test.dart: TT are completely disallowed

void main() {
  group('loadWebSdk (no TrustedTypes)', () {
    final web.HTMLDivElement target =
        web.document.createElement('div') as web.HTMLDivElement;

    test('Injects script into desired target', () async {
      // This test doesn't simulate the callback that completes the future, and
      // the code being tested runs synchronously.
      unawaited(loadWebSdk(target: target));

      // Target now should have a child that is a script element
      final web.Node? injected = target.firstChild;
      expect(injected, isNotNull);
      expect(injected, isA<web.HTMLScriptElement>());

      final web.HTMLScriptElement script = injected! as web.HTMLScriptElement;
      expect(script.defer, isTrue);
      expect(script.async, isTrue);
      expect(script.src, 'https://accounts.google.com/gsi/client');
    });

    test('Completes when the script loads', () async {
      final Future<void> loadFuture = loadWebSdk(target: target);

      Future<void>.delayed(const Duration(milliseconds: 100), () {
        // Simulate the library calling `window.onGoogleLibraryLoad`.
        web.window.onGoogleLibraryLoad();
      });

      await expectLater(loadFuture, completes);
    });
  });
}

extension on web.Window {
  void onGoogleLibraryLoad() => _onGoogleLibraryLoad();
  @JS('onGoogleLibraryLoad')
  external JSFunction? _onGoogleLibraryLoad();
}
