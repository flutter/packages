// Mocks generated by Mockito 5.4.0 from annotations
// in camera_android_camerax/test/android_camera_camerax_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i9;

import 'package:camera_android_camerax/src/camera.dart' as _i5;
import 'package:camera_android_camerax/src/camera_info.dart' as _i2;
import 'package:camera_android_camerax/src/camera_selector.dart' as _i10;
import 'package:camera_android_camerax/src/camerax_library.g.dart' as _i4;
import 'package:camera_android_camerax/src/image_capture.dart' as _i11;
import 'package:camera_android_camerax/src/live_camera_state.dart' as _i3;
import 'package:camera_android_camerax/src/preview.dart' as _i12;
import 'package:camera_android_camerax/src/process_camera_provider.dart'
    as _i13;
import 'package:camera_android_camerax/src/use_case.dart' as _i14;
import 'package:flutter/foundation.dart' as _i8;
import 'package:flutter/services.dart' as _i7;
import 'package:flutter/widgets.dart' as _i6;
import 'package:mockito/mockito.dart' as _i1;

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

class _FakeCameraInfo_0 extends _i1.SmartFake implements _i2.CameraInfo {
  _FakeCameraInfo_0(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeLiveCameraState_1 extends _i1.SmartFake
    implements _i3.LiveCameraState {
  _FakeLiveCameraState_1(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeResolutionInfo_2 extends _i1.SmartFake
    implements _i4.ResolutionInfo {
  _FakeResolutionInfo_2(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeCamera_3 extends _i1.SmartFake implements _i5.Camera {
  _FakeCamera_3(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeWidget_4 extends _i1.SmartFake implements _i6.Widget {
  _FakeWidget_4(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );

  @override
  String toString({_i7.DiagnosticLevel? minLevel = _i7.DiagnosticLevel.info}) =>
      super.toString();
}

class _FakeInheritedWidget_5 extends _i1.SmartFake
    implements _i6.InheritedWidget {
  _FakeInheritedWidget_5(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );

  @override
  String toString({_i7.DiagnosticLevel? minLevel = _i7.DiagnosticLevel.info}) =>
      super.toString();
}

class _FakeDiagnosticsNode_6 extends _i1.SmartFake
    implements _i8.DiagnosticsNode {
  _FakeDiagnosticsNode_6(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );

  @override
  String toString({
    _i8.TextTreeConfiguration? parentConfiguration,
    _i7.DiagnosticLevel? minLevel = _i7.DiagnosticLevel.info,
  }) =>
      super.toString();
}

/// A class which mocks [Camera].
///
/// See the documentation for Mockito's code generation for more information.
class MockCamera extends _i1.Mock implements _i5.Camera {
  @override
  _i9.Future<_i2.CameraInfo> getCameraInfo() => (super.noSuchMethod(
        Invocation.method(
          #getCameraInfo,
          [],
        ),
        returnValue: _i9.Future<_i2.CameraInfo>.value(_FakeCameraInfo_0(
          this,
          Invocation.method(
            #getCameraInfo,
            [],
          ),
        )),
        returnValueForMissingStub:
            _i9.Future<_i2.CameraInfo>.value(_FakeCameraInfo_0(
          this,
          Invocation.method(
            #getCameraInfo,
            [],
          ),
        )),
      ) as _i9.Future<_i2.CameraInfo>);
}

/// A class which mocks [CameraInfo].
///
/// See the documentation for Mockito's code generation for more information.
class MockCameraInfo extends _i1.Mock implements _i2.CameraInfo {
  @override
  _i9.Future<int> getSensorRotationDegrees() => (super.noSuchMethod(
        Invocation.method(
          #getSensorRotationDegrees,
          [],
        ),
        returnValue: _i9.Future<int>.value(0),
        returnValueForMissingStub: _i9.Future<int>.value(0),
      ) as _i9.Future<int>);
  @override
  _i9.Future<_i3.LiveCameraState> getLiveCameraState() => (super.noSuchMethod(
        Invocation.method(
          #getLiveCameraState,
          [],
        ),
        returnValue:
            _i9.Future<_i3.LiveCameraState>.value(_FakeLiveCameraState_1(
          this,
          Invocation.method(
            #getLiveCameraState,
            [],
          ),
        )),
        returnValueForMissingStub:
            _i9.Future<_i3.LiveCameraState>.value(_FakeLiveCameraState_1(
          this,
          Invocation.method(
            #getLiveCameraState,
            [],
          ),
        )),
      ) as _i9.Future<_i3.LiveCameraState>);
}

/// A class which mocks [CameraSelector].
///
/// See the documentation for Mockito's code generation for more information.
class MockCameraSelector extends _i1.Mock implements _i10.CameraSelector {
  @override
  _i9.Future<List<_i2.CameraInfo>> filter(List<_i2.CameraInfo>? cameraInfos) =>
      (super.noSuchMethod(
        Invocation.method(
          #filter,
          [cameraInfos],
        ),
        returnValue: _i9.Future<List<_i2.CameraInfo>>.value(<_i2.CameraInfo>[]),
        returnValueForMissingStub:
            _i9.Future<List<_i2.CameraInfo>>.value(<_i2.CameraInfo>[]),
      ) as _i9.Future<List<_i2.CameraInfo>>);
}

/// A class which mocks [ImageCapture].
///
/// See the documentation for Mockito's code generation for more information.
class MockImageCapture extends _i1.Mock implements _i11.ImageCapture {
  @override
  _i9.Future<void> setFlashMode(int? newFlashMode) => (super.noSuchMethod(
        Invocation.method(
          #setFlashMode,
          [newFlashMode],
        ),
        returnValue: _i9.Future<void>.value(),
        returnValueForMissingStub: _i9.Future<void>.value(),
      ) as _i9.Future<void>);
  @override
  _i9.Future<String> takePicture() => (super.noSuchMethod(
        Invocation.method(
          #takePicture,
          [],
        ),
        returnValue: _i9.Future<String>.value(''),
        returnValueForMissingStub: _i9.Future<String>.value(''),
      ) as _i9.Future<String>);
}

/// A class which mocks [LiveCameraState].
///
/// See the documentation for Mockito's code generation for more information.
class MockLiveCameraState extends _i1.Mock implements _i3.LiveCameraState {
  @override
  _i9.Future<void> addObserver() => (super.noSuchMethod(
        Invocation.method(
          #addObserver,
          [],
        ),
        returnValue: _i9.Future<void>.value(),
        returnValueForMissingStub: _i9.Future<void>.value(),
      ) as _i9.Future<void>);
  @override
  _i9.Future<void> removeObservers() => (super.noSuchMethod(
        Invocation.method(
          #removeObservers,
          [],
        ),
        returnValue: _i9.Future<void>.value(),
        returnValueForMissingStub: _i9.Future<void>.value(),
      ) as _i9.Future<void>);
}

/// A class which mocks [Preview].
///
/// See the documentation for Mockito's code generation for more information.
class MockPreview extends _i1.Mock implements _i12.Preview {
  @override
  _i9.Future<int> setSurfaceProvider() => (super.noSuchMethod(
        Invocation.method(
          #setSurfaceProvider,
          [],
        ),
        returnValue: _i9.Future<int>.value(0),
        returnValueForMissingStub: _i9.Future<int>.value(0),
      ) as _i9.Future<int>);
  @override
  void releaseFlutterSurfaceTexture() => super.noSuchMethod(
        Invocation.method(
          #releaseFlutterSurfaceTexture,
          [],
        ),
        returnValueForMissingStub: null,
      );
  @override
  _i9.Future<_i4.ResolutionInfo> getResolutionInfo() => (super.noSuchMethod(
        Invocation.method(
          #getResolutionInfo,
          [],
        ),
        returnValue: _i9.Future<_i4.ResolutionInfo>.value(_FakeResolutionInfo_2(
          this,
          Invocation.method(
            #getResolutionInfo,
            [],
          ),
        )),
        returnValueForMissingStub:
            _i9.Future<_i4.ResolutionInfo>.value(_FakeResolutionInfo_2(
          this,
          Invocation.method(
            #getResolutionInfo,
            [],
          ),
        )),
      ) as _i9.Future<_i4.ResolutionInfo>);
}

/// A class which mocks [ProcessCameraProvider].
///
/// See the documentation for Mockito's code generation for more information.
class MockProcessCameraProvider extends _i1.Mock
    implements _i13.ProcessCameraProvider {
  @override
  _i9.Future<List<_i2.CameraInfo>> getAvailableCameraInfos() =>
      (super.noSuchMethod(
        Invocation.method(
          #getAvailableCameraInfos,
          [],
        ),
        returnValue: _i9.Future<List<_i2.CameraInfo>>.value(<_i2.CameraInfo>[]),
        returnValueForMissingStub:
            _i9.Future<List<_i2.CameraInfo>>.value(<_i2.CameraInfo>[]),
      ) as _i9.Future<List<_i2.CameraInfo>>);
  @override
  _i9.Future<_i5.Camera> bindToLifecycle(
    _i10.CameraSelector? cameraSelector,
    List<_i14.UseCase>? useCases,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #bindToLifecycle,
          [
            cameraSelector,
            useCases,
          ],
        ),
        returnValue: _i9.Future<_i5.Camera>.value(_FakeCamera_3(
          this,
          Invocation.method(
            #bindToLifecycle,
            [
              cameraSelector,
              useCases,
            ],
          ),
        )),
        returnValueForMissingStub: _i9.Future<_i5.Camera>.value(_FakeCamera_3(
          this,
          Invocation.method(
            #bindToLifecycle,
            [
              cameraSelector,
              useCases,
            ],
          ),
        )),
      ) as _i9.Future<_i5.Camera>);
  @override
  _i9.Future<bool> isBound(_i14.UseCase? useCase) => (super.noSuchMethod(
        Invocation.method(
          #isBound,
          [useCase],
        ),
        returnValue: _i9.Future<bool>.value(false),
        returnValueForMissingStub: _i9.Future<bool>.value(false),
      ) as _i9.Future<bool>);
  @override
  void unbind(List<_i14.UseCase>? useCases) => super.noSuchMethod(
        Invocation.method(
          #unbind,
          [useCases],
        ),
        returnValueForMissingStub: null,
      );
  @override
  void unbindAll() => super.noSuchMethod(
        Invocation.method(
          #unbindAll,
          [],
        ),
        returnValueForMissingStub: null,
      );
}

/// A class which mocks [BuildContext].
///
/// See the documentation for Mockito's code generation for more information.
class MockBuildContext extends _i1.Mock implements _i6.BuildContext {
  MockBuildContext() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i6.Widget get widget => (super.noSuchMethod(
        Invocation.getter(#widget),
        returnValue: _FakeWidget_4(
          this,
          Invocation.getter(#widget),
        ),
      ) as _i6.Widget);
  @override
  bool get mounted => (super.noSuchMethod(
        Invocation.getter(#mounted),
        returnValue: false,
      ) as bool);
  @override
  bool get debugDoingBuild => (super.noSuchMethod(
        Invocation.getter(#debugDoingBuild),
        returnValue: false,
      ) as bool);
  @override
  _i6.InheritedWidget dependOnInheritedElement(
    _i6.InheritedElement? ancestor, {
    Object? aspect,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #dependOnInheritedElement,
          [ancestor],
          {#aspect: aspect},
        ),
        returnValue: _FakeInheritedWidget_5(
          this,
          Invocation.method(
            #dependOnInheritedElement,
            [ancestor],
            {#aspect: aspect},
          ),
        ),
      ) as _i6.InheritedWidget);
  @override
  void visitAncestorElements(_i6.ConditionalElementVisitor? visitor) =>
      super.noSuchMethod(
        Invocation.method(
          #visitAncestorElements,
          [visitor],
        ),
        returnValueForMissingStub: null,
      );
  @override
  void visitChildElements(_i6.ElementVisitor? visitor) => super.noSuchMethod(
        Invocation.method(
          #visitChildElements,
          [visitor],
        ),
        returnValueForMissingStub: null,
      );
  @override
  void dispatchNotification(_i6.Notification? notification) =>
      super.noSuchMethod(
        Invocation.method(
          #dispatchNotification,
          [notification],
        ),
        returnValueForMissingStub: null,
      );
  @override
  _i8.DiagnosticsNode describeElement(
    String? name, {
    _i8.DiagnosticsTreeStyle? style = _i8.DiagnosticsTreeStyle.errorProperty,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #describeElement,
          [name],
          {#style: style},
        ),
        returnValue: _FakeDiagnosticsNode_6(
          this,
          Invocation.method(
            #describeElement,
            [name],
            {#style: style},
          ),
        ),
      ) as _i8.DiagnosticsNode);
  @override
  _i8.DiagnosticsNode describeWidget(
    String? name, {
    _i8.DiagnosticsTreeStyle? style = _i8.DiagnosticsTreeStyle.errorProperty,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #describeWidget,
          [name],
          {#style: style},
        ),
        returnValue: _FakeDiagnosticsNode_6(
          this,
          Invocation.method(
            #describeWidget,
            [name],
            {#style: style},
          ),
        ),
      ) as _i8.DiagnosticsNode);
  @override
  List<_i8.DiagnosticsNode> describeMissingAncestor(
          {required Type? expectedAncestorType}) =>
      (super.noSuchMethod(
        Invocation.method(
          #describeMissingAncestor,
          [],
          {#expectedAncestorType: expectedAncestorType},
        ),
        returnValue: <_i8.DiagnosticsNode>[],
      ) as List<_i8.DiagnosticsNode>);
  @override
  _i8.DiagnosticsNode describeOwnershipChain(String? name) =>
      (super.noSuchMethod(
        Invocation.method(
          #describeOwnershipChain,
          [name],
        ),
        returnValue: _FakeDiagnosticsNode_6(
          this,
          Invocation.method(
            #describeOwnershipChain,
            [name],
          ),
        ),
      ) as _i8.DiagnosticsNode);
}
