// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_test_plugin_code/src/generated/native_interop_tests.gen.dart';

class _FakeReservedNamesFlutterApi extends NativeInteropReservedNamesFlutterApi {
  @override
  String getReference() => 'ref';

  @override
  String implementIn(String value) => value;

  @override
  bool isNull() => false;

  @override
  String release(String value) => value;

  @override
  String type() => 'type';
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('native_interop_tests.gen.dart can be imported and used on all platforms including Web', () {
    final instance = NativeInteropUnusedClass();
    final Object encoded = instance.encode();
    expect(NativeInteropUnusedClass.decode(encoded), equals(instance));
    expect(NativeInteropAnEnum.values, isNotEmpty);

    NativeInteropReservedNamesFlutterApi.setUp(null);

    if (kIsWeb) {
      // On Web, setUp registers binary messenger handlers without invoking native registrars.
      NativeInteropReservedNamesFlutterApi.setUp(_FakeReservedNamesFlutterApi());
      NativeInteropReservedNamesFlutterApi.setUp(null);

      expect(
        () => NativeInteropReservedNamesHostApi.createWithNativeInteropApi(),
        throwsUnsupportedError,
      );
      expect(
        () => NativeInteropReservedNamesHostApiForNativeInterop.getInstance(),
        throwsUnsupportedError,
      );
      expect(
        () => NativeInteropReservedNamesFlutterApi.implement(_FakeReservedNamesFlutterApi()),
        throwsUnsupportedError,
      );
    }
  });
}
