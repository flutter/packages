// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_test_plugin_code/src/generated/proxy_api_tests.gen.dart';

void main() {
  test('can override ProxyApi constructors', () {
    PigeonOverrides.pigeon_reset();

    final ProxyApiSuperClass instance = ProxyApiSuperClass.pigeon_detached();
    PigeonOverrides.proxyApiSuperClass_new = () => instance;

    expect(ProxyApiSuperClass(), instance);
  });

  test('can override ProxyApi static attached fields', () {
    PigeonOverrides.pigeon_reset();

    final ProxyApiSuperClass instance = ProxyApiSuperClass.pigeon_detached();
    PigeonOverrides.proxyApiTestClass_staticAttachedField = instance;

    expect(ProxyApiTestClass.staticAttachedField, instance);
  });

  test('can override ProxyApi static methods', () async {
    PigeonOverrides.pigeon_reset();

    PigeonOverrides.proxyApiTestClass_echoStaticString = (String value) async {
      return value;
    };

    const String value = 'testString';
    expect(await ProxyApiTestClass.echoStaticString(value), value);
  });

  test('pigeon_reset sets constructor overrides to null', () {
    PigeonOverrides.proxyApiSuperClass_new =
        () => ProxyApiSuperClass.pigeon_detached();

    PigeonOverrides.pigeon_reset();
    expect(PigeonOverrides.proxyApiSuperClass_new, isNull);
  });

  test('pigeon_reset sets attached field overrides to null', () {
    PigeonOverrides.proxyApiTestClass_staticAttachedField =
        ProxyApiSuperClass.pigeon_detached();

    PigeonOverrides.pigeon_reset();
    expect(PigeonOverrides.proxyApiTestClass_staticAttachedField, isNull);
  });

  test('pigeon_reset sets static method overrides to null', () {
    PigeonOverrides.proxyApiTestClass_echoStaticString = (String value) async {
      return value;
    };

    PigeonOverrides.pigeon_reset();
    expect(PigeonOverrides.proxyApiTestClass_echoStaticString, isNull);
  });
}
