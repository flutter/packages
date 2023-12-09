// Mocks generated by Mockito 5.4.1 from annotations
// in camera_android_camerax/test/camera_control_test.dart.
// Do not manually edit this file.

// @dart=2.19

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i3;

import 'package:mockito/mockito.dart' as _i1;

import 'test_camerax_library.g.dart' as _i2;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

/// A class which mocks [TestCameraControlHostApi].
///
/// See the documentation for Mockito's code generation for more information.
class MockTestCameraControlHostApi extends _i1.Mock
    implements _i2.TestCameraControlHostApi {
  MockTestCameraControlHostApi() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i3.Future<void> enableTorch(
    int? identifier,
    bool? torch,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #enableTorch,
          [
            identifier,
            torch,
          ],
        ),
        returnValue: _i3.Future<void>.value(),
        returnValueForMissingStub: _i3.Future<void>.value(),
      ) as _i3.Future<void>);

  @override
  _i3.Future<void> setZoomRatio(
    int? identifier,
    double? ratio,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #setZoomRatio,
          [
            identifier,
            ratio,
          ],
        ),
        returnValue: _i3.Future<void>.value(),
        returnValueForMissingStub: _i3.Future<void>.value(),
      ) as _i3.Future<void>);
}

/// A class which mocks [TestInstanceManagerHostApi].
///
/// See the documentation for Mockito's code generation for more information.
class MockTestInstanceManagerHostApi extends _i1.Mock
    implements _i2.TestInstanceManagerHostApi {
  MockTestInstanceManagerHostApi() {
    _i1.throwOnMissingStub(this);
  }

  @override
  void clear() => super.noSuchMethod(
        Invocation.method(
          #clear,
          [],
        ),
        returnValueForMissingStub: null,
      );
}
