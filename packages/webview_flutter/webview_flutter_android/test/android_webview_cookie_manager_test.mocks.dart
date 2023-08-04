// Mocks generated by Mockito 5.4.1 from annotations
// in webview_flutter_android/test/android_webview_cookie_manager_test.dart.
// Do not manually edit this file.

// @dart=2.19

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i5;
import 'dart:ui' as _i4;

import 'package:mockito/mockito.dart' as _i1;
import 'package:webview_flutter_android/src/android_webview.dart' as _i2;
import 'package:webview_flutter_android/src/android_webview_controller.dart'
    as _i6;
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart'
    as _i3;

import 'test_android_webview.g.dart' as _i7;

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

class _FakeCookieManager_0 extends _i1.SmartFake implements _i2.CookieManager {
  _FakeCookieManager_0(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakePlatformWebViewControllerCreationParams_1 extends _i1.SmartFake
    implements _i3.PlatformWebViewControllerCreationParams {
  _FakePlatformWebViewControllerCreationParams_1(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeObject_2 extends _i1.SmartFake implements Object {
  _FakeObject_2(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeOffset_3 extends _i1.SmartFake implements _i4.Offset {
  _FakeOffset_3(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

/// A class which mocks [CookieManager].
///
/// See the documentation for Mockito's code generation for more information.
class MockCookieManager extends _i1.Mock implements _i2.CookieManager {
  MockCookieManager() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i5.Future<void> setCookie(
    String? url,
    String? value,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #setCookie,
          [
            url,
            value,
          ],
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);
  @override
  _i5.Future<bool> removeAllCookies() => (super.noSuchMethod(
        Invocation.method(
          #removeAllCookies,
          [],
        ),
        returnValue: _i5.Future<bool>.value(false),
      ) as _i5.Future<bool>);
  @override
  _i5.Future<void> setAcceptThirdPartyCookies(
    _i2.WebView? webView,
    bool? accept,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #setAcceptThirdPartyCookies,
          [
            webView,
            accept,
          ],
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);
  @override
  _i2.CookieManager copy() => (super.noSuchMethod(
        Invocation.method(
          #copy,
          [],
        ),
        returnValue: _FakeCookieManager_0(
          this,
          Invocation.method(
            #copy,
            [],
          ),
        ),
      ) as _i2.CookieManager);
}

/// A class which mocks [AndroidWebViewController].
///
/// See the documentation for Mockito's code generation for more information.
class MockAndroidWebViewController extends _i1.Mock
    implements _i6.AndroidWebViewController {
  MockAndroidWebViewController() {
    _i1.throwOnMissingStub(this);
  }

  @override
  int get webViewIdentifier => (super.noSuchMethod(
        Invocation.getter(#webViewIdentifier),
        returnValue: 0,
      ) as int);
  @override
  _i3.PlatformWebViewControllerCreationParams get params => (super.noSuchMethod(
        Invocation.getter(#params),
        returnValue: _FakePlatformWebViewControllerCreationParams_1(
          this,
          Invocation.getter(#params),
        ),
      ) as _i3.PlatformWebViewControllerCreationParams);
  @override
  _i5.Future<void> loadFile(String? absoluteFilePath) => (super.noSuchMethod(
        Invocation.method(
          #loadFile,
          [absoluteFilePath],
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
  _i5.Future<void> loadHtmlString(
    String? html, {
    String? baseUrl,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #loadHtmlString,
          [html],
          {#baseUrl: baseUrl},
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);
  @override
  _i5.Future<void> loadRequest(_i3.LoadRequestParams? params) =>
      (super.noSuchMethod(
        Invocation.method(
          #loadRequest,
          [params],
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);
  @override
  _i5.Future<String?> currentUrl() => (super.noSuchMethod(
        Invocation.method(
          #currentUrl,
          [],
        ),
        returnValue: _i5.Future<String?>.value(),
      ) as _i5.Future<String?>);
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
  _i5.Future<void> clearCache() => (super.noSuchMethod(
        Invocation.method(
          #clearCache,
          [],
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);
  @override
  _i5.Future<void> clearLocalStorage() => (super.noSuchMethod(
        Invocation.method(
          #clearLocalStorage,
          [],
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);
  @override
  _i5.Future<void> setPlatformNavigationDelegate(
          _i3.PlatformNavigationDelegate? handler) =>
      (super.noSuchMethod(
        Invocation.method(
          #setPlatformNavigationDelegate,
          [handler],
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);
  @override
  _i5.Future<void> runJavaScript(String? javaScript) => (super.noSuchMethod(
        Invocation.method(
          #runJavaScript,
          [javaScript],
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);
  @override
  _i5.Future<Object> runJavaScriptReturningResult(String? javaScript) =>
      (super.noSuchMethod(
        Invocation.method(
          #runJavaScriptReturningResult,
          [javaScript],
        ),
        returnValue: _i5.Future<Object>.value(_FakeObject_2(
          this,
          Invocation.method(
            #runJavaScriptReturningResult,
            [javaScript],
          ),
        )),
      ) as _i5.Future<Object>);
  @override
  _i5.Future<void> addJavaScriptChannel(
          _i3.JavaScriptChannelParams? javaScriptChannelParams) =>
      (super.noSuchMethod(
        Invocation.method(
          #addJavaScriptChannel,
          [javaScriptChannelParams],
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);
  @override
  _i5.Future<void> removeJavaScriptChannel(String? javaScriptChannelName) =>
      (super.noSuchMethod(
        Invocation.method(
          #removeJavaScriptChannel,
          [javaScriptChannelName],
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
  _i5.Future<void> scrollTo(
    int? x,
    int? y,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #scrollTo,
          [
            x,
            y,
          ],
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);
  @override
  _i5.Future<void> scrollBy(
    int? x,
    int? y,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #scrollBy,
          [
            x,
            y,
          ],
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);
  @override
  _i5.Future<_i4.Offset> getScrollPosition() => (super.noSuchMethod(
        Invocation.method(
          #getScrollPosition,
          [],
        ),
        returnValue: _i5.Future<_i4.Offset>.value(_FakeOffset_3(
          this,
          Invocation.method(
            #getScrollPosition,
            [],
          ),
        )),
      ) as _i5.Future<_i4.Offset>);
  @override
  _i5.Future<void> enableZoom(bool? enabled) => (super.noSuchMethod(
        Invocation.method(
          #enableZoom,
          [enabled],
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);
  @override
  _i5.Future<void> setBackgroundColor(_i4.Color? color) => (super.noSuchMethod(
        Invocation.method(
          #setBackgroundColor,
          [color],
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);
  @override
  _i5.Future<void> setJavaScriptMode(_i3.JavaScriptMode? javaScriptMode) =>
      (super.noSuchMethod(
        Invocation.method(
          #setJavaScriptMode,
          [javaScriptMode],
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);
  @override
  _i5.Future<void> setUserAgent(String? userAgent) => (super.noSuchMethod(
        Invocation.method(
          #setUserAgent,
          [userAgent],
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);
  @override
  _i5.Future<void> setMediaPlaybackRequiresUserGesture(bool? require) =>
      (super.noSuchMethod(
        Invocation.method(
          #setMediaPlaybackRequiresUserGesture,
          [require],
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);
  @override
  _i5.Future<void> setTextZoom(int? textZoom) => (super.noSuchMethod(
        Invocation.method(
          #setTextZoom,
          [textZoom],
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);
  @override
  _i5.Future<void> setOnShowFileSelector(
          _i5.Future<List<String>> Function(_i6.FileSelectorParams)?
              onShowFileSelector) =>
      (super.noSuchMethod(
        Invocation.method(
          #setOnShowFileSelector,
          [onShowFileSelector],
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);
  @override
  _i5.Future<void> setOnPlatformPermissionRequest(
          void Function(_i3.PlatformWebViewPermissionRequest)?
              onPermissionRequest) =>
      (super.noSuchMethod(
        Invocation.method(
          #setOnPlatformPermissionRequest,
          [onPermissionRequest],
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);
  @override
  _i5.Future<void> setGeolocationPermissionsPromptCallbacks({
    _i6.OnGeolocationPermissionsShowPrompt? onShowPrompt,
    _i6.OnGeolocationPermissionsHidePrompt? onHidePrompt,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #setGeolocationPermissionsPromptCallbacks,
          [],
          {
            #onShowPrompt: onShowPrompt,
            #onHidePrompt: onHidePrompt,
          },
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);
  @override
  _i5.Future<void> setOnConsoleMessage(
          void Function(_i3.JavaScriptConsoleMessage)? onConsoleMessage) =>
      (super.noSuchMethod(
        Invocation.method(
          #setOnConsoleMessage,
          [onConsoleMessage],
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);
}

/// A class which mocks [TestInstanceManagerHostApi].
///
/// See the documentation for Mockito's code generation for more information.
class MockTestInstanceManagerHostApi extends _i1.Mock
    implements _i7.TestInstanceManagerHostApi {
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
