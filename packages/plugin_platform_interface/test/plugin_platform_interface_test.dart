// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Unreachable code is used in docregion.
// ignore_for_file: unreachable_from_main

import 'package:mockito/mockito.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:test/test.dart';

// #docregion Example
abstract class SamplePluginPlatform extends PlatformInterface {
  SamplePluginPlatform() : super(token: _token);

  static final Object _token = Object();

  // A plugin can have a default implementation, as shown here, or `instance`
  // can be nullable, and the default instance can be null.
  static SamplePluginPlatform _instance = SamplePluginDefault();

  static SamplePluginPlatform get instance => _instance;

  /// Platform-specific implementations should set this to their own
  /// platform-specific class that extends [SamplePluginPlatform] when they
  /// register themselves.
  static set instance(SamplePluginPlatform instance) {
    PlatformInterface.verify(instance, _token);
    _instance = instance;
  }

  // Methods for the plugin's platform interface would go here, often with
  // implementations that throw UnimplementedError.
}

class SamplePluginDefault extends SamplePluginPlatform {
  // A default real implementation of the platform interface would go here.
}
// #enddocregion Example

class ImplementsSamplePluginPlatform extends Mock
    implements SamplePluginPlatform {}

class ImplementsSamplePluginPlatformUsingNoSuchMethod
    implements SamplePluginPlatform {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// #docregion Mock
class SamplePluginPlatformMock extends Mock
    with MockPlatformInterfaceMixin
    implements SamplePluginPlatform {}
// #enddocregion Mock

class SamplePluginPlatformFake extends Fake
    with MockPlatformInterfaceMixin
    implements SamplePluginPlatform {}

class ExtendsSamplePluginPlatform extends SamplePluginPlatform {}

class ConstTokenPluginPlatform extends PlatformInterface {
  ConstTokenPluginPlatform() : super(token: _token);

  static const Object _token = Object(); // invalid

  // ignore: avoid_setters_without_getters
  static set instance(ConstTokenPluginPlatform instance) {
    PlatformInterface.verify(instance, _token);
  }
}

class ExtendsConstTokenPluginPlatform extends ConstTokenPluginPlatform {}

class VerifyTokenPluginPlatform extends PlatformInterface {
  VerifyTokenPluginPlatform() : super(token: _token);

  static final Object _token = Object();

  // ignore: avoid_setters_without_getters
  static set instance(VerifyTokenPluginPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    // A real implementation would set a static instance field here.
  }
}

class ImplementsVerifyTokenPluginPlatform extends Mock
    implements VerifyTokenPluginPlatform {}

class ImplementsVerifyTokenPluginPlatformUsingMockPlatformInterfaceMixin
    extends Mock
    with MockPlatformInterfaceMixin
    implements VerifyTokenPluginPlatform {}

class ExtendsVerifyTokenPluginPlatform extends VerifyTokenPluginPlatform {}

class ConstVerifyTokenPluginPlatform extends PlatformInterface {
  ConstVerifyTokenPluginPlatform() : super(token: _token);

  static const Object _token = Object(); // invalid

  // ignore: avoid_setters_without_getters
  static set instance(ConstVerifyTokenPluginPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
  }
}

class ImplementsConstVerifyTokenPluginPlatform extends PlatformInterface
    implements ConstVerifyTokenPluginPlatform {
  ImplementsConstVerifyTokenPluginPlatform() : super(token: const Object());
}

// Ensures that `PlatformInterface` has no instance methods. Adding an
// instance method is discouraged and may be a breaking change if it
// conflicts with instance methods in subclasses.
class StaticMethodsOnlyPlatformInterfaceTest implements PlatformInterface {}

class StaticMethodsOnlyMockPlatformInterfaceMixinTest
    implements MockPlatformInterfaceMixin {}

void main() {
  group('`verify`', () {
    test('prevents implementation with `implements`', () {
      expect(() {
        SamplePluginPlatform.instance = ImplementsSamplePluginPlatform();
      }, throwsA(isA<AssertionError>()));
    });

    test('prevents implmentation with `implements` and `noSuchMethod`', () {
      expect(() {
        SamplePluginPlatform.instance =
            ImplementsSamplePluginPlatformUsingNoSuchMethod();
      }, throwsA(isA<AssertionError>()));
    });

    test('allows mocking with `implements`', () {
      final SamplePluginPlatform mock = SamplePluginPlatformMock();
      SamplePluginPlatform.instance = mock;
    });

    test('allows faking with `implements`', () {
      final SamplePluginPlatform fake = SamplePluginPlatformFake();
      SamplePluginPlatform.instance = fake;
    });

    test('allows extending', () {
      SamplePluginPlatform.instance = ExtendsSamplePluginPlatform();
    });

    test('prevents `const Object()` token', () {
      expect(() {
        ConstTokenPluginPlatform.instance = ExtendsConstTokenPluginPlatform();
      }, throwsA(isA<AssertionError>()));
    });
  });

  // Tests of the earlier, to-be-deprecated `verifyToken` method
  group('`verifyToken`', () {
    test('prevents implementation with `implements`', () {
      expect(() {
        VerifyTokenPluginPlatform.instance =
            ImplementsVerifyTokenPluginPlatform();
      }, throwsA(isA<AssertionError>()));
    });

    test('allows mocking with `implements`', () {
      final VerifyTokenPluginPlatform mock =
          ImplementsVerifyTokenPluginPlatformUsingMockPlatformInterfaceMixin();
      VerifyTokenPluginPlatform.instance = mock;
    });

    test('allows extending', () {
      VerifyTokenPluginPlatform.instance = ExtendsVerifyTokenPluginPlatform();
    });

    test('does not prevent `const Object()` token', () {
      ConstVerifyTokenPluginPlatform.instance =
          ImplementsConstVerifyTokenPluginPlatform();
    });
  });
}
