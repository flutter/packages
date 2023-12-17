// Mocks generated by Mockito 5.4.3 from annotations
// in webview_flutter_wkwebview/test/webkit_webview_controller_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i6;
import 'dart:math' as _i3;
import 'dart:ui' as _i7;

import 'package:mockito/mockito.dart' as _i1;
import 'package:webview_flutter_wkwebview/src/foundation/foundation.dart'
    as _i2;
import 'package:webview_flutter_wkwebview/src/ui_kit/ui_kit.dart' as _i4;
import 'package:webview_flutter_wkwebview/src/web_kit/web_kit.dart' as _i5;

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

class _FakeNSObject_0 extends _i1.SmartFake implements _i2.NSObject {
  _FakeNSObject_0(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakePoint_1<T extends num> extends _i1.SmartFake
    implements _i3.Point<T> {
  _FakePoint_1(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeUIScrollView_2 extends _i1.SmartFake implements _i4.UIScrollView {
  _FakeUIScrollView_2(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeUIScrollViewDelegate_3 extends _i1.SmartFake
    implements _i4.UIScrollViewDelegate {
  _FakeUIScrollViewDelegate_3(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeWKPreferences_4 extends _i1.SmartFake implements _i5.WKPreferences {
  _FakeWKPreferences_4(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeWKUserContentController_5 extends _i1.SmartFake
    implements _i5.WKUserContentController {
  _FakeWKUserContentController_5(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeWKHttpCookieStore_6 extends _i1.SmartFake
    implements _i5.WKHttpCookieStore {
  _FakeWKHttpCookieStore_6(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeWKWebsiteDataStore_7 extends _i1.SmartFake
    implements _i5.WKWebsiteDataStore {
  _FakeWKWebsiteDataStore_7(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeWKWebViewConfiguration_8 extends _i1.SmartFake
    implements _i5.WKWebViewConfiguration {
  _FakeWKWebViewConfiguration_8(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeWKWebView_9 extends _i1.SmartFake implements _i5.WKWebView {
  _FakeWKWebView_9(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeWKScriptMessageHandler_10 extends _i1.SmartFake
    implements _i5.WKScriptMessageHandler {
  _FakeWKScriptMessageHandler_10(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

/// A class which mocks [NSUrl].
///
/// See the documentation for Mockito's code generation for more information.
class MockNSUrl extends _i1.Mock implements _i2.NSUrl {
  MockNSUrl() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i6.Future<String?> getAbsoluteString() => (super.noSuchMethod(
        Invocation.method(
          #getAbsoluteString,
          [],
        ),
        returnValue: _i6.Future<String?>.value(),
      ) as _i6.Future<String?>);

  @override
  _i2.NSObject copy() => (super.noSuchMethod(
        Invocation.method(
          #copy,
          [],
        ),
        returnValue: _FakeNSObject_0(
          this,
          Invocation.method(
            #copy,
            [],
          ),
        ),
      ) as _i2.NSObject);

  @override
  _i6.Future<void> addObserver(
    _i2.NSObject? observer, {
    required String? keyPath,
    required Set<_i2.NSKeyValueObservingOptions>? options,
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
        returnValue: _i6.Future<void>.value(),
        returnValueForMissingStub: _i6.Future<void>.value(),
      ) as _i6.Future<void>);

  @override
  _i6.Future<void> removeObserver(
    _i2.NSObject? observer, {
    required String? keyPath,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #removeObserver,
          [observer],
          {#keyPath: keyPath},
        ),
        returnValue: _i6.Future<void>.value(),
        returnValueForMissingStub: _i6.Future<void>.value(),
      ) as _i6.Future<void>);
}

/// A class which mocks [UIScrollView].
///
/// See the documentation for Mockito's code generation for more information.
// ignore: must_be_immutable
class MockUIScrollView extends _i1.Mock implements _i4.UIScrollView {
  MockUIScrollView() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i6.Future<_i3.Point<double>> getContentOffset() => (super.noSuchMethod(
        Invocation.method(
          #getContentOffset,
          [],
        ),
        returnValue: _i6.Future<_i3.Point<double>>.value(_FakePoint_1<double>(
          this,
          Invocation.method(
            #getContentOffset,
            [],
          ),
        )),
      ) as _i6.Future<_i3.Point<double>>);

  @override
  _i6.Future<void> scrollBy(_i3.Point<double>? offset) => (super.noSuchMethod(
        Invocation.method(
          #scrollBy,
          [offset],
        ),
        returnValue: _i6.Future<void>.value(),
        returnValueForMissingStub: _i6.Future<void>.value(),
      ) as _i6.Future<void>);

  @override
  _i6.Future<void> setContentOffset(_i3.Point<double>? offset) =>
      (super.noSuchMethod(
        Invocation.method(
          #setContentOffset,
          [offset],
        ),
        returnValue: _i6.Future<void>.value(),
        returnValueForMissingStub: _i6.Future<void>.value(),
      ) as _i6.Future<void>);

  @override
  _i6.Future<void> setDelegate(_i4.UIScrollViewDelegate? delegate) =>
      (super.noSuchMethod(
        Invocation.method(
          #setDelegate,
          [delegate],
        ),
        returnValue: _i6.Future<void>.value(),
        returnValueForMissingStub: _i6.Future<void>.value(),
      ) as _i6.Future<void>);

  @override
  _i4.UIScrollView copy() => (super.noSuchMethod(
        Invocation.method(
          #copy,
          [],
        ),
        returnValue: _FakeUIScrollView_2(
          this,
          Invocation.method(
            #copy,
            [],
          ),
        ),
      ) as _i4.UIScrollView);

  @override
  _i6.Future<void> setBackgroundColor(_i7.Color? color) => (super.noSuchMethod(
        Invocation.method(
          #setBackgroundColor,
          [color],
        ),
        returnValue: _i6.Future<void>.value(),
        returnValueForMissingStub: _i6.Future<void>.value(),
      ) as _i6.Future<void>);

  @override
  _i6.Future<void> setOpaque(bool? opaque) => (super.noSuchMethod(
        Invocation.method(
          #setOpaque,
          [opaque],
        ),
        returnValue: _i6.Future<void>.value(),
        returnValueForMissingStub: _i6.Future<void>.value(),
      ) as _i6.Future<void>);

  @override
  _i6.Future<void> addObserver(
    _i2.NSObject? observer, {
    required String? keyPath,
    required Set<_i2.NSKeyValueObservingOptions>? options,
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
        returnValue: _i6.Future<void>.value(),
        returnValueForMissingStub: _i6.Future<void>.value(),
      ) as _i6.Future<void>);

  @override
  _i6.Future<void> removeObserver(
    _i2.NSObject? observer, {
    required String? keyPath,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #removeObserver,
          [observer],
          {#keyPath: keyPath},
        ),
        returnValue: _i6.Future<void>.value(),
        returnValueForMissingStub: _i6.Future<void>.value(),
      ) as _i6.Future<void>);
}

/// A class which mocks [UIScrollViewDelegate].
///
/// See the documentation for Mockito's code generation for more information.
// ignore: must_be_immutable
class MockUIScrollViewDelegate extends _i1.Mock
    implements _i4.UIScrollViewDelegate {
  MockUIScrollViewDelegate() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i4.UIScrollViewDelegate copy() => (super.noSuchMethod(
        Invocation.method(
          #copy,
          [],
        ),
        returnValue: _FakeUIScrollViewDelegate_3(
          this,
          Invocation.method(
            #copy,
            [],
          ),
        ),
      ) as _i4.UIScrollViewDelegate);

  @override
  _i6.Future<void> addObserver(
    _i2.NSObject? observer, {
    required String? keyPath,
    required Set<_i2.NSKeyValueObservingOptions>? options,
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
        returnValue: _i6.Future<void>.value(),
        returnValueForMissingStub: _i6.Future<void>.value(),
      ) as _i6.Future<void>);

  @override
  _i6.Future<void> removeObserver(
    _i2.NSObject? observer, {
    required String? keyPath,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #removeObserver,
          [observer],
          {#keyPath: keyPath},
        ),
        returnValue: _i6.Future<void>.value(),
        returnValueForMissingStub: _i6.Future<void>.value(),
      ) as _i6.Future<void>);
}

/// A class which mocks [WKPreferences].
///
/// See the documentation for Mockito's code generation for more information.
// ignore: must_be_immutable
class MockWKPreferences extends _i1.Mock implements _i5.WKPreferences {
  MockWKPreferences() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i6.Future<void> setJavaScriptEnabled(bool? enabled) => (super.noSuchMethod(
        Invocation.method(
          #setJavaScriptEnabled,
          [enabled],
        ),
        returnValue: _i6.Future<void>.value(),
        returnValueForMissingStub: _i6.Future<void>.value(),
      ) as _i6.Future<void>);

  @override
  _i5.WKPreferences copy() => (super.noSuchMethod(
        Invocation.method(
          #copy,
          [],
        ),
        returnValue: _FakeWKPreferences_4(
          this,
          Invocation.method(
            #copy,
            [],
          ),
        ),
      ) as _i5.WKPreferences);

  @override
  _i6.Future<void> addObserver(
    _i2.NSObject? observer, {
    required String? keyPath,
    required Set<_i2.NSKeyValueObservingOptions>? options,
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
        returnValue: _i6.Future<void>.value(),
        returnValueForMissingStub: _i6.Future<void>.value(),
      ) as _i6.Future<void>);

  @override
  _i6.Future<void> removeObserver(
    _i2.NSObject? observer, {
    required String? keyPath,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #removeObserver,
          [observer],
          {#keyPath: keyPath},
        ),
        returnValue: _i6.Future<void>.value(),
        returnValueForMissingStub: _i6.Future<void>.value(),
      ) as _i6.Future<void>);
}

/// A class which mocks [WKUserContentController].
///
/// See the documentation for Mockito's code generation for more information.
// ignore: must_be_immutable
class MockWKUserContentController extends _i1.Mock
    implements _i5.WKUserContentController {
  MockWKUserContentController() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i6.Future<void> addScriptMessageHandler(
    _i5.WKScriptMessageHandler? handler,
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
        returnValue: _i6.Future<void>.value(),
        returnValueForMissingStub: _i6.Future<void>.value(),
      ) as _i6.Future<void>);

  @override
  _i6.Future<void> removeScriptMessageHandler(String? name) =>
      (super.noSuchMethod(
        Invocation.method(
          #removeScriptMessageHandler,
          [name],
        ),
        returnValue: _i6.Future<void>.value(),
        returnValueForMissingStub: _i6.Future<void>.value(),
      ) as _i6.Future<void>);

  @override
  _i6.Future<void> removeAllScriptMessageHandlers() => (super.noSuchMethod(
        Invocation.method(
          #removeAllScriptMessageHandlers,
          [],
        ),
        returnValue: _i6.Future<void>.value(),
        returnValueForMissingStub: _i6.Future<void>.value(),
      ) as _i6.Future<void>);

  @override
  _i6.Future<void> addUserScript(_i5.WKUserScript? userScript) =>
      (super.noSuchMethod(
        Invocation.method(
          #addUserScript,
          [userScript],
        ),
        returnValue: _i6.Future<void>.value(),
        returnValueForMissingStub: _i6.Future<void>.value(),
      ) as _i6.Future<void>);

  @override
  _i6.Future<void> removeAllUserScripts() => (super.noSuchMethod(
        Invocation.method(
          #removeAllUserScripts,
          [],
        ),
        returnValue: _i6.Future<void>.value(),
        returnValueForMissingStub: _i6.Future<void>.value(),
      ) as _i6.Future<void>);

  @override
  _i5.WKUserContentController copy() => (super.noSuchMethod(
        Invocation.method(
          #copy,
          [],
        ),
        returnValue: _FakeWKUserContentController_5(
          this,
          Invocation.method(
            #copy,
            [],
          ),
        ),
      ) as _i5.WKUserContentController);

  @override
  _i6.Future<void> addObserver(
    _i2.NSObject? observer, {
    required String? keyPath,
    required Set<_i2.NSKeyValueObservingOptions>? options,
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
        returnValue: _i6.Future<void>.value(),
        returnValueForMissingStub: _i6.Future<void>.value(),
      ) as _i6.Future<void>);

  @override
  _i6.Future<void> removeObserver(
    _i2.NSObject? observer, {
    required String? keyPath,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #removeObserver,
          [observer],
          {#keyPath: keyPath},
        ),
        returnValue: _i6.Future<void>.value(),
        returnValueForMissingStub: _i6.Future<void>.value(),
      ) as _i6.Future<void>);
}

/// A class which mocks [WKWebsiteDataStore].
///
/// See the documentation for Mockito's code generation for more information.
// ignore: must_be_immutable
class MockWKWebsiteDataStore extends _i1.Mock
    implements _i5.WKWebsiteDataStore {
  MockWKWebsiteDataStore() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i5.WKHttpCookieStore get httpCookieStore => (super.noSuchMethod(
        Invocation.getter(#httpCookieStore),
        returnValue: _FakeWKHttpCookieStore_6(
          this,
          Invocation.getter(#httpCookieStore),
        ),
      ) as _i5.WKHttpCookieStore);

  @override
  _i6.Future<bool> removeDataOfTypes(
    Set<_i5.WKWebsiteDataType>? dataTypes,
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
        returnValue: _i6.Future<bool>.value(false),
      ) as _i6.Future<bool>);

  @override
  _i5.WKWebsiteDataStore copy() => (super.noSuchMethod(
        Invocation.method(
          #copy,
          [],
        ),
        returnValue: _FakeWKWebsiteDataStore_7(
          this,
          Invocation.method(
            #copy,
            [],
          ),
        ),
      ) as _i5.WKWebsiteDataStore);

  @override
  _i6.Future<void> addObserver(
    _i2.NSObject? observer, {
    required String? keyPath,
    required Set<_i2.NSKeyValueObservingOptions>? options,
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
        returnValue: _i6.Future<void>.value(),
        returnValueForMissingStub: _i6.Future<void>.value(),
      ) as _i6.Future<void>);

  @override
  _i6.Future<void> removeObserver(
    _i2.NSObject? observer, {
    required String? keyPath,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #removeObserver,
          [observer],
          {#keyPath: keyPath},
        ),
        returnValue: _i6.Future<void>.value(),
        returnValueForMissingStub: _i6.Future<void>.value(),
      ) as _i6.Future<void>);
}

/// A class which mocks [WKWebView].
///
/// See the documentation for Mockito's code generation for more information.
// ignore: must_be_immutable
class MockWKWebView extends _i1.Mock implements _i5.WKWebView {
  MockWKWebView() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i5.WKWebViewConfiguration get configuration => (super.noSuchMethod(
        Invocation.getter(#configuration),
        returnValue: _FakeWKWebViewConfiguration_8(
          this,
          Invocation.getter(#configuration),
        ),
      ) as _i5.WKWebViewConfiguration);

  @override
  _i4.UIScrollView get scrollView => (super.noSuchMethod(
        Invocation.getter(#scrollView),
        returnValue: _FakeUIScrollView_2(
          this,
          Invocation.getter(#scrollView),
        ),
      ) as _i4.UIScrollView);

  @override
  _i6.Future<void> setUIDelegate(_i5.WKUIDelegate? delegate) =>
      (super.noSuchMethod(
        Invocation.method(
          #setUIDelegate,
          [delegate],
        ),
        returnValue: _i6.Future<void>.value(),
        returnValueForMissingStub: _i6.Future<void>.value(),
      ) as _i6.Future<void>);

  @override
  _i6.Future<void> setNavigationDelegate(_i5.WKNavigationDelegate? delegate) =>
      (super.noSuchMethod(
        Invocation.method(
          #setNavigationDelegate,
          [delegate],
        ),
        returnValue: _i6.Future<void>.value(),
        returnValueForMissingStub: _i6.Future<void>.value(),
      ) as _i6.Future<void>);

  @override
  _i6.Future<String?> getUrl() => (super.noSuchMethod(
        Invocation.method(
          #getUrl,
          [],
        ),
        returnValue: _i6.Future<String?>.value(),
      ) as _i6.Future<String?>);

  @override
  _i6.Future<double> getEstimatedProgress() => (super.noSuchMethod(
        Invocation.method(
          #getEstimatedProgress,
          [],
        ),
        returnValue: _i6.Future<double>.value(0.0),
      ) as _i6.Future<double>);

  @override
  _i6.Future<void> loadRequest(_i2.NSUrlRequest? request) =>
      (super.noSuchMethod(
        Invocation.method(
          #loadRequest,
          [request],
        ),
        returnValue: _i6.Future<void>.value(),
        returnValueForMissingStub: _i6.Future<void>.value(),
      ) as _i6.Future<void>);

  @override
  _i6.Future<void> loadHtmlString(
    String? string, {
    String? baseUrl,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #loadHtmlString,
          [string],
          {#baseUrl: baseUrl},
        ),
        returnValue: _i6.Future<void>.value(),
        returnValueForMissingStub: _i6.Future<void>.value(),
      ) as _i6.Future<void>);

  @override
  _i6.Future<void> loadFileUrl(
    String? url, {
    required String? readAccessUrl,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #loadFileUrl,
          [url],
          {#readAccessUrl: readAccessUrl},
        ),
        returnValue: _i6.Future<void>.value(),
        returnValueForMissingStub: _i6.Future<void>.value(),
      ) as _i6.Future<void>);

  @override
  _i6.Future<void> loadFlutterAsset(String? key) => (super.noSuchMethod(
        Invocation.method(
          #loadFlutterAsset,
          [key],
        ),
        returnValue: _i6.Future<void>.value(),
        returnValueForMissingStub: _i6.Future<void>.value(),
      ) as _i6.Future<void>);

  @override
  _i6.Future<bool> canGoBack() => (super.noSuchMethod(
        Invocation.method(
          #canGoBack,
          [],
        ),
        returnValue: _i6.Future<bool>.value(false),
      ) as _i6.Future<bool>);

  @override
  _i6.Future<bool> canGoForward() => (super.noSuchMethod(
        Invocation.method(
          #canGoForward,
          [],
        ),
        returnValue: _i6.Future<bool>.value(false),
      ) as _i6.Future<bool>);

  @override
  _i6.Future<void> goBack() => (super.noSuchMethod(
        Invocation.method(
          #goBack,
          [],
        ),
        returnValue: _i6.Future<void>.value(),
        returnValueForMissingStub: _i6.Future<void>.value(),
      ) as _i6.Future<void>);

  @override
  _i6.Future<void> goForward() => (super.noSuchMethod(
        Invocation.method(
          #goForward,
          [],
        ),
        returnValue: _i6.Future<void>.value(),
        returnValueForMissingStub: _i6.Future<void>.value(),
      ) as _i6.Future<void>);

  @override
  _i6.Future<void> reload() => (super.noSuchMethod(
        Invocation.method(
          #reload,
          [],
        ),
        returnValue: _i6.Future<void>.value(),
        returnValueForMissingStub: _i6.Future<void>.value(),
      ) as _i6.Future<void>);

  @override
  _i6.Future<String?> getTitle() => (super.noSuchMethod(
        Invocation.method(
          #getTitle,
          [],
        ),
        returnValue: _i6.Future<String?>.value(),
      ) as _i6.Future<String?>);

  @override
  _i6.Future<void> setAllowsBackForwardNavigationGestures(bool? allow) =>
      (super.noSuchMethod(
        Invocation.method(
          #setAllowsBackForwardNavigationGestures,
          [allow],
        ),
        returnValue: _i6.Future<void>.value(),
        returnValueForMissingStub: _i6.Future<void>.value(),
      ) as _i6.Future<void>);

  @override
  _i6.Future<void> setCustomUserAgent(String? userAgent) => (super.noSuchMethod(
        Invocation.method(
          #setCustomUserAgent,
          [userAgent],
        ),
        returnValue: _i6.Future<void>.value(),
        returnValueForMissingStub: _i6.Future<void>.value(),
      ) as _i6.Future<void>);

  @override
  _i6.Future<Object?> evaluateJavaScript(String? javaScriptString) =>
      (super.noSuchMethod(
        Invocation.method(
          #evaluateJavaScript,
          [javaScriptString],
        ),
        returnValue: _i6.Future<Object?>.value(),
      ) as _i6.Future<Object?>);

  @override
  _i6.Future<void> setInspectable(bool? inspectable) => (super.noSuchMethod(
        Invocation.method(
          #setInspectable,
          [inspectable],
        ),
        returnValue: _i6.Future<void>.value(),
        returnValueForMissingStub: _i6.Future<void>.value(),
      ) as _i6.Future<void>);

  @override
  _i6.Future<String?> getCustomUserAgent() => (super.noSuchMethod(
        Invocation.method(
          #getCustomUserAgent,
          [],
        ),
        returnValue: _i6.Future<String?>.value(),
      ) as _i6.Future<String?>);

  @override
  _i5.WKWebView copy() => (super.noSuchMethod(
        Invocation.method(
          #copy,
          [],
        ),
        returnValue: _FakeWKWebView_9(
          this,
          Invocation.method(
            #copy,
            [],
          ),
        ),
      ) as _i5.WKWebView);

  @override
  _i6.Future<void> setBackgroundColor(_i7.Color? color) => (super.noSuchMethod(
        Invocation.method(
          #setBackgroundColor,
          [color],
        ),
        returnValue: _i6.Future<void>.value(),
        returnValueForMissingStub: _i6.Future<void>.value(),
      ) as _i6.Future<void>);

  @override
  _i6.Future<void> setOpaque(bool? opaque) => (super.noSuchMethod(
        Invocation.method(
          #setOpaque,
          [opaque],
        ),
        returnValue: _i6.Future<void>.value(),
        returnValueForMissingStub: _i6.Future<void>.value(),
      ) as _i6.Future<void>);

  @override
  _i6.Future<void> addObserver(
    _i2.NSObject? observer, {
    required String? keyPath,
    required Set<_i2.NSKeyValueObservingOptions>? options,
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
        returnValue: _i6.Future<void>.value(),
        returnValueForMissingStub: _i6.Future<void>.value(),
      ) as _i6.Future<void>);

  @override
  _i6.Future<void> removeObserver(
    _i2.NSObject? observer, {
    required String? keyPath,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #removeObserver,
          [observer],
          {#keyPath: keyPath},
        ),
        returnValue: _i6.Future<void>.value(),
        returnValueForMissingStub: _i6.Future<void>.value(),
      ) as _i6.Future<void>);
}

/// A class which mocks [WKWebViewConfiguration].
///
/// See the documentation for Mockito's code generation for more information.
// ignore: must_be_immutable
class MockWKWebViewConfiguration extends _i1.Mock
    implements _i5.WKWebViewConfiguration {
  MockWKWebViewConfiguration() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i5.WKUserContentController get userContentController => (super.noSuchMethod(
        Invocation.getter(#userContentController),
        returnValue: _FakeWKUserContentController_5(
          this,
          Invocation.getter(#userContentController),
        ),
      ) as _i5.WKUserContentController);

  @override
  _i5.WKPreferences get preferences => (super.noSuchMethod(
        Invocation.getter(#preferences),
        returnValue: _FakeWKPreferences_4(
          this,
          Invocation.getter(#preferences),
        ),
      ) as _i5.WKPreferences);

  @override
  _i5.WKWebsiteDataStore get websiteDataStore => (super.noSuchMethod(
        Invocation.getter(#websiteDataStore),
        returnValue: _FakeWKWebsiteDataStore_7(
          this,
          Invocation.getter(#websiteDataStore),
        ),
      ) as _i5.WKWebsiteDataStore);

  @override
  _i6.Future<void> setAllowsInlineMediaPlayback(bool? allow) =>
      (super.noSuchMethod(
        Invocation.method(
          #setAllowsInlineMediaPlayback,
          [allow],
        ),
        returnValue: _i6.Future<void>.value(),
        returnValueForMissingStub: _i6.Future<void>.value(),
      ) as _i6.Future<void>);

  @override
  _i6.Future<void> setLimitsNavigationsToAppBoundDomains(bool? limit) =>
      (super.noSuchMethod(
        Invocation.method(
          #setLimitsNavigationsToAppBoundDomains,
          [limit],
        ),
        returnValue: _i6.Future<void>.value(),
        returnValueForMissingStub: _i6.Future<void>.value(),
      ) as _i6.Future<void>);

  @override
  _i6.Future<void> setMediaTypesRequiringUserActionForPlayback(
          Set<_i5.WKAudiovisualMediaType>? types) =>
      (super.noSuchMethod(
        Invocation.method(
          #setMediaTypesRequiringUserActionForPlayback,
          [types],
        ),
        returnValue: _i6.Future<void>.value(),
        returnValueForMissingStub: _i6.Future<void>.value(),
      ) as _i6.Future<void>);

  @override
  _i5.WKWebViewConfiguration copy() => (super.noSuchMethod(
        Invocation.method(
          #copy,
          [],
        ),
        returnValue: _FakeWKWebViewConfiguration_8(
          this,
          Invocation.method(
            #copy,
            [],
          ),
        ),
      ) as _i5.WKWebViewConfiguration);

  @override
  _i6.Future<void> addObserver(
    _i2.NSObject? observer, {
    required String? keyPath,
    required Set<_i2.NSKeyValueObservingOptions>? options,
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
        returnValue: _i6.Future<void>.value(),
        returnValueForMissingStub: _i6.Future<void>.value(),
      ) as _i6.Future<void>);

  @override
  _i6.Future<void> removeObserver(
    _i2.NSObject? observer, {
    required String? keyPath,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #removeObserver,
          [observer],
          {#keyPath: keyPath},
        ),
        returnValue: _i6.Future<void>.value(),
        returnValueForMissingStub: _i6.Future<void>.value(),
      ) as _i6.Future<void>);
}

/// A class which mocks [WKScriptMessageHandler].
///
/// See the documentation for Mockito's code generation for more information.
// ignore: must_be_immutable
class MockWKScriptMessageHandler extends _i1.Mock
    implements _i5.WKScriptMessageHandler {
  MockWKScriptMessageHandler() {
    _i1.throwOnMissingStub(this);
  }

  @override
  void Function(
    _i5.WKUserContentController,
    _i5.WKScriptMessage,
  ) get didReceiveScriptMessage => (super.noSuchMethod(
        Invocation.getter(#didReceiveScriptMessage),
        returnValue: (
          _i5.WKUserContentController userContentController,
          _i5.WKScriptMessage message,
        ) {},
      ) as void Function(
        _i5.WKUserContentController,
        _i5.WKScriptMessage,
      ));

  @override
  _i5.WKScriptMessageHandler copy() => (super.noSuchMethod(
        Invocation.method(
          #copy,
          [],
        ),
        returnValue: _FakeWKScriptMessageHandler_10(
          this,
          Invocation.method(
            #copy,
            [],
          ),
        ),
      ) as _i5.WKScriptMessageHandler);

  @override
  _i6.Future<void> addObserver(
    _i2.NSObject? observer, {
    required String? keyPath,
    required Set<_i2.NSKeyValueObservingOptions>? options,
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
        returnValue: _i6.Future<void>.value(),
        returnValueForMissingStub: _i6.Future<void>.value(),
      ) as _i6.Future<void>);

  @override
  _i6.Future<void> removeObserver(
    _i2.NSObject? observer, {
    required String? keyPath,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #removeObserver,
          [observer],
          {#keyPath: keyPath},
        ),
        returnValue: _i6.Future<void>.value(),
        returnValueForMissingStub: _i6.Future<void>.value(),
      ) as _i6.Future<void>);
}
