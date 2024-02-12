// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interactive_media_ads/src/platform_interface/platform_interface.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'platform_ad_display_container_test.mocks.dart';

@GenerateMocks(<Type>[
  InteractiveMediaAdsPlatform,
  PlatformAdDisplayContainer,
])
void main() {
  setUp(() {
    InteractiveMediaAdsPlatform.instance =
        MockInteractiveMediaAdsPlatformWithMixin();
  });

  PlatformAdDisplayContainerCreationParams createEmptyParams() {
    return PlatformAdDisplayContainerCreationParams(
      onContainerAdded: (_) {},
    );
  }

  test('Cannot be implemented with `implements`', () {
    when((InteractiveMediaAdsPlatform.instance!
                as MockInteractiveMediaAdsPlatform)
            .createPlatformAdDisplayContainer(any))
        .thenReturn(ImplementsPlatformAdDisplayContainer());

    expect(
      () => PlatformAdDisplayContainer(createEmptyParams()),
      throwsAssertionError,
    );
  });

  test('Can be extended', () {
    when((InteractiveMediaAdsPlatform.instance!
                as MockInteractiveMediaAdsPlatform)
            .createPlatformAdDisplayContainer(any))
        .thenReturn(ExtendsPlatformAdDisplayContainer(createEmptyParams()));

    expect(PlatformAdDisplayContainer(createEmptyParams()), isNotNull);
  });
}

class MockInteractiveMediaAdsPlatformWithMixin
    extends MockInteractiveMediaAdsPlatform with MockPlatformInterfaceMixin {}

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
