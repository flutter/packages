// Mocks generated by Mockito 5.3.2 from annotations
// in webview_flutter_wkwebview/test/webkit_navigation_delegate_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i4;
import 'dart:ui' as _i6;

import 'package:mockito/mockito.dart' as _i1;
import 'package:webview_flutter_wkwebview/src/foundation/foundation.dart'
    as _i5;
import 'package:webview_flutter_wkwebview/src/ui_kit/ui_kit.dart' as _i3;
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

class _FakeWKWebViewConfiguration_0 extends _i1.SmartFake
    implements _i2.WKWebViewConfiguration {
  _FakeWKWebViewConfiguration_0(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeUIScrollView_1 extends _i1.SmartFake implements _i3.UIScrollView {
  _FakeUIScrollView_1(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeWKWebView_2 extends _i1.SmartFake implements _i2.WKWebView {
  _FakeWKWebView_2(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

/// A class which mocks [WKWebView].
///
/// See the documentation for Mockito's code generation for more information.
// ignore: must_be_immutable
class MockWKWebView extends _i1.Mock implements _i2.WKWebView {
  MockWKWebView() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i2.WKWebViewConfiguration get configuration => (super.noSuchMethod(
        Invocation.getter(#configuration),
        returnValue: _FakeWKWebViewConfiguration_0(
          this,
          Invocation.getter(#configuration),
        ),
      ) as _i2.WKWebViewConfiguration);
  @override
  _i3.UIScrollView get scrollView => (super.noSuchMethod(
        Invocation.getter(#scrollView),
        returnValue: _FakeUIScrollView_1(
          this,
          Invocation.getter(#scrollView),
        ),
      ) as _i3.UIScrollView);
  @override
  _i4.Future<void> setUIDelegate(_i2.WKUIDelegate? delegate) =>
      (super.noSuchMethod(
        Invocation.method(
          #setUIDelegate,
          [delegate],
        ),
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);
  @override
  _i4.Future<void> setNavigationDelegate(_i2.WKNavigationDelegate? delegate) =>
      (super.noSuchMethod(
        Invocation.method(
          #setNavigationDelegate,
          [delegate],
        ),
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);
  @override
  _i4.Future<String?> getUrl() => (super.noSuchMethod(
        Invocation.method(
          #getUrl,
          [],
        ),
        returnValue: _i4.Future<String?>.value(),
      ) as _i4.Future<String?>);
  @override
  _i4.Future<double> getEstimatedProgress() => (super.noSuchMethod(
        Invocation.method(
          #getEstimatedProgress,
          [],
        ),
        returnValue: _i4.Future<double>.value(0.0),
      ) as _i4.Future<double>);
  @override
  _i4.Future<void> loadRequest(_i5.NSUrlRequest? request) =>
      (super.noSuchMethod(
        Invocation.method(
          #loadRequest,
          [request],
        ),
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);
  @override
  _i4.Future<void> loadHtmlString(
    String? string, {
    String? baseUrl,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #loadHtmlString,
          [string],
          {#baseUrl: baseUrl},
        ),
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);
  @override
  _i4.Future<void> loadFileUrl(
    String? url, {
    required String? readAccessUrl,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #loadFileUrl,
          [url],
          {#readAccessUrl: readAccessUrl},
        ),
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);
  @override
  _i4.Future<void> loadFlutterAsset(String? key) => (super.noSuchMethod(
        Invocation.method(
          #loadFlutterAsset,
          [key],
        ),
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);
  @override
  _i4.Future<bool> canGoBack() => (super.noSuchMethod(
        Invocation.method(
          #canGoBack,
          [],
        ),
        returnValue: _i4.Future<bool>.value(false),
      ) as _i4.Future<bool>);
  @override
  _i4.Future<bool> canGoForward() => (super.noSuchMethod(
        Invocation.method(
          #canGoForward,
          [],
        ),
        returnValue: _i4.Future<bool>.value(false),
      ) as _i4.Future<bool>);
  @override
  _i4.Future<void> goBack() => (super.noSuchMethod(
        Invocation.method(
          #goBack,
          [],
        ),
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);
  @override
  _i4.Future<void> goForward() => (super.noSuchMethod(
        Invocation.method(
          #goForward,
          [],
        ),
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);
  @override
  _i4.Future<void> reload() => (super.noSuchMethod(
        Invocation.method(
          #reload,
          [],
        ),
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);
  @override
  _i4.Future<String?> getTitle() => (super.noSuchMethod(
        Invocation.method(
          #getTitle,
          [],
        ),
        returnValue: _i4.Future<String?>.value(),
      ) as _i4.Future<String?>);
  @override
  _i4.Future<void> setAllowsBackForwardNavigationGestures(bool? allow) =>
      (super.noSuchMethod(
        Invocation.method(
          #setAllowsBackForwardNavigationGestures,
          [allow],
        ),
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);
  @override
  _i4.Future<void> setCustomUserAgent(String? userAgent) => (super.noSuchMethod(
        Invocation.method(
          #setCustomUserAgent,
          [userAgent],
        ),
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);
  @override
  _i4.Future<Object?> evaluateJavaScript(String? javaScriptString) =>
      (super.noSuchMethod(
        Invocation.method(
          #evaluateJavaScript,
          [javaScriptString],
        ),
        returnValue: _i4.Future<Object?>.value(),
      ) as _i4.Future<Object?>);
  @override
  _i2.WKWebView copy() => (super.noSuchMethod(
        Invocation.method(
          #copy,
          [],
        ),
        returnValue: _FakeWKWebView_2(
          this,
          Invocation.method(
            #copy,
            [],
          ),
        ),
      ) as _i2.WKWebView);
  @override
  _i4.Future<void> setBackgroundColor(_i6.Color? color) => (super.noSuchMethod(
        Invocation.method(
          #setBackgroundColor,
          [color],
        ),
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);
  @override
  _i4.Future<void> setOpaque(bool? opaque) => (super.noSuchMethod(
        Invocation.method(
          #setOpaque,
          [opaque],
        ),
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);
  @override
  _i4.Future<void> addObserver(
    _i5.NSObject? observer, {
    required String? keyPath,
    required Set<_i5.NSKeyValueObservingOptions>? options,
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
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);
  @override
  _i4.Future<void> removeObserver(
    _i5.NSObject? observer, {
    required String? keyPath,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #removeObserver,
          [observer],
          {#keyPath: keyPath},
        ),
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);
}
