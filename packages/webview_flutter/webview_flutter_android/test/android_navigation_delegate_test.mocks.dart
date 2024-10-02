// Mocks generated by Mockito 5.4.4 from annotations
// in webview_flutter_android/test/android_navigation_delegate_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i3;

import 'package:mockito/mockito.dart' as _i1;
import 'package:webview_flutter_android/src/android_webkit.g.dart' as _i2;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: deprecated_member_use
// ignore_for_file: deprecated_member_use_from_same_package
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

class _FakePigeonInstanceManager_0 extends _i1.SmartFake
    implements _i2.PigeonInstanceManager {
  _FakePigeonInstanceManager_0(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeHttpAuthHandler_1 extends _i1.SmartFake
    implements _i2.HttpAuthHandler {
  _FakeHttpAuthHandler_1(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

/// A class which mocks [HttpAuthHandler].
///
/// See the documentation for Mockito's code generation for more information.
class MockHttpAuthHandler extends _i1.Mock implements _i2.HttpAuthHandler {
  MockHttpAuthHandler() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i2.PigeonInstanceManager get pigeon_instanceManager => (super.noSuchMethod(
        Invocation.getter(#pigeon_instanceManager),
        returnValue: _FakePigeonInstanceManager_0(
          this,
          Invocation.getter(#pigeon_instanceManager),
        ),
      ) as _i2.PigeonInstanceManager);

  @override
  _i3.Future<bool> useHttpAuthUsernamePassword() => (super.noSuchMethod(
        Invocation.method(
          #useHttpAuthUsernamePassword,
          [],
        ),
        returnValue: _i3.Future<bool>.value(false),
      ) as _i3.Future<bool>);

  @override
  _i3.Future<void> cancel() => (super.noSuchMethod(
        Invocation.method(
          #cancel,
          [],
        ),
        returnValue: _i3.Future<void>.value(),
        returnValueForMissingStub: _i3.Future<void>.value(),
      ) as _i3.Future<void>);

  @override
  _i3.Future<void> proceed(
    String? username,
    String? password,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #proceed,
          [
            username,
            password,
          ],
        ),
        returnValue: _i3.Future<void>.value(),
        returnValueForMissingStub: _i3.Future<void>.value(),
      ) as _i3.Future<void>);

  @override
  _i2.HttpAuthHandler pigeon_copy() => (super.noSuchMethod(
        Invocation.method(
          #pigeon_copy,
          [],
        ),
        returnValue: _FakeHttpAuthHandler_1(
          this,
          Invocation.method(
            #pigeon_copy,
            [],
          ),
        ),
      ) as _i2.HttpAuthHandler);
}
