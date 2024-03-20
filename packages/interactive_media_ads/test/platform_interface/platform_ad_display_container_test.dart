// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interactive_media_ads/src/platform_interface/platform_interface.dart';
import 'package:mockito/annotations.dart';

import '../test_stubs.dart';

void main() {
  PlatformAdDisplayContainerCreationParams createEmptyParams() {
    return PlatformAdDisplayContainerCreationParams(
      onContainerAdded: (_) {},
    );
  }

  test('Cannot be implemented with `implements`', () {
    InteractiveMediaAdsPlatform.instance = TestInteractiveMediaAdsPlatform(
      onCreatePlatformAdDisplayContainer: (
        PlatformAdDisplayContainerCreationParams params,
      ) {
        return ImplementsPlatformAdDisplayContainer();
      },
    );

    expect(
      () => PlatformAdDisplayContainer(createEmptyParams()),
      throwsAssertionError,
    );
  });

  test('Can be extended', () {
    InteractiveMediaAdsPlatform.instance = TestInteractiveMediaAdsPlatform(
      onCreatePlatformAdDisplayContainer: (
        PlatformAdDisplayContainerCreationParams params,
      ) {
        return ExtendsPlatformAdDisplayContainer(createEmptyParams());
      },
    );

    expect(PlatformAdDisplayContainer(createEmptyParams()), isNotNull);
  });
}

class ImplementsPlatformAdDisplayContainer
    implements PlatformAdDisplayContainer {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class ExtendsPlatformAdDisplayContainer extends PlatformAdDisplayContainer {
  ExtendsPlatformAdDisplayContainer(super.params) : super.implementation();

  @override
  Widget build(BuildContext context) {
    throw UnimplementedError();
  }
}
