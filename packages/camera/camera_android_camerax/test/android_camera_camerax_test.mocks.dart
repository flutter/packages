// Mocks generated by Mockito 5.4.0 from annotations
// in camera_android_camerax/test/android_camera_camerax_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i8;

import 'package:camera_android_camerax/src/camera.dart' as _i3;
import 'package:camera_android_camerax/src/camera_info.dart' as _i7;
import 'package:camera_android_camerax/src/camera_selector.dart' as _i9;
import 'package:camera_android_camerax/src/camerax_library.g.dart' as _i2;
import 'package:camera_android_camerax/src/image_capture.dart' as _i10;
import 'package:camera_android_camerax/src/preview.dart' as _i11;
import 'package:camera_android_camerax/src/process_camera_provider.dart'
    as _i12;
import 'package:camera_android_camerax/src/use_case.dart' as _i13;
import 'package:flutter/foundation.dart' as _i6;
import 'package:flutter/services.dart' as _i5;
import 'package:flutter/widgets.dart' as _i4;
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

class _FakeResolutionInfo_0 extends _i1.SmartFake
    implements _i2.ResolutionInfo {
  _FakeResolutionInfo_0(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeCamera_1 extends _i1.SmartFake implements _i3.Camera {
  _FakeCamera_1(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeWidget_2 extends _i1.SmartFake implements _i4.Widget {
  _FakeWidget_2(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );

  @override
  String toString({_i5.DiagnosticLevel? minLevel = _i5.DiagnosticLevel.info}) =>
      super.toString();
}

class _FakeInheritedWidget_3 extends _i1.SmartFake
    implements _i4.InheritedWidget {
  _FakeInheritedWidget_3(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );

  @override
  String toString({_i5.DiagnosticLevel? minLevel = _i5.DiagnosticLevel.info}) =>
      super.toString();
}

class _FakeDiagnosticsNode_4 extends _i1.SmartFake
    implements _i6.DiagnosticsNode {
  _FakeDiagnosticsNode_4(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );

  @override
  String toString({
    _i6.TextTreeConfiguration? parentConfiguration,
    _i5.DiagnosticLevel? minLevel = _i5.DiagnosticLevel.info,
  }) =>
      super.toString();
}

/// A class which mocks [Camera].
///
/// See the documentation for Mockito's code generation for more information.
class MockCamera extends _i1.Mock implements _i3.Camera {}

/// A class which mocks [CameraInfo].
///
/// See the documentation for Mockito's code generation for more information.
class MockCameraInfo extends _i1.Mock implements _i7.CameraInfo {
  @override
  _i8.Future<int> getSensorRotationDegrees() => (super.noSuchMethod(
        Invocation.method(
          #getSensorRotationDegrees,
          [],
        ),
        returnValue: _i8.Future<int>.value(0),
        returnValueForMissingStub: _i8.Future<int>.value(0),
      ) as _i8.Future<int>);
}

/// A class which mocks [CameraSelector].
///
/// See the documentation for Mockito's code generation for more information.
class MockCameraSelector extends _i1.Mock implements _i9.CameraSelector {
  @override
  _i8.Future<List<_i7.CameraInfo>> filter(List<_i7.CameraInfo>? cameraInfos) =>
      (super.noSuchMethod(
        Invocation.method(
          #filter,
          [cameraInfos],
        ),
        returnValue: _i8.Future<List<_i7.CameraInfo>>.value(<_i7.CameraInfo>[]),
        returnValueForMissingStub:
            _i8.Future<List<_i7.CameraInfo>>.value(<_i7.CameraInfo>[]),
      ) as _i8.Future<List<_i7.CameraInfo>>);
}

/// A class which mocks [ImageCapture].
///
/// See the documentation for Mockito's code generation for more information.
class MockImageCapture extends _i1.Mock implements _i10.ImageCapture {
  @override
  _i8.Future<void> setFlashMode(int? newFlashMode) => (super.noSuchMethod(
        Invocation.method(
          #setFlashMode,
          [newFlashMode],
        ),
        returnValue: _i8.Future<void>.value(),
        returnValueForMissingStub: _i8.Future<void>.value(),
      ) as _i8.Future<void>);
  @override
  _i8.Future<String> takePicture() => (super.noSuchMethod(
        Invocation.method(
          #takePicture,
          [],
        ),
        returnValue: _i8.Future<String>.value(''),
        returnValueForMissingStub: _i8.Future<String>.value(''),
      ) as _i8.Future<String>);
}

/// A class which mocks [Preview].
///
/// See the documentation for Mockito's code generation for more information.
class MockPreview extends _i1.Mock implements _i11.Preview {
  @override
  _i8.Future<int> setSurfaceProvider() => (super.noSuchMethod(
        Invocation.method(
          #setSurfaceProvider,
          [],
        ),
        returnValue: _i8.Future<int>.value(0),
        returnValueForMissingStub: _i8.Future<int>.value(0),
      ) as _i8.Future<int>);
  @override
  void releaseFlutterSurfaceTexture() => super.noSuchMethod(
        Invocation.method(
          #releaseFlutterSurfaceTexture,
          [],
        ),
        returnValueForMissingStub: null,
      );
  @override
  _i8.Future<_i2.ResolutionInfo> getResolutionInfo() => (super.noSuchMethod(
        Invocation.method(
          #getResolutionInfo,
          [],
        ),
        returnValue: _i8.Future<_i2.ResolutionInfo>.value(_FakeResolutionInfo_0(
          this,
          Invocation.method(
            #getResolutionInfo,
            [],
          ),
        )),
        returnValueForMissingStub:
            _i8.Future<_i2.ResolutionInfo>.value(_FakeResolutionInfo_0(
          this,
          Invocation.method(
            #getResolutionInfo,
            [],
          ),
        )),
      ) as _i8.Future<_i2.ResolutionInfo>);
}

/// A class which mocks [ProcessCameraProvider].
///
/// See the documentation for Mockito's code generation for more information.
class MockProcessCameraProvider extends _i1.Mock
    implements _i12.ProcessCameraProvider {
  @override
  _i8.Future<List<_i7.CameraInfo>> getAvailableCameraInfos() =>
      (super.noSuchMethod(
        Invocation.method(
          #getAvailableCameraInfos,
          [],
        ),
        returnValue: _i8.Future<List<_i7.CameraInfo>>.value(<_i7.CameraInfo>[]),
        returnValueForMissingStub:
            _i8.Future<List<_i7.CameraInfo>>.value(<_i7.CameraInfo>[]),
      ) as _i8.Future<List<_i7.CameraInfo>>);
  @override
  _i8.Future<_i3.Camera> bindToLifecycle(
    _i9.CameraSelector? cameraSelector,
    List<_i13.UseCase>? useCases,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #bindToLifecycle,
          [
            cameraSelector,
            useCases,
          ],
        ),
        returnValue: _i8.Future<_i3.Camera>.value(_FakeCamera_1(
          this,
          Invocation.method(
            #bindToLifecycle,
            [
              cameraSelector,
              useCases,
            ],
          ),
        )),
        returnValueForMissingStub: _i8.Future<_i3.Camera>.value(_FakeCamera_1(
          this,
          Invocation.method(
            #bindToLifecycle,
            [
              cameraSelector,
              useCases,
            ],
          ),
        )),
      ) as _i8.Future<_i3.Camera>);
  @override
  _i8.Future<bool> isBound(_i13.UseCase? useCase) => (super.noSuchMethod(
        Invocation.method(
          #isBound,
          [useCase],
        ),
        returnValue: _i8.Future<bool>.value(false),
        returnValueForMissingStub: _i8.Future<bool>.value(false),
      ) as _i8.Future<bool>);
  @override
  void unbind(List<_i13.UseCase>? useCases) => super.noSuchMethod(
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
class MockBuildContext extends _i1.Mock implements _i4.BuildContext {
  MockBuildContext() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i4.Widget get widget => (super.noSuchMethod(
        Invocation.getter(#widget),
        returnValue: _FakeWidget_2(
          this,
          Invocation.getter(#widget),
        ),
      ) as _i4.Widget);
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
  _i4.InheritedWidget dependOnInheritedElement(
    _i4.InheritedElement? ancestor, {
    Object? aspect,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #dependOnInheritedElement,
          [ancestor],
          {#aspect: aspect},
        ),
        returnValue: _FakeInheritedWidget_3(
          this,
          Invocation.method(
            #dependOnInheritedElement,
            [ancestor],
            {#aspect: aspect},
          ),
        ),
      ) as _i4.InheritedWidget);
  @override
  void visitAncestorElements(bool Function(_i4.Element)? visitor) =>
      super.noSuchMethod(
        Invocation.method(
          #visitAncestorElements,
          [visitor],
        ),
        returnValueForMissingStub: null,
      );
  @override
  void visitChildElements(_i4.ElementVisitor? visitor) => super.noSuchMethod(
        Invocation.method(
          #visitChildElements,
          [visitor],
        ),
        returnValueForMissingStub: null,
      );
  @override
  void dispatchNotification(_i4.Notification? notification) =>
      super.noSuchMethod(
        Invocation.method(
          #dispatchNotification,
          [notification],
        ),
        returnValueForMissingStub: null,
      );
  @override
  _i6.DiagnosticsNode describeElement(
    String? name, {
    _i6.DiagnosticsTreeStyle? style = _i6.DiagnosticsTreeStyle.errorProperty,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #describeElement,
          [name],
          {#style: style},
        ),
        returnValue: _FakeDiagnosticsNode_4(
          this,
          Invocation.method(
            #describeElement,
            [name],
            {#style: style},
          ),
        ),
      ) as _i6.DiagnosticsNode);
  @override
  _i6.DiagnosticsNode describeWidget(
    String? name, {
    _i6.DiagnosticsTreeStyle? style = _i6.DiagnosticsTreeStyle.errorProperty,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #describeWidget,
          [name],
          {#style: style},
        ),
        returnValue: _FakeDiagnosticsNode_4(
          this,
          Invocation.method(
            #describeWidget,
            [name],
            {#style: style},
          ),
        ),
      ) as _i6.DiagnosticsNode);
  @override
  List<_i6.DiagnosticsNode> describeMissingAncestor(
          {required Type? expectedAncestorType}) =>
      (super.noSuchMethod(
        Invocation.method(
          #describeMissingAncestor,
          [],
          {#expectedAncestorType: expectedAncestorType},
        ),
        returnValue: <_i6.DiagnosticsNode>[],
      ) as List<_i6.DiagnosticsNode>);
  @override
  _i6.DiagnosticsNode describeOwnershipChain(String? name) =>
      (super.noSuchMethod(
        Invocation.method(
          #describeOwnershipChain,
          [name],
        ),
        returnValue: _FakeDiagnosticsNode_4(
          this,
          Invocation.method(
            #describeOwnershipChain,
            [name],
          ),
        ),
      ) as _i6.DiagnosticsNode);
}
