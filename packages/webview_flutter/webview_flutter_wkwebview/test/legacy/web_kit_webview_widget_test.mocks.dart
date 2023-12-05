// Mocks generated by Mockito 5.4.3 from annotations
// in webview_flutter_wkwebview/test/legacy/web_kit_webview_widget_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i5;
import 'dart:math' as _i2;
import 'dart:ui' as _i6;

import 'package:mockito/mockito.dart' as _i1;
import 'package:webview_flutter_platform_interface/src/legacy/types/javascript_channel.dart'
    as _i9;
import 'package:webview_flutter_platform_interface/src/legacy/types/types.dart'
    as _i10;
import 'package:webview_flutter_platform_interface/src/webview_flutter_platform_interface_legacy.dart'
    as _i8;
import 'package:webview_flutter_wkwebview/src/foundation/foundation.dart'
    as _i7;
import 'package:webview_flutter_wkwebview/src/legacy/web_kit_webview_widget.dart'
    as _i11;
import 'package:webview_flutter_wkwebview/src/ui_kit/ui_kit.dart' as _i3;
import 'package:webview_flutter_wkwebview/src/web_kit/web_kit.dart' as _i4;

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

class _FakePoint_0<T extends num> extends _i1.SmartFake
    implements _i2.Point<T> {
  _FakePoint_0(
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

class _FakeWKNavigationDelegate_2 extends _i1.SmartFake
    implements _i4.WKNavigationDelegate {
  _FakeWKNavigationDelegate_2(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeWKPreferences_3 extends _i1.SmartFake implements _i4.WKPreferences {
  _FakeWKPreferences_3(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeWKScriptMessageHandler_4 extends _i1.SmartFake
    implements _i4.WKScriptMessageHandler {
  _FakeWKScriptMessageHandler_4(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeWKWebViewConfiguration_5 extends _i1.SmartFake
    implements _i4.WKWebViewConfiguration {
  _FakeWKWebViewConfiguration_5(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeWKWebView_6 extends _i1.SmartFake implements _i4.WKWebView {
  _FakeWKWebView_6(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeWKUserContentController_7 extends _i1.SmartFake
    implements _i4.WKUserContentController {
  _FakeWKUserContentController_7(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeWKWebsiteDataStore_8 extends _i1.SmartFake
    implements _i4.WKWebsiteDataStore {
  _FakeWKWebsiteDataStore_8(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeWKHttpCookieStore_9 extends _i1.SmartFake
    implements _i4.WKHttpCookieStore {
  _FakeWKHttpCookieStore_9(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeWKUIDelegate_10 extends _i1.SmartFake implements _i4.WKUIDelegate {
  _FakeWKUIDelegate_10(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

/// A class which mocks [UIScrollView].
///
/// See the documentation for Mockito's code generation for more information.
// ignore: must_be_immutable
class MockUIScrollView extends _i1.Mock implements _i3.UIScrollView {
  MockUIScrollView() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i5.Future<_i2.Point<double>> getContentOffset() => (super.noSuchMethod(
        Invocation.method(
          #getContentOffset,
          [],
        ),
        returnValue: _i5.Future<_i2.Point<double>>.value(_FakePoint_0<double>(
          this,
          Invocation.method(
            #getContentOffset,
            [],
          ),
        )),
      ) as _i5.Future<_i2.Point<double>>);

  @override
  _i5.Future<void> scrollBy(_i2.Point<double>? offset) => (super.noSuchMethod(
        Invocation.method(
          #scrollBy,
          [offset],
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);

  @override
  _i5.Future<void> setContentOffset(_i2.Point<double>? offset) =>
      (super.noSuchMethod(
        Invocation.method(
          #setContentOffset,
          [offset],
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);

  @override
  _i3.UIScrollView copy() => (super.noSuchMethod(
        Invocation.method(
          #copy,
          [],
        ),
        returnValue: _FakeUIScrollView_1(
          this,
          Invocation.method(
            #copy,
            [],
          ),
        ),
      ) as _i3.UIScrollView);

  @override
  _i5.Future<void> setBackgroundColor(_i6.Color? color) => (super.noSuchMethod(
        Invocation.method(
          #setBackgroundColor,
          [color],
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);

  @override
  _i5.Future<void> setOpaque(bool? opaque) => (super.noSuchMethod(
        Invocation.method(
          #setOpaque,
          [opaque],
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);

  @override
  _i5.Future<void> addObserver(
    _i7.NSObject? observer, {
    required String? keyPath,
    required Set<_i7.NSKeyValueObservingOptions>? options,
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
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);

  @override
  _i5.Future<void> removeObserver(
    _i7.NSObject? observer, {
    required String? keyPath,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #removeObserver,
          [observer],
          {#keyPath: keyPath},
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);
}

/// A class which mocks [WKNavigationDelegate].
///
/// See the documentation for Mockito's code generation for more information.
// ignore: must_be_immutable
class MockWKNavigationDelegate extends _i1.Mock
    implements _i4.WKNavigationDelegate {
  MockWKNavigationDelegate() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i4.WKNavigationDelegate copy() => (super.noSuchMethod(
        Invocation.method(
          #copy,
          [],
        ),
        returnValue: _FakeWKNavigationDelegate_2(
          this,
          Invocation.method(
            #copy,
            [],
          ),
        ),
      ) as _i4.WKNavigationDelegate);

  @override
  _i5.Future<void> addObserver(
    _i7.NSObject? observer, {
    required String? keyPath,
    required Set<_i7.NSKeyValueObservingOptions>? options,
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
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);

  @override
  _i5.Future<void> removeObserver(
    _i7.NSObject? observer, {
    required String? keyPath,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #removeObserver,
          [observer],
          {#keyPath: keyPath},
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);
}

/// A class which mocks [WKPreferences].
///
/// See the documentation for Mockito's code generation for more information.
// ignore: must_be_immutable
class MockWKPreferences extends _i1.Mock implements _i4.WKPreferences {
  MockWKPreferences() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i5.Future<void> setJavaScriptEnabled(bool? enabled) => (super.noSuchMethod(
        Invocation.method(
          #setJavaScriptEnabled,
          [enabled],
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);

  @override
  _i4.WKPreferences copy() => (super.noSuchMethod(
        Invocation.method(
          #copy,
          [],
        ),
        returnValue: _FakeWKPreferences_3(
          this,
          Invocation.method(
            #copy,
            [],
          ),
        ),
      ) as _i4.WKPreferences);

  @override
  _i5.Future<void> addObserver(
    _i7.NSObject? observer, {
    required String? keyPath,
    required Set<_i7.NSKeyValueObservingOptions>? options,
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
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);

  @override
  _i5.Future<void> removeObserver(
    _i7.NSObject? observer, {
    required String? keyPath,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #removeObserver,
          [observer],
          {#keyPath: keyPath},
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);
}

/// A class which mocks [WKScriptMessageHandler].
///
/// See the documentation for Mockito's code generation for more information.
// ignore: must_be_immutable
class MockWKScriptMessageHandler extends _i1.Mock
    implements _i4.WKScriptMessageHandler {
  MockWKScriptMessageHandler() {
    _i1.throwOnMissingStub(this);
  }

  @override
  void Function(
    _i4.WKUserContentController,
    _i4.WKScriptMessage,
  ) get didReceiveScriptMessage => (super.noSuchMethod(
        Invocation.getter(#didReceiveScriptMessage),
        returnValue: (
          _i4.WKUserContentController userContentController,
          _i4.WKScriptMessage message,
        ) {},
      ) as void Function(
        _i4.WKUserContentController,
        _i4.WKScriptMessage,
      ));

  @override
  _i4.WKScriptMessageHandler copy() => (super.noSuchMethod(
        Invocation.method(
          #copy,
          [],
        ),
        returnValue: _FakeWKScriptMessageHandler_4(
          this,
          Invocation.method(
            #copy,
            [],
          ),
        ),
      ) as _i4.WKScriptMessageHandler);

  @override
  _i5.Future<void> addObserver(
    _i7.NSObject? observer, {
    required String? keyPath,
    required Set<_i7.NSKeyValueObservingOptions>? options,
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
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);

  @override
  _i5.Future<void> removeObserver(
    _i7.NSObject? observer, {
    required String? keyPath,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #removeObserver,
          [observer],
          {#keyPath: keyPath},
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);
}

/// A class which mocks [WKWebView].
///
/// See the documentation for Mockito's code generation for more information.
// ignore: must_be_immutable
class MockWKWebView extends _i1.Mock implements _i4.WKWebView {
  MockWKWebView() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i4.WKWebViewConfiguration get configuration => (super.noSuchMethod(
        Invocation.getter(#configuration),
        returnValue: _FakeWKWebViewConfiguration_5(
          this,
          Invocation.getter(#configuration),
        ),
      ) as _i4.WKWebViewConfiguration);

  @override
  _i3.UIScrollView get scrollView => (super.noSuchMethod(
        Invocation.getter(#scrollView),
        returnValue: _FakeUIScrollView_1(
          this,
          Invocation.getter(#scrollView),
        ),
      ) as _i3.UIScrollView);

  @override
  _i5.Future<void> setUIDelegate(_i4.WKUIDelegate? delegate) =>
      (super.noSuchMethod(
        Invocation.method(
          #setUIDelegate,
          [delegate],
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);

  @override
  _i5.Future<void> setNavigationDelegate(_i4.WKNavigationDelegate? delegate) =>
      (super.noSuchMethod(
        Invocation.method(
          #setNavigationDelegate,
          [delegate],
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);

  @override
  _i5.Future<String?> getUrl() => (super.noSuchMethod(
        Invocation.method(
          #getUrl,
          [],
        ),
        returnValue: _i5.Future<String?>.value(),
      ) as _i5.Future<String?>);

  @override
  _i5.Future<double> getEstimatedProgress() => (super.noSuchMethod(
        Invocation.method(
          #getEstimatedProgress,
          [],
        ),
        returnValue: _i5.Future<double>.value(0.0),
      ) as _i5.Future<double>);

  @override
  _i5.Future<void> loadRequest(_i7.NSUrlRequest? request) =>
      (super.noSuchMethod(
        Invocation.method(
          #loadRequest,
          [request],
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);

  @override
  _i5.Future<void> loadHtmlString(
    String? string, {
    String? baseUrl,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #loadHtmlString,
          [string],
          {#baseUrl: baseUrl},
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);

  @override
  _i5.Future<void> loadFileUrl(
    String? url, {
    required String? readAccessUrl,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #loadFileUrl,
          [url],
          {#readAccessUrl: readAccessUrl},
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);

  @override
  _i5.Future<void> loadFlutterAsset(String? key) => (super.noSuchMethod(
        Invocation.method(
          #loadFlutterAsset,
          [key],
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);

  @override
  _i5.Future<bool> canGoBack() => (super.noSuchMethod(
        Invocation.method(
          #canGoBack,
          [],
        ),
        returnValue: _i5.Future<bool>.value(false),
      ) as _i5.Future<bool>);

  @override
  _i5.Future<bool> canGoForward() => (super.noSuchMethod(
        Invocation.method(
          #canGoForward,
          [],
        ),
        returnValue: _i5.Future<bool>.value(false),
      ) as _i5.Future<bool>);

  @override
  _i5.Future<void> goBack() => (super.noSuchMethod(
        Invocation.method(
          #goBack,
          [],
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);

  @override
  _i5.Future<void> goForward() => (super.noSuchMethod(
        Invocation.method(
          #goForward,
          [],
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);

  @override
  _i5.Future<void> reload() => (super.noSuchMethod(
        Invocation.method(
          #reload,
          [],
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);

  @override
  _i5.Future<String?> getTitle() => (super.noSuchMethod(
        Invocation.method(
          #getTitle,
          [],
        ),
        returnValue: _i5.Future<String?>.value(),
      ) as _i5.Future<String?>);

  @override
  _i5.Future<void> setAllowsBackForwardNavigationGestures(bool? allow) =>
      (super.noSuchMethod(
        Invocation.method(
          #setAllowsBackForwardNavigationGestures,
          [allow],
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);

  @override
  _i5.Future<void> setCustomUserAgent(String? userAgent) => (super.noSuchMethod(
        Invocation.method(
          #setCustomUserAgent,
          [userAgent],
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);

  @override
  _i5.Future<Object?> evaluateJavaScript(String? javaScriptString) =>
      (super.noSuchMethod(
        Invocation.method(
          #evaluateJavaScript,
          [javaScriptString],
        ),
        returnValue: _i5.Future<Object?>.value(),
      ) as _i5.Future<Object?>);

  @override
  _i5.Future<void> setInspectable(bool? inspectable) => (super.noSuchMethod(
        Invocation.method(
          #setInspectable,
          [inspectable],
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);

  @override
  _i5.Future<String?> getCustomUserAgent() => (super.noSuchMethod(
        Invocation.method(
          #getCustomUserAgent,
          [],
        ),
        returnValue: _i5.Future<String?>.value(),
      ) as _i5.Future<String?>);

  @override
  _i4.WKWebView copy() => (super.noSuchMethod(
        Invocation.method(
          #copy,
          [],
        ),
        returnValue: _FakeWKWebView_6(
          this,
          Invocation.method(
            #copy,
            [],
          ),
        ),
      ) as _i4.WKWebView);

  @override
  _i5.Future<void> setBackgroundColor(_i6.Color? color) => (super.noSuchMethod(
        Invocation.method(
          #setBackgroundColor,
          [color],
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);

  @override
  _i5.Future<void> setOpaque(bool? opaque) => (super.noSuchMethod(
        Invocation.method(
          #setOpaque,
          [opaque],
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);

  @override
  _i5.Future<void> addObserver(
    _i7.NSObject? observer, {
    required String? keyPath,
    required Set<_i7.NSKeyValueObservingOptions>? options,
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
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);

  @override
  _i5.Future<void> removeObserver(
    _i7.NSObject? observer, {
    required String? keyPath,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #removeObserver,
          [observer],
          {#keyPath: keyPath},
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);
}

/// A class which mocks [WKWebViewConfiguration].
///
/// See the documentation for Mockito's code generation for more information.
// ignore: must_be_immutable
class MockWKWebViewConfiguration extends _i1.Mock
    implements _i4.WKWebViewConfiguration {
  MockWKWebViewConfiguration() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i4.WKUserContentController get userContentController => (super.noSuchMethod(
        Invocation.getter(#userContentController),
        returnValue: _FakeWKUserContentController_7(
          this,
          Invocation.getter(#userContentController),
        ),
      ) as _i4.WKUserContentController);

  @override
  _i4.WKPreferences get preferences => (super.noSuchMethod(
        Invocation.getter(#preferences),
        returnValue: _FakeWKPreferences_3(
          this,
          Invocation.getter(#preferences),
        ),
      ) as _i4.WKPreferences);

  @override
  _i4.WKWebsiteDataStore get websiteDataStore => (super.noSuchMethod(
        Invocation.getter(#websiteDataStore),
        returnValue: _FakeWKWebsiteDataStore_8(
          this,
          Invocation.getter(#websiteDataStore),
        ),
      ) as _i4.WKWebsiteDataStore);

  @override
  _i5.Future<void> setAllowsInlineMediaPlayback(bool? allow) =>
      (super.noSuchMethod(
        Invocation.method(
          #setAllowsInlineMediaPlayback,
          [allow],
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);

  @override
  _i5.Future<void> setLimitsNavigationsToAppBoundDomains(bool? limit) =>
      (super.noSuchMethod(
        Invocation.method(
          #setLimitsNavigationsToAppBoundDomains,
          [limit],
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);

  @override
  _i5.Future<void> setMediaTypesRequiringUserActionForPlayback(
          Set<_i4.WKAudiovisualMediaType>? types) =>
      (super.noSuchMethod(
        Invocation.method(
          #setMediaTypesRequiringUserActionForPlayback,
          [types],
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);

  @override
  _i4.WKWebViewConfiguration copy() => (super.noSuchMethod(
        Invocation.method(
          #copy,
          [],
        ),
        returnValue: _FakeWKWebViewConfiguration_5(
          this,
          Invocation.method(
            #copy,
            [],
          ),
        ),
      ) as _i4.WKWebViewConfiguration);

  @override
  _i5.Future<void> addObserver(
    _i7.NSObject? observer, {
    required String? keyPath,
    required Set<_i7.NSKeyValueObservingOptions>? options,
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
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);

  @override
  _i5.Future<void> removeObserver(
    _i7.NSObject? observer, {
    required String? keyPath,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #removeObserver,
          [observer],
          {#keyPath: keyPath},
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);
}

/// A class which mocks [WKWebsiteDataStore].
///
/// See the documentation for Mockito's code generation for more information.
// ignore: must_be_immutable
class MockWKWebsiteDataStore extends _i1.Mock
    implements _i4.WKWebsiteDataStore {
  MockWKWebsiteDataStore() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i4.WKHttpCookieStore get httpCookieStore => (super.noSuchMethod(
        Invocation.getter(#httpCookieStore),
        returnValue: _FakeWKHttpCookieStore_9(
          this,
          Invocation.getter(#httpCookieStore),
        ),
      ) as _i4.WKHttpCookieStore);

  @override
  _i5.Future<bool> removeDataOfTypes(
    Set<_i4.WKWebsiteDataType>? dataTypes,
    DateTime? since,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #removeDataOfTypes,
          [
            dataTypes,
            since,
          ],
        ),
        returnValue: _i5.Future<bool>.value(false),
      ) as _i5.Future<bool>);

  @override
  _i4.WKWebsiteDataStore copy() => (super.noSuchMethod(
        Invocation.method(
          #copy,
          [],
        ),
        returnValue: _FakeWKWebsiteDataStore_8(
          this,
          Invocation.method(
            #copy,
            [],
          ),
        ),
      ) as _i4.WKWebsiteDataStore);

  @override
  _i5.Future<void> addObserver(
    _i7.NSObject? observer, {
    required String? keyPath,
    required Set<_i7.NSKeyValueObservingOptions>? options,
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
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);

  @override
  _i5.Future<void> removeObserver(
    _i7.NSObject? observer, {
    required String? keyPath,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #removeObserver,
          [observer],
          {#keyPath: keyPath},
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);
}

/// A class which mocks [WKUIDelegate].
///
/// See the documentation for Mockito's code generation for more information.
// ignore: must_be_immutable
class MockWKUIDelegate extends _i1.Mock implements _i4.WKUIDelegate {
  MockWKUIDelegate() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i4.WKUIDelegate copy() => (super.noSuchMethod(
        Invocation.method(
          #copy,
          [],
        ),
        returnValue: _FakeWKUIDelegate_10(
          this,
          Invocation.method(
            #copy,
            [],
          ),
        ),
      ) as _i4.WKUIDelegate);

  @override
  _i5.Future<void> addObserver(
    _i7.NSObject? observer, {
    required String? keyPath,
    required Set<_i7.NSKeyValueObservingOptions>? options,
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
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);

  @override
  _i5.Future<void> removeObserver(
    _i7.NSObject? observer, {
    required String? keyPath,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #removeObserver,
          [observer],
          {#keyPath: keyPath},
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);
}

/// A class which mocks [WKUserContentController].
///
/// See the documentation for Mockito's code generation for more information.
// ignore: must_be_immutable
class MockWKUserContentController extends _i1.Mock
    implements _i4.WKUserContentController {
  MockWKUserContentController() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i5.Future<void> addScriptMessageHandler(
    _i4.WKScriptMessageHandler? handler,
    String? name,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #addScriptMessageHandler,
          [
            handler,
            name,
          ],
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);

  @override
  _i5.Future<void> removeScriptMessageHandler(String? name) =>
      (super.noSuchMethod(
        Invocation.method(
          #removeScriptMessageHandler,
          [name],
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);

  @override
  _i5.Future<void> removeAllScriptMessageHandlers() => (super.noSuchMethod(
        Invocation.method(
          #removeAllScriptMessageHandlers,
          [],
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);

  @override
  _i5.Future<void> addUserScript(_i4.WKUserScript? userScript) =>
      (super.noSuchMethod(
        Invocation.method(
          #addUserScript,
          [userScript],
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);

  @override
  _i5.Future<void> removeAllUserScripts() => (super.noSuchMethod(
        Invocation.method(
          #removeAllUserScripts,
          [],
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);

  @override
  _i4.WKUserContentController copy() => (super.noSuchMethod(
        Invocation.method(
          #copy,
          [],
        ),
        returnValue: _FakeWKUserContentController_7(
          this,
          Invocation.method(
            #copy,
            [],
          ),
        ),
      ) as _i4.WKUserContentController);

  @override
  _i5.Future<void> addObserver(
    _i7.NSObject? observer, {
    required String? keyPath,
    required Set<_i7.NSKeyValueObservingOptions>? options,
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
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);

  @override
  _i5.Future<void> removeObserver(
    _i7.NSObject? observer, {
    required String? keyPath,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #removeObserver,
          [observer],
          {#keyPath: keyPath},
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);
}

/// A class which mocks [JavascriptChannelRegistry].
///
/// See the documentation for Mockito's code generation for more information.
class MockJavascriptChannelRegistry extends _i1.Mock
    implements _i8.JavascriptChannelRegistry {
  MockJavascriptChannelRegistry() {
    _i1.throwOnMissingStub(this);
  }

  @override
  Map<String, _i9.JavascriptChannel> get channels => (super.noSuchMethod(
        Invocation.getter(#channels),
        returnValue: <String, _i9.JavascriptChannel>{},
      ) as Map<String, _i9.JavascriptChannel>);

  @override
  void onJavascriptChannelMessage(
    String? channel,
    String? message,
  ) =>
      super.noSuchMethod(
        Invocation.method(
          #onJavascriptChannelMessage,
          [
            channel,
            message,
          ],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void updateJavascriptChannelsFromSet(Set<_i9.JavascriptChannel>? channels) =>
      super.noSuchMethod(
        Invocation.method(
          #updateJavascriptChannelsFromSet,
          [channels],
        ),
        returnValueForMissingStub: null,
      );
}

/// A class which mocks [WebViewPlatformCallbacksHandler].
///
/// See the documentation for Mockito's code generation for more information.
class MockWebViewPlatformCallbacksHandler extends _i1.Mock
    implements _i8.WebViewPlatformCallbacksHandler {
  MockWebViewPlatformCallbacksHandler() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i5.FutureOr<bool> onNavigationRequest({
    required String? url,
    required bool? isForMainFrame,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #onNavigationRequest,
          [],
          {
            #url: url,
            #isForMainFrame: isForMainFrame,
          },
        ),
        returnValue: _i5.Future<bool>.value(false),
      ) as _i5.FutureOr<bool>);

  @override
  void onPageStarted(String? url) => super.noSuchMethod(
        Invocation.method(
          #onPageStarted,
          [url],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void onPageFinished(String? url) => super.noSuchMethod(
        Invocation.method(
          #onPageFinished,
          [url],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void onProgress(int? progress) => super.noSuchMethod(
        Invocation.method(
          #onProgress,
          [progress],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void onWebResourceError(_i10.WebResourceError? error) => super.noSuchMethod(
        Invocation.method(
          #onWebResourceError,
          [error],
        ),
        returnValueForMissingStub: null,
      );
}

/// A class which mocks [WebViewWidgetProxy].
///
/// See the documentation for Mockito's code generation for more information.
class MockWebViewWidgetProxy extends _i1.Mock
    implements _i11.WebViewWidgetProxy {
  MockWebViewWidgetProxy() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i4.WKWebView createWebView(
    _i4.WKWebViewConfiguration? configuration, {
    void Function(
      String,
      _i7.NSObject,
      Map<_i7.NSKeyValueChangeKey, Object?>,
    )? observeValue,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #createWebView,
          [configuration],
          {#observeValue: observeValue},
        ),
        returnValue: _FakeWKWebView_6(
          this,
          Invocation.method(
            #createWebView,
            [configuration],
            {#observeValue: observeValue},
          ),
        ),
      ) as _i4.WKWebView);

  @override
  _i4.WKScriptMessageHandler createScriptMessageHandler(
          {required void Function(
            _i4.WKUserContentController,
            _i4.WKScriptMessage,
          )? didReceiveScriptMessage}) =>
      (super.noSuchMethod(
        Invocation.method(
          #createScriptMessageHandler,
          [],
          {#didReceiveScriptMessage: didReceiveScriptMessage},
        ),
        returnValue: _FakeWKScriptMessageHandler_4(
          this,
          Invocation.method(
            #createScriptMessageHandler,
            [],
            {#didReceiveScriptMessage: didReceiveScriptMessage},
          ),
        ),
      ) as _i4.WKScriptMessageHandler);

  @override
  _i4.WKUIDelegate createUIDelgate(
          {void Function(
            _i4.WKWebView,
            _i4.WKWebViewConfiguration,
            _i4.WKNavigationAction,
          )? onCreateWebView}) =>
      (super.noSuchMethod(
        Invocation.method(
          #createUIDelgate,
          [],
          {#onCreateWebView: onCreateWebView},
        ),
        returnValue: _FakeWKUIDelegate_10(
          this,
          Invocation.method(
            #createUIDelgate,
            [],
            {#onCreateWebView: onCreateWebView},
          ),
        ),
      ) as _i4.WKUIDelegate);

  @override
  _i4.WKNavigationDelegate createNavigationDelegate({
    void Function(
      _i4.WKWebView,
      String?,
    )? didFinishNavigation,
    void Function(
      _i4.WKWebView,
      String?,
    )? didStartProvisionalNavigation,
    _i5.Future<_i4.WKNavigationActionPolicy> Function(
      _i4.WKWebView,
      _i4.WKNavigationAction,
    )? decidePolicyForNavigationAction,
    void Function(
      _i4.WKWebView,
      _i7.NSError,
    )? didFailNavigation,
    void Function(
      _i4.WKWebView,
      _i7.NSError,
    )? didFailProvisionalNavigation,
    void Function(_i4.WKWebView)? webViewWebContentProcessDidTerminate,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #createNavigationDelegate,
          [],
          {
            #didFinishNavigation: didFinishNavigation,
            #didStartProvisionalNavigation: didStartProvisionalNavigation,
            #decidePolicyForNavigationAction: decidePolicyForNavigationAction,
            #didFailNavigation: didFailNavigation,
            #didFailProvisionalNavigation: didFailProvisionalNavigation,
            #webViewWebContentProcessDidTerminate:
                webViewWebContentProcessDidTerminate,
          },
        ),
        returnValue: _FakeWKNavigationDelegate_2(
          this,
          Invocation.method(
            #createNavigationDelegate,
            [],
            {
              #didFinishNavigation: didFinishNavigation,
              #didStartProvisionalNavigation: didStartProvisionalNavigation,
              #decidePolicyForNavigationAction: decidePolicyForNavigationAction,
              #didFailNavigation: didFailNavigation,
              #didFailProvisionalNavigation: didFailProvisionalNavigation,
              #webViewWebContentProcessDidTerminate:
                  webViewWebContentProcessDidTerminate,
            },
          ),
        ),
      ) as _i4.WKNavigationDelegate);
}
