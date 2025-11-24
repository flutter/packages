// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:objective_c/src/objective_c_bindings_generated.dart';
import 'package:path_provider_foundation/src/ffi_bindings.g.dart';
import 'package:path_provider_foundation/src/path_provider_foundation_real.dart';

// Most tests are in integration_test rather than here, because anything that
// needs to create Objective-C objects has to run in the real runtime.

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PathProviderFoundation', () {
    // These unit tests use the actual filesystem, since an injectable
    // filesystem would add a runtime dependency to the package, so everything
    // is contained to a temporary directory.
    late Directory testRoot;

    setUp(() async {
      testRoot = Directory.systemTemp.createTempSync();
    });

    tearDown(() {
      testRoot.deleteSync(recursive: true);
    });

    test('getExternalCachePaths throws', () async {
      final pathProvider = PathProviderFoundation(ffiLib: FakeFoundationFFI());
      expect(pathProvider.getExternalCachePaths(), throwsA(isUnsupportedError));
    });

    test('getExternalStoragePath throws', () async {
      final pathProvider = PathProviderFoundation(ffiLib: FakeFoundationFFI());
      expect(
        pathProvider.getExternalStoragePath(),
        throwsA(isUnsupportedError),
      );
    });

    test('getExternalStoragePaths throws', () async {
      final pathProvider = PathProviderFoundation(ffiLib: FakeFoundationFFI());
      expect(
        pathProvider.getExternalStoragePaths(),
        throwsA(isUnsupportedError),
      );
    });

    test('getContainerPath throws on macOS', () async {
      final pathProvider = PathProviderFoundation(
        platform: FakePlatformProvider(isMacOS: true),
        ffiLib: FakeFoundationFFI(),
      );
      expect(
        pathProvider.getContainerPath(appGroupIdentifier: 'group.example.test'),
        throwsA(isUnsupportedError),
      );
    });
  });
}

/// Fake implementation of PathProviderPlatformProvider.
class FakePlatformProvider implements PathProviderPlatformProvider {
  FakePlatformProvider({this.isIOS = false, this.isMacOS = false});
  @override
  bool isIOS;

  @override
  bool isMacOS;
}

class FakeFoundationFFI implements FoundationFFI {
  @override
  // ignore: non_constant_identifier_names
  NSArray NSSearchPathForDirectoriesInDomains(
    NSSearchPathDirectory directory,
    int domainMask,
    bool expandTilde,
  ) {
    throw UnimplementedError();
  }
}
