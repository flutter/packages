// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_test_plugin_code/src/generated/proxy_api_tests.gen.dart';

void main() {
  test('can override ProxyApi constructors', () {
    pigeon_resetAllOverrides();

    final ProxyApiSuperClass instance = ProxyApiSuperClass.pigeon_detached();
    PigeonProxyApiSuperClassOverrides.new_ = () => instance;

    expect(ProxyApiSuperClass(), instance);
  });

  test('can override ProxyApi static fields', () {
    pigeon_resetAllOverrides();

    final ProxyApiSuperClass instance = ProxyApiSuperClass.pigeon_detached();
    PigeonProxyApiTestClassOverrides.staticAttachedField = instance;

    expect(ProxyApiTestClass.staticAttachedField, instance);
  });

  test('can override ProxyApi static methods', () async {
    pigeon_resetAllOverrides();

    PigeonProxyApiTestClassOverrides.echoStaticString = (String value) async {
      return value;
    };

    const String value = 'testString';
    expect(await ProxyApiTestClass.echoStaticString(value), value);
  });

  test('pigeon_resetAllOverrides set all constructor overrides to null', () {
    PigeonProxyApiSuperClassOverrides.new_ =
        () => ProxyApiSuperClass.pigeon_detached();

    pigeon_resetAllOverrides();
    expect(PigeonProxyApiSuperClassOverrides.new_, isNull);
  });

  test('pigeon_resetAllOverrides sets attached field overrides to null', () {
    PigeonProxyApiTestClassOverrides.staticAttachedField =
        ProxyApiSuperClass.pigeon_detached();

    pigeon_resetAllOverrides();
    expect(PigeonProxyApiTestClassOverrides.staticAttachedField, isNull);
  });

  test('pigeon_resetAllOverrides sets static method overrides to null', () {
    PigeonProxyApiTestClassOverrides.echoStaticString = (String value) async {
      return value;
    };

    pigeon_resetAllOverrides();
    expect(PigeonProxyApiTestClassOverrides.echoStaticString, isNull);
  });
}
