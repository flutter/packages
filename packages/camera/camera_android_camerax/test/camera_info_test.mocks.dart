// Mocks generated by Mockito 5.4.1 from annotations
// in camera_android_camerax/test/camera_info_test.dart.
// Do not manually edit this file.

// @dart=2.19

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i5;

import 'package:camera_android_camerax/src/camera_state.dart' as _i4;
import 'package:camera_android_camerax/src/live_data.dart' as _i3;
import 'package:camera_android_camerax/src/observer.dart' as _i6;
import 'package:camera_android_camerax/src/zoom_state.dart' as _i7;
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

/// A class which mocks [TestCameraInfoHostApi].
///
/// See the documentation for Mockito's code generation for more information.
class MockTestCameraInfoHostApi extends _i1.Mock
    implements _i2.TestCameraInfoHostApi {
  MockTestCameraInfoHostApi() {
    _i1.throwOnMissingStub(this);
  }

  @override
  int getSensorRotationDegrees(int? identifier) => (super.noSuchMethod(
        Invocation.method(
          #getSensorRotationDegrees,
          [identifier],
        ),
        returnValue: 0,
      ) as int);

  @override
  int getCameraState(int? identifier) => (super.noSuchMethod(
        Invocation.method(
          #getCameraState,
          [identifier],
        ),
        returnValue: 0,
      ) as int);

  @override
  int getExposureState(int? identifier) => (super.noSuchMethod(
        Invocation.method(
          #getExposureState,
          [identifier],
        ),
        returnValue: 0,
      ) as int);

  @override
  int getZoomState(int? identifier) => (super.noSuchMethod(
        Invocation.method(
          #getZoomState,
          [identifier],
        ),
        returnValue: 0,
      ) as int);
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

/// A class which mocks [LiveData].
///
/// See the documentation for Mockito's code generation for more information.
// ignore: must_be_immutable
class MockLiveCameraState extends _i1.Mock
    implements _i3.LiveData<_i4.CameraState> {
  MockLiveCameraState() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i5.Future<void> observe(_i6.Observer<_i4.CameraState>? observer) =>
      (super.noSuchMethod(
        Invocation.method(
          #observe,
          [observer],
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);

  @override
  _i5.Future<void> removeObservers() => (super.noSuchMethod(
        Invocation.method(
          #removeObservers,
          [],
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);
}

/// A class which mocks [LiveData].
///
/// See the documentation for Mockito's code generation for more information.
// ignore: must_be_immutable
class MockLiveZoomState extends _i1.Mock
    implements _i3.LiveData<_i7.ZoomState> {
  MockLiveZoomState() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i5.Future<void> observe(_i6.Observer<_i7.ZoomState>? observer) =>
      (super.noSuchMethod(
        Invocation.method(
          #observe,
          [observer],
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);

  @override
  _i5.Future<void> removeObservers() => (super.noSuchMethod(
        Invocation.method(
          #removeObservers,
          [],
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);
}
