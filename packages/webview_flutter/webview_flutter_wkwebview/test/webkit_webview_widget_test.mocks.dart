// Mocks generated by Mockito 5.4.1 from annotations
// in webview_flutter_wkwebview/test/webkit_webview_widget_test.dart.
// Do not manually edit this file.

// @dart=2.19

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i3;

import 'package:mockito/mockito.dart' as _i1;
import 'package:webview_flutter_wkwebview/src/foundation/foundation.dart'
    as _i4;
import 'package:webview_flutter_wkwebview/src/web_kit/web_kit.dart' as _i2;

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

class _FakeWKUIDelegate_0 extends _i1.SmartFake implements _i2.WKUIDelegate {
  _FakeWKUIDelegate_0(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeWKUserContentController_1 extends _i1.SmartFake
    implements _i2.WKUserContentController {
  _FakeWKUserContentController_1(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeWKPreferences_2 extends _i1.SmartFake implements _i2.WKPreferences {
  _FakeWKPreferences_2(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeWKWebsiteDataStore_3 extends _i1.SmartFake
    implements _i2.WKWebsiteDataStore {
  _FakeWKWebsiteDataStore_3(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeWKWebViewConfiguration_4 extends _i1.SmartFake
    implements _i2.WKWebViewConfiguration {
  _FakeWKWebViewConfiguration_4(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

/// A class which mocks [WKUIDelegate].
///
/// See the documentation for Mockito's code generation for more information.
// ignore: must_be_immutable
class MockWKUIDelegate extends _i1.Mock implements _i2.WKUIDelegate {
  MockWKUIDelegate() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i2.WKUIDelegate copy() => (super.noSuchMethod(
        Invocation.method(
          #copy,
          [],
        ),
        returnValue: _FakeWKUIDelegate_0(
          this,
          Invocation.method(
            #copy,
            [],
          ),
        ),
      ) as _i2.WKUIDelegate);
  @override
  _i3.Future<void> addObserver(
    _i4.NSObject? observer, {
    required String? keyPath,
    required Set<_i4.NSKeyValueObservingOptions>? options,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #addObserver,
          [observer],
          {
            #keyPath: keyPath,
            #options: options,
          },
        ),
        returnValue: _i3.Future<void>.value(),
        returnValueForMissingStub: _i3.Future<void>.value(),
      ) as _i3.Future<void>);
  @override
  _i3.Future<void> removeObserver(
    _i4.NSObject? observer, {
    required String? keyPath,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #removeObserver,
          [observer],
          {#keyPath: keyPath},
        ),
        returnValue: _i3.Future<void>.value(),
        returnValueForMissingStub: _i3.Future<void>.value(),
      ) as _i3.Future<void>);
}

/// A class which mocks [WKWebViewConfiguration].
///
/// See the documentation for Mockito's code generation for more information.
// ignore: must_be_immutable
class MockWKWebViewConfiguration extends _i1.Mock
    implements _i2.WKWebViewConfiguration {
  MockWKWebViewConfiguration() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i2.WKUserContentController get userContentController => (super.noSuchMethod(
        Invocation.getter(#userContentController),
        returnValue: _FakeWKUserContentController_1(
          this,
          Invocation.getter(#userContentController),
        ),
      ) as _i2.WKUserContentController);
  @override
  _i2.WKPreferences get preferences => (super.noSuchMethod(
        Invocation.getter(#preferences),
        returnValue: _FakeWKPreferences_2(
          this,
          Invocation.getter(#preferences),
        ),
      ) as _i2.WKPreferences);
  @override
  _i2.WKWebsiteDataStore get websiteDataStore => (super.noSuchMethod(
        Invocation.getter(#websiteDataStore),
        returnValue: _FakeWKWebsiteDataStore_3(
          this,
          Invocation.getter(#websiteDataStore),
        ),
      ) as _i2.WKWebsiteDataStore);
  @override
  _i3.Future<void> setAllowsInlineMediaPlayback(bool? allow) =>
      (super.noSuchMethod(
        Invocation.method(
          #setAllowsInlineMediaPlayback,
          [allow],
        ),
        returnValue: _i3.Future<void>.value(),
        returnValueForMissingStub: _i3.Future<void>.value(),
      ) as _i3.Future<void>);
  @override
  _i3.Future<void> setLimitsNavigationsToAppBoundDomains(bool? limit) =>
      (super.noSuchMethod(
        Invocation.method(
          #setLimitsNavigationsToAppBoundDomains,
          [limit],
        ),
        returnValue: _i3.Future<void>.value(),
        returnValueForMissingStub: _i3.Future<void>.value(),
      ) as _i3.Future<void>);
  @override
  _i3.Future<void> setMediaTypesRequiringUserActionForPlayback(
          Set<_i2.WKAudiovisualMediaType>? types) =>
      (super.noSuchMethod(
        Invocation.method(
          #setMediaTypesRequiringUserActionForPlayback,
          [types],
        ),
        returnValue: _i3.Future<void>.value(),
        returnValueForMissingStub: _i3.Future<void>.value(),
      ) as _i3.Future<void>);
  @override
  _i2.WKWebViewConfiguration copy() => (super.noSuchMethod(
        Invocation.method(
          #copy,
          [],
        ),
        returnValue: _FakeWKWebViewConfiguration_4(
          this,
          Invocation.method(
            #copy,
            [],
          ),
        ),
      ) as _i2.WKWebViewConfiguration);
  @override
  _i3.Future<void> addObserver(
    _i4.NSObject? observer, {
    required String? keyPath,
    required Set<_i4.NSKeyValueObservingOptions>? options,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #addObserver,
          [observer],
          {
            #keyPath: keyPath,
            #options: options,
          },
        ),
        returnValue: _i3.Future<void>.value(),
        returnValueForMissingStub: _i3.Future<void>.value(),
      ) as _i3.Future<void>);
  @override
  _i3.Future<void> removeObserver(
    _i4.NSObject? observer, {
    required String? keyPath,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #removeObserver,
          [observer],
          {#keyPath: keyPath},
        ),
        returnValue: _i3.Future<void>.value(),
        returnValueForMissingStub: _i3.Future<void>.value(),
      ) as _i3.Future<void>);
}
