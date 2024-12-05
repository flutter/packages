// Mocks generated by Mockito 5.4.4 from annotations
// in webview_flutter_wkwebview/test/webkit_navigation_delegate_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i3;
import 'dart:typed_data' as _i4;

import 'package:mockito/mockito.dart' as _i1;
import 'package:mockito/src/dummies.dart' as _i5;
import 'package:webview_flutter_wkwebview/src/common/web_kit2.g.dart' as _i2;

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

class _FakeURLProtectionSpace_1 extends _i1.SmartFake
    implements _i2.URLProtectionSpace {
  _FakeURLProtectionSpace_1(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeURLAuthenticationChallenge_2 extends _i1.SmartFake
    implements _i2.URLAuthenticationChallenge {
  _FakeURLAuthenticationChallenge_2(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeURLRequest_3 extends _i1.SmartFake implements _i2.URLRequest {
  _FakeURLRequest_3(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeURL_4 extends _i1.SmartFake implements _i2.URL {
  _FakeURL_4(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

/// A class which mocks [URLAuthenticationChallenge].
///
/// See the documentation for Mockito's code generation for more information.
class MockURLAuthenticationChallenge extends _i1.Mock
    implements _i2.URLAuthenticationChallenge {
  MockURLAuthenticationChallenge() {
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
  _i3.Future<_i2.URLProtectionSpace> getProtectionSpace() =>
      (super.noSuchMethod(
        Invocation.method(
          #getProtectionSpace,
          [],
        ),
        returnValue:
            _i3.Future<_i2.URLProtectionSpace>.value(_FakeURLProtectionSpace_1(
          this,
          Invocation.method(
            #getProtectionSpace,
            [],
          ),
        )),
      ) as _i3.Future<_i2.URLProtectionSpace>);

  @override
  _i2.URLAuthenticationChallenge pigeon_copy() => (super.noSuchMethod(
        Invocation.method(
          #pigeon_copy,
          [],
        ),
        returnValue: _FakeURLAuthenticationChallenge_2(
          this,
          Invocation.method(
            #pigeon_copy,
            [],
          ),
        ),
      ) as _i2.URLAuthenticationChallenge);

  @override
  _i3.Future<void> addObserver(
    _i2.NSObject? observer,
    String? keyPath,
    List<_i2.KeyValueObservingOptions>? options,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #addObserver,
          [
            observer,
            keyPath,
            options,
          ],
        ),
        returnValue: _i3.Future<void>.value(),
        returnValueForMissingStub: _i3.Future<void>.value(),
      ) as _i3.Future<void>);

  @override
  _i3.Future<void> removeObserver(
    _i2.NSObject? observer,
    String? keyPath,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #removeObserver,
          [
            observer,
            keyPath,
          ],
        ),
        returnValue: _i3.Future<void>.value(),
        returnValueForMissingStub: _i3.Future<void>.value(),
      ) as _i3.Future<void>);
}

/// A class which mocks [URLRequest].
///
/// See the documentation for Mockito's code generation for more information.
class MockURLRequest extends _i1.Mock implements _i2.URLRequest {
  MockURLRequest() {
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
  _i3.Future<String?> getUrl() => (super.noSuchMethod(
        Invocation.method(
          #getUrl,
          [],
        ),
        returnValue: _i3.Future<String?>.value(),
      ) as _i3.Future<String?>);

  @override
  _i3.Future<void> setHttpMethod(String? method) => (super.noSuchMethod(
        Invocation.method(
          #setHttpMethod,
          [method],
        ),
        returnValue: _i3.Future<void>.value(),
        returnValueForMissingStub: _i3.Future<void>.value(),
      ) as _i3.Future<void>);

  @override
  _i3.Future<String?> getHttpMethod() => (super.noSuchMethod(
        Invocation.method(
          #getHttpMethod,
          [],
        ),
        returnValue: _i3.Future<String?>.value(),
      ) as _i3.Future<String?>);

  @override
  _i3.Future<void> setHttpBody(_i4.Uint8List? body) => (super.noSuchMethod(
        Invocation.method(
          #setHttpBody,
          [body],
        ),
        returnValue: _i3.Future<void>.value(),
        returnValueForMissingStub: _i3.Future<void>.value(),
      ) as _i3.Future<void>);

  @override
  _i3.Future<_i4.Uint8List?> getHttpBody() => (super.noSuchMethod(
        Invocation.method(
          #getHttpBody,
          [],
        ),
        returnValue: _i3.Future<_i4.Uint8List?>.value(),
      ) as _i3.Future<_i4.Uint8List?>);

  @override
  _i3.Future<void> setAllHttpHeaderFields(Map<String, String>? fields) =>
      (super.noSuchMethod(
        Invocation.method(
          #setAllHttpHeaderFields,
          [fields],
        ),
        returnValue: _i3.Future<void>.value(),
        returnValueForMissingStub: _i3.Future<void>.value(),
      ) as _i3.Future<void>);

  @override
  _i3.Future<Map<String, String>?> getAllHttpHeaderFields() =>
      (super.noSuchMethod(
        Invocation.method(
          #getAllHttpHeaderFields,
          [],
        ),
        returnValue: _i3.Future<Map<String, String>?>.value(),
      ) as _i3.Future<Map<String, String>?>);

  @override
  _i2.URLRequest pigeon_copy() => (super.noSuchMethod(
        Invocation.method(
          #pigeon_copy,
          [],
        ),
        returnValue: _FakeURLRequest_3(
          this,
          Invocation.method(
            #pigeon_copy,
            [],
          ),
        ),
      ) as _i2.URLRequest);

  @override
  _i3.Future<void> addObserver(
    _i2.NSObject? observer,
    String? keyPath,
    List<_i2.KeyValueObservingOptions>? options,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #addObserver,
          [
            observer,
            keyPath,
            options,
          ],
        ),
        returnValue: _i3.Future<void>.value(),
        returnValueForMissingStub: _i3.Future<void>.value(),
      ) as _i3.Future<void>);

  @override
  _i3.Future<void> removeObserver(
    _i2.NSObject? observer,
    String? keyPath,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #removeObserver,
          [
            observer,
            keyPath,
          ],
        ),
        returnValue: _i3.Future<void>.value(),
        returnValueForMissingStub: _i3.Future<void>.value(),
      ) as _i3.Future<void>);
}

/// A class which mocks [URL].
///
/// See the documentation for Mockito's code generation for more information.
class MockURL extends _i1.Mock implements _i2.URL {
  MockURL() {
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
  _i3.Future<String> getAbsoluteString() => (super.noSuchMethod(
        Invocation.method(
          #getAbsoluteString,
          [],
        ),
        returnValue: _i3.Future<String>.value(_i5.dummyValue<String>(
          this,
          Invocation.method(
            #getAbsoluteString,
            [],
          ),
        )),
      ) as _i3.Future<String>);

  @override
  _i2.URL pigeon_copy() => (super.noSuchMethod(
        Invocation.method(
          #pigeon_copy,
          [],
        ),
        returnValue: _FakeURL_4(
          this,
          Invocation.method(
            #pigeon_copy,
            [],
          ),
        ),
      ) as _i2.URL);

  @override
  _i3.Future<void> addObserver(
    _i2.NSObject? observer,
    String? keyPath,
    List<_i2.KeyValueObservingOptions>? options,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #addObserver,
          [
            observer,
            keyPath,
            options,
          ],
        ),
        returnValue: _i3.Future<void>.value(),
        returnValueForMissingStub: _i3.Future<void>.value(),
      ) as _i3.Future<void>);

  @override
  _i3.Future<void> removeObserver(
    _i2.NSObject? observer,
    String? keyPath,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #removeObserver,
          [
            observer,
            keyPath,
          ],
        ),
        returnValue: _i3.Future<void>.value(),
        returnValueForMissingStub: _i3.Future<void>.value(),
      ) as _i3.Future<void>);
}
