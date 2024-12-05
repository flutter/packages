// Mocks generated by Mockito 5.4.4 from annotations
// in webview_flutter_wkwebview/test/webkit_webview_cookie_manager_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i3;

import 'package:mockito/mockito.dart' as _i1;
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

class _FakeWKHTTPCookieStore_0 extends _i1.SmartFake
    implements _i2.WKHTTPCookieStore {
  _FakeWKHTTPCookieStore_0(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakePigeonInstanceManager_1 extends _i1.SmartFake
    implements _i2.PigeonInstanceManager {
  _FakePigeonInstanceManager_1(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeWKWebsiteDataStore_2 extends _i1.SmartFake
    implements _i2.WKWebsiteDataStore {
  _FakeWKWebsiteDataStore_2(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

/// A class which mocks [WKWebsiteDataStore].
///
/// See the documentation for Mockito's code generation for more information.
class MockWKWebsiteDataStore extends _i1.Mock
    implements _i2.WKWebsiteDataStore {
  MockWKWebsiteDataStore() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i2.WKHTTPCookieStore get httpCookieStore => (super.noSuchMethod(
        Invocation.getter(#httpCookieStore),
        returnValue: _FakeWKHTTPCookieStore_0(
          this,
          Invocation.getter(#httpCookieStore),
        ),
      ) as _i2.WKHTTPCookieStore);

  @override
  _i2.PigeonInstanceManager get pigeon_instanceManager => (super.noSuchMethod(
        Invocation.getter(#pigeon_instanceManager),
        returnValue: _FakePigeonInstanceManager_1(
          this,
          Invocation.getter(#pigeon_instanceManager),
        ),
      ) as _i2.PigeonInstanceManager);

  @override
  _i2.WKHTTPCookieStore pigeonVar_httpCookieStore() => (super.noSuchMethod(
        Invocation.method(
          #pigeonVar_httpCookieStore,
          [],
        ),
        returnValue: _FakeWKHTTPCookieStore_0(
          this,
          Invocation.method(
            #pigeonVar_httpCookieStore,
            [],
          ),
        ),
      ) as _i2.WKHTTPCookieStore);

  @override
  _i3.Future<bool> removeDataOfTypes(
    List<_i2.WebsiteDataType>? dataTypes,
    double? modificationTimeInSecondsSinceEpoch,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #removeDataOfTypes,
          [
            dataTypes,
            modificationTimeInSecondsSinceEpoch,
          ],
        ),
        returnValue: _i3.Future<bool>.value(false),
      ) as _i3.Future<bool>);

  @override
  _i2.WKWebsiteDataStore pigeon_copy() => (super.noSuchMethod(
        Invocation.method(
          #pigeon_copy,
          [],
        ),
        returnValue: _FakeWKWebsiteDataStore_2(
          this,
          Invocation.method(
            #pigeon_copy,
            [],
          ),
        ),
      ) as _i2.WKWebsiteDataStore);

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

/// A class which mocks [WKHTTPCookieStore].
///
/// See the documentation for Mockito's code generation for more information.
class MockWKHTTPCookieStore extends _i1.Mock implements _i2.WKHTTPCookieStore {
  MockWKHTTPCookieStore() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i2.PigeonInstanceManager get pigeon_instanceManager => (super.noSuchMethod(
        Invocation.getter(#pigeon_instanceManager),
        returnValue: _FakePigeonInstanceManager_1(
          this,
          Invocation.getter(#pigeon_instanceManager),
        ),
      ) as _i2.PigeonInstanceManager);

  @override
  _i3.Future<void> setCookie(_i2.HTTPCookie? cookie) => (super.noSuchMethod(
        Invocation.method(
          #setCookie,
          [cookie],
        ),
        returnValue: _i3.Future<void>.value(),
        returnValueForMissingStub: _i3.Future<void>.value(),
      ) as _i3.Future<void>);

  @override
  _i2.WKHTTPCookieStore pigeon_copy() => (super.noSuchMethod(
        Invocation.method(
          #pigeon_copy,
          [],
        ),
        returnValue: _FakeWKHTTPCookieStore_0(
          this,
          Invocation.method(
            #pigeon_copy,
            [],
          ),
        ),
      ) as _i2.WKHTTPCookieStore);

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
