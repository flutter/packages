// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@TestOn('browser') // Uses package:web
library;

import 'package:google_identity_services_web/loader.dart';
import 'package:test/test.dart';
import 'package:web/web.dart' as web;

import 'tools.dart';

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
  group('loadWebSdk (TrustedTypes forbidden)', () {
    final web.HTMLDivElement target =
        web.document.createElement('div') as web.HTMLDivElement;
    injectMetaTag(<String, String>{
      'http-equiv': 'Content-Security-Policy',
      'content': "trusted-types 'none';",
    });

    test('Fail with TrustedTypesException', () {
      expect(() {
        loadWebSdk(target: target);
      }, throwsA(isA<TrustedTypesException>()));
    });
  });
}
