// Mocks generated by Mockito 5.4.4 from annotations
// in camera_android_camerax/test/camera2_camera_info_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i7;

import 'package:camera_android_camerax/src/camera_info.dart' as _i6;
import 'package:camera_android_camerax/src/camera_state.dart' as _i8;
import 'package:camera_android_camerax/src/exposure_state.dart' as _i3;
import 'package:camera_android_camerax/src/live_data.dart' as _i2;
import 'package:camera_android_camerax/src/zoom_state.dart' as _i9;
import 'package:mockito/mockito.dart' as _i1;
import 'package:mockito/src/dummies.dart' as _i5;

import 'test_camerax_library.g.dart' as _i4;

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

class _FakeLiveData_0<T extends Object> extends _i1.SmartFake
    implements _i2.LiveData<T> {
  _FakeLiveData_0(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeExposureState_1 extends _i1.SmartFake implements _i3.ExposureState {
  _FakeExposureState_1(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

/// A class which mocks [TestCamera2CameraInfoHostApi].
///
/// See the documentation for Mockito's code generation for more information.
class MockTestCamera2CameraInfoHostApi extends _i1.Mock
    implements _i4.TestCamera2CameraInfoHostApi {
  MockTestCamera2CameraInfoHostApi() {
    _i1.throwOnMissingStub(this);
  }

  @override
  int createFrom(int? cameraInfoIdentifier) => (super.noSuchMethod(
        Invocation.method(
          #createFrom,
          [cameraInfoIdentifier],
        ),
        returnValue: 0,
      ) as int);

  @override
  int getSupportedHardwareLevel(int? identifier) => (super.noSuchMethod(
        Invocation.method(
          #getSupportedHardwareLevel,
          [identifier],
        ),
        returnValue: 0,
      ) as int);

  @override
  String getCameraId(int? identifier) => (super.noSuchMethod(
        Invocation.method(
          #getCameraId,
          [identifier],
        ),
        returnValue: _i5.dummyValue<String>(
          this,
          Invocation.method(
            #getCameraId,
            [identifier],
          ),
        ),
      ) as String);
}

/// A class which mocks [TestInstanceManagerHostApi].
///
/// See the documentation for Mockito's code generation for more information.
class MockTestInstanceManagerHostApi extends _i1.Mock
    implements _i4.TestInstanceManagerHostApi {
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

/// A class which mocks [CameraInfo].
///
/// See the documentation for Mockito's code generation for more information.
// ignore: must_be_immutable
class MockCameraInfo extends _i1.Mock implements _i6.CameraInfo {
  MockCameraInfo() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i7.Future<int> getSensorRotationDegrees() => (super.noSuchMethod(
        Invocation.method(
          #getSensorRotationDegrees,
          [],
        ),
        returnValue: _i7.Future<int>.value(0),
      ) as _i7.Future<int>);

  @override
  _i7.Future<_i2.LiveData<_i8.CameraState>> getCameraState() =>
      (super.noSuchMethod(
        Invocation.method(
          #getCameraState,
          [],
        ),
        returnValue: _i7.Future<_i2.LiveData<_i8.CameraState>>.value(
            _FakeLiveData_0<_i8.CameraState>(
          this,
          Invocation.method(
            #getCameraState,
            [],
          ),
        )),
      ) as _i7.Future<_i2.LiveData<_i8.CameraState>>);

  @override
  _i7.Future<_i3.ExposureState> getExposureState() => (super.noSuchMethod(
        Invocation.method(
          #getExposureState,
          [],
        ),
        returnValue: _i7.Future<_i3.ExposureState>.value(_FakeExposureState_1(
          this,
          Invocation.method(
            #getExposureState,
            [],
          ),
        )),
      ) as _i7.Future<_i3.ExposureState>);

  @override
  _i7.Future<_i2.LiveData<_i9.ZoomState>> getZoomState() => (super.noSuchMethod(
        Invocation.method(
          #getZoomState,
          [],
        ),
        returnValue: _i7.Future<_i2.LiveData<_i9.ZoomState>>.value(
            _FakeLiveData_0<_i9.ZoomState>(
          this,
          Invocation.method(
            #getZoomState,
            [],
          ),
        )),
      ) as _i7.Future<_i2.LiveData<_i9.ZoomState>>);
}
