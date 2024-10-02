// Mocks generated by Mockito 5.4.4 from annotations
// in webview_flutter_android/test/legacy/webview_android_widget_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i4;
import 'dart:typed_data' as _i6;

import 'package:mockito/mockito.dart' as _i1;
import 'package:mockito/src/dummies.dart' as _i5;
import 'package:webview_flutter_android/src/android_webkit.g.dart' as _i2;
import 'package:webview_flutter_android/src/legacy/webview_android_widget.dart'
    as _i7;
import 'package:webview_flutter_platform_interface/src/webview_flutter_platform_interface_legacy.dart'
    as _i3;

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

class _FakeFlutterAssetManager_1 extends _i1.SmartFake
    implements _i2.FlutterAssetManager {
  _FakeFlutterAssetManager_1(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeWebSettings_2 extends _i1.SmartFake implements _i2.WebSettings {
  _FakeWebSettings_2(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeWebStorage_3 extends _i1.SmartFake implements _i2.WebStorage {
  _FakeWebStorage_3(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeWebView_4 extends _i1.SmartFake implements _i2.WebView {
  _FakeWebView_4(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeWebViewPoint_5 extends _i1.SmartFake implements _i2.WebViewPoint {
  _FakeWebViewPoint_5(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeWebResourceRequest_6 extends _i1.SmartFake
    implements _i2.WebResourceRequest {
  _FakeWebResourceRequest_6(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeDownloadListener_7 extends _i1.SmartFake
    implements _i2.DownloadListener {
  _FakeDownloadListener_7(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeJavascriptChannelRegistry_8 extends _i1.SmartFake
    implements _i3.JavascriptChannelRegistry {
  _FakeJavascriptChannelRegistry_8(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeJavaScriptChannel_9 extends _i1.SmartFake
    implements _i2.JavaScriptChannel {
  _FakeJavaScriptChannel_9(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeWebChromeClient_10 extends _i1.SmartFake
    implements _i2.WebChromeClient {
  _FakeWebChromeClient_10(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeWebViewClient_11 extends _i1.SmartFake implements _i2.WebViewClient {
  _FakeWebViewClient_11(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

/// A class which mocks [FlutterAssetManager].
///
/// See the documentation for Mockito's code generation for more information.
class MockFlutterAssetManager extends _i1.Mock
    implements _i2.FlutterAssetManager {
  MockFlutterAssetManager() {
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
  _i4.Future<List<String>> list(String? path) => (super.noSuchMethod(
        Invocation.method(
          #list,
          [path],
        ),
        returnValue: _i4.Future<List<String>>.value(<String>[]),
      ) as _i4.Future<List<String>>);

  @override
  _i4.Future<String> getAssetFilePathByName(String? name) =>
      (super.noSuchMethod(
        Invocation.method(
          #getAssetFilePathByName,
          [name],
        ),
        returnValue: _i4.Future<String>.value(_i5.dummyValue<String>(
          this,
          Invocation.method(
            #getAssetFilePathByName,
            [name],
          ),
        )),
      ) as _i4.Future<String>);

  @override
  _i2.FlutterAssetManager pigeon_copy() => (super.noSuchMethod(
        Invocation.method(
          #pigeon_copy,
          [],
        ),
        returnValue: _FakeFlutterAssetManager_1(
          this,
          Invocation.method(
            #pigeon_copy,
            [],
          ),
        ),
      ) as _i2.FlutterAssetManager);
}

/// A class which mocks [WebSettings].
///
/// See the documentation for Mockito's code generation for more information.
class MockWebSettings extends _i1.Mock implements _i2.WebSettings {
  MockWebSettings() {
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
  _i4.Future<void> setDomStorageEnabled(bool? flag) => (super.noSuchMethod(
        Invocation.method(
          #setDomStorageEnabled,
          [flag],
        ),
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);

  @override
  _i4.Future<void> setJavaScriptCanOpenWindowsAutomatically(bool? flag) =>
      (super.noSuchMethod(
        Invocation.method(
          #setJavaScriptCanOpenWindowsAutomatically,
          [flag],
        ),
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);

  @override
  _i4.Future<void> setSupportMultipleWindows(bool? support) =>
      (super.noSuchMethod(
        Invocation.method(
          #setSupportMultipleWindows,
          [support],
        ),
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);

  @override
  _i4.Future<void> setJavaScriptEnabled(bool? flag) => (super.noSuchMethod(
        Invocation.method(
          #setJavaScriptEnabled,
          [flag],
        ),
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);

  @override
  _i4.Future<void> setUserAgentString(String? userAgentString) =>
      (super.noSuchMethod(
        Invocation.method(
          #setUserAgentString,
          [userAgentString],
        ),
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);

  @override
  _i4.Future<void> setMediaPlaybackRequiresUserGesture(bool? require) =>
      (super.noSuchMethod(
        Invocation.method(
          #setMediaPlaybackRequiresUserGesture,
          [require],
        ),
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);

  @override
  _i4.Future<void> setSupportZoom(bool? support) => (super.noSuchMethod(
        Invocation.method(
          #setSupportZoom,
          [support],
        ),
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);

  @override
  _i4.Future<void> setLoadWithOverviewMode(bool? overview) =>
      (super.noSuchMethod(
        Invocation.method(
          #setLoadWithOverviewMode,
          [overview],
        ),
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);

  @override
  _i4.Future<void> setUseWideViewPort(bool? use) => (super.noSuchMethod(
        Invocation.method(
          #setUseWideViewPort,
          [use],
        ),
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);

  @override
  _i4.Future<void> setDisplayZoomControls(bool? enabled) => (super.noSuchMethod(
        Invocation.method(
          #setDisplayZoomControls,
          [enabled],
        ),
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);

  @override
  _i4.Future<void> setBuiltInZoomControls(bool? enabled) => (super.noSuchMethod(
        Invocation.method(
          #setBuiltInZoomControls,
          [enabled],
        ),
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);

  @override
  _i4.Future<void> setAllowFileAccess(bool? enabled) => (super.noSuchMethod(
        Invocation.method(
          #setAllowFileAccess,
          [enabled],
        ),
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);

  @override
  _i4.Future<void> setTextZoom(int? textZoom) => (super.noSuchMethod(
        Invocation.method(
          #setTextZoom,
          [textZoom],
        ),
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);

  @override
  _i4.Future<String> getUserAgentString() => (super.noSuchMethod(
        Invocation.method(
          #getUserAgentString,
          [],
        ),
        returnValue: _i4.Future<String>.value(_i5.dummyValue<String>(
          this,
          Invocation.method(
            #getUserAgentString,
            [],
          ),
        )),
      ) as _i4.Future<String>);

  @override
  _i2.WebSettings pigeon_copy() => (super.noSuchMethod(
        Invocation.method(
          #pigeon_copy,
          [],
        ),
        returnValue: _FakeWebSettings_2(
          this,
          Invocation.method(
            #pigeon_copy,
            [],
          ),
        ),
      ) as _i2.WebSettings);
}

/// A class which mocks [WebStorage].
///
/// See the documentation for Mockito's code generation for more information.
class MockWebStorage extends _i1.Mock implements _i2.WebStorage {
  MockWebStorage() {
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
  _i4.Future<void> deleteAllData() => (super.noSuchMethod(
        Invocation.method(
          #deleteAllData,
          [],
        ),
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);

  @override
  _i2.WebStorage pigeon_copy() => (super.noSuchMethod(
        Invocation.method(
          #pigeon_copy,
          [],
        ),
        returnValue: _FakeWebStorage_3(
          this,
          Invocation.method(
            #pigeon_copy,
            [],
          ),
        ),
      ) as _i2.WebStorage);
}

/// A class which mocks [WebView].
///
/// See the documentation for Mockito's code generation for more information.
class MockWebView extends _i1.Mock implements _i2.WebView {
  MockWebView() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i2.WebSettings get settings => (super.noSuchMethod(
        Invocation.getter(#settings),
        returnValue: _FakeWebSettings_2(
          this,
          Invocation.getter(#settings),
        ),
      ) as _i2.WebSettings);

  @override
  _i2.PigeonInstanceManager get pigeon_instanceManager => (super.noSuchMethod(
        Invocation.getter(#pigeon_instanceManager),
        returnValue: _FakePigeonInstanceManager_0(
          this,
          Invocation.getter(#pigeon_instanceManager),
        ),
      ) as _i2.PigeonInstanceManager);

  @override
  _i2.WebSettings pigeonVar_settings() => (super.noSuchMethod(
        Invocation.method(
          #pigeonVar_settings,
          [],
        ),
        returnValue: _FakeWebSettings_2(
          this,
          Invocation.method(
            #pigeonVar_settings,
            [],
          ),
        ),
      ) as _i2.WebSettings);

  @override
  _i4.Future<void> loadData(
    String? data,
    String? mimeType,
    String? encoding,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #loadData,
          [
            data,
            mimeType,
            encoding,
          ],
        ),
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);

  @override
  _i4.Future<void> loadDataWithBaseUrl(
    String? baseUrl,
    String? data,
    String? mimeType,
    String? encoding,
    String? historyUrl,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #loadDataWithBaseUrl,
          [
            baseUrl,
            data,
            mimeType,
            encoding,
            historyUrl,
          ],
        ),
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);

  @override
  _i4.Future<void> loadUrl(
    String? url,
    Map<String, String>? headers,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #loadUrl,
          [
            url,
            headers,
          ],
        ),
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);

  @override
  _i4.Future<void> postUrl(
    String? url,
    _i6.Uint8List? data,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #postUrl,
          [
            url,
            data,
          ],
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
  _i4.Future<void> clearCache(bool? includeDiskFiles) => (super.noSuchMethod(
        Invocation.method(
          #clearCache,
          [includeDiskFiles],
        ),
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);

  @override
  _i4.Future<String?> evaluateJavascript(String? javascriptString) =>
      (super.noSuchMethod(
        Invocation.method(
          #evaluateJavascript,
          [javascriptString],
        ),
        returnValue: _i4.Future<String?>.value(),
      ) as _i4.Future<String?>);

  @override
  _i4.Future<String?> getTitle() => (super.noSuchMethod(
        Invocation.method(
          #getTitle,
          [],
        ),
        returnValue: _i4.Future<String?>.value(),
      ) as _i4.Future<String?>);

  @override
  _i4.Future<void> setWebViewClient(_i2.WebViewClient? client) =>
      (super.noSuchMethod(
        Invocation.method(
          #setWebViewClient,
          [client],
        ),
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);

  @override
  _i4.Future<void> addJavaScriptChannel(_i2.JavaScriptChannel? channel) =>
      (super.noSuchMethod(
        Invocation.method(
          #addJavaScriptChannel,
          [channel],
        ),
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);

  @override
  _i4.Future<void> removeJavaScriptChannel(String? name) => (super.noSuchMethod(
        Invocation.method(
          #removeJavaScriptChannel,
          [name],
        ),
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);

  @override
  _i4.Future<void> setDownloadListener(_i2.DownloadListener? listener) =>
      (super.noSuchMethod(
        Invocation.method(
          #setDownloadListener,
          [listener],
        ),
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);

  @override
  _i4.Future<void> setWebChromeClient(_i2.WebChromeClient? client) =>
      (super.noSuchMethod(
        Invocation.method(
          #setWebChromeClient,
          [client],
        ),
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);

  @override
  _i4.Future<void> setBackgroundColor(int? color) => (super.noSuchMethod(
        Invocation.method(
          #setBackgroundColor,
          [color],
        ),
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);

  @override
  _i4.Future<void> destroy() => (super.noSuchMethod(
        Invocation.method(
          #destroy,
          [],
        ),
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);

  @override
  _i2.WebView pigeon_copy() => (super.noSuchMethod(
        Invocation.method(
          #pigeon_copy,
          [],
        ),
        returnValue: _FakeWebView_4(
          this,
          Invocation.method(
            #pigeon_copy,
            [],
          ),
        ),
      ) as _i2.WebView);

  @override
  _i4.Future<void> scrollTo(
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
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);

  @override
  _i4.Future<void> scrollBy(
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
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);

  @override
  _i4.Future<_i2.WebViewPoint> getScrollPosition() => (super.noSuchMethod(
        Invocation.method(
          #getScrollPosition,
          [],
        ),
        returnValue: _i4.Future<_i2.WebViewPoint>.value(_FakeWebViewPoint_5(
          this,
          Invocation.method(
            #getScrollPosition,
            [],
          ),
        )),
      ) as _i4.Future<_i2.WebViewPoint>);
}

/// A class which mocks [WebResourceRequest].
///
/// See the documentation for Mockito's code generation for more information.
class MockWebResourceRequest extends _i1.Mock
    implements _i2.WebResourceRequest {
  MockWebResourceRequest() {
    _i1.throwOnMissingStub(this);
  }

  @override
  String get url => (super.noSuchMethod(
        Invocation.getter(#url),
        returnValue: _i5.dummyValue<String>(
          this,
          Invocation.getter(#url),
        ),
      ) as String);

  @override
  bool get isForMainFrame => (super.noSuchMethod(
        Invocation.getter(#isForMainFrame),
        returnValue: false,
      ) as bool);

  @override
  bool get hasGesture => (super.noSuchMethod(
        Invocation.getter(#hasGesture),
        returnValue: false,
      ) as bool);

  @override
  String get method => (super.noSuchMethod(
        Invocation.getter(#method),
        returnValue: _i5.dummyValue<String>(
          this,
          Invocation.getter(#method),
        ),
      ) as String);

  @override
  _i2.PigeonInstanceManager get pigeon_instanceManager => (super.noSuchMethod(
        Invocation.getter(#pigeon_instanceManager),
        returnValue: _FakePigeonInstanceManager_0(
          this,
          Invocation.getter(#pigeon_instanceManager),
        ),
      ) as _i2.PigeonInstanceManager);

  @override
  _i2.WebResourceRequest pigeon_copy() => (super.noSuchMethod(
        Invocation.method(
          #pigeon_copy,
          [],
        ),
        returnValue: _FakeWebResourceRequest_6(
          this,
          Invocation.method(
            #pigeon_copy,
            [],
          ),
        ),
      ) as _i2.WebResourceRequest);
}

/// A class which mocks [DownloadListener].
///
/// See the documentation for Mockito's code generation for more information.
class MockDownloadListener extends _i1.Mock implements _i2.DownloadListener {
  MockDownloadListener() {
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
  _i2.DownloadListener pigeon_copy() => (super.noSuchMethod(
        Invocation.method(
          #pigeon_copy,
          [],
        ),
        returnValue: _FakeDownloadListener_7(
          this,
          Invocation.method(
            #pigeon_copy,
            [],
          ),
        ),
      ) as _i2.DownloadListener);
}

/// A class which mocks [WebViewAndroidJavaScriptChannel].
///
/// See the documentation for Mockito's code generation for more information.
class MockWebViewAndroidJavaScriptChannel extends _i1.Mock
    implements _i7.WebViewAndroidJavaScriptChannel {
  MockWebViewAndroidJavaScriptChannel() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i3.JavascriptChannelRegistry get javascriptChannelRegistry =>
      (super.noSuchMethod(
        Invocation.getter(#javascriptChannelRegistry),
        returnValue: _FakeJavascriptChannelRegistry_8(
          this,
          Invocation.getter(#javascriptChannelRegistry),
        ),
      ) as _i3.JavascriptChannelRegistry);

  @override
  void Function(
    _i2.JavaScriptChannel,
    String,
  ) get postMessage => (super.noSuchMethod(
        Invocation.getter(#postMessage),
        returnValue: (
          _i2.JavaScriptChannel pigeon_instance,
          String message,
        ) {},
      ) as void Function(
        _i2.JavaScriptChannel,
        String,
      ));

  @override
  _i2.PigeonInstanceManager get pigeon_instanceManager => (super.noSuchMethod(
        Invocation.getter(#pigeon_instanceManager),
        returnValue: _FakePigeonInstanceManager_0(
          this,
          Invocation.getter(#pigeon_instanceManager),
        ),
      ) as _i2.PigeonInstanceManager);

  @override
  _i2.JavaScriptChannel pigeon_copy() => (super.noSuchMethod(
        Invocation.method(
          #pigeon_copy,
          [],
        ),
        returnValue: _FakeJavaScriptChannel_9(
          this,
          Invocation.method(
            #pigeon_copy,
            [],
          ),
        ),
      ) as _i2.JavaScriptChannel);
}

/// A class which mocks [WebChromeClient].
///
/// See the documentation for Mockito's code generation for more information.
class MockWebChromeClient extends _i1.Mock implements _i2.WebChromeClient {
  MockWebChromeClient() {
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
  _i4.Future<void> setSynchronousReturnValueForOnShowFileChooser(bool? value) =>
      (super.noSuchMethod(
        Invocation.method(
          #setSynchronousReturnValueForOnShowFileChooser,
          [value],
        ),
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);

  @override
  _i4.Future<void> setSynchronousReturnValueForOnConsoleMessage(bool? value) =>
      (super.noSuchMethod(
        Invocation.method(
          #setSynchronousReturnValueForOnConsoleMessage,
          [value],
        ),
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);

  @override
  _i4.Future<void> setSynchronousReturnValueForOnJsAlert(bool? value) =>
      (super.noSuchMethod(
        Invocation.method(
          #setSynchronousReturnValueForOnJsAlert,
          [value],
        ),
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);

  @override
  _i4.Future<void> setSynchronousReturnValueForOnJsConfirm(bool? value) =>
      (super.noSuchMethod(
        Invocation.method(
          #setSynchronousReturnValueForOnJsConfirm,
          [value],
        ),
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);

  @override
  _i4.Future<void> setSynchronousReturnValueForOnJsPrompt(bool? value) =>
      (super.noSuchMethod(
        Invocation.method(
          #setSynchronousReturnValueForOnJsPrompt,
          [value],
        ),
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);

  @override
  _i2.WebChromeClient pigeon_copy() => (super.noSuchMethod(
        Invocation.method(
          #pigeon_copy,
          [],
        ),
        returnValue: _FakeWebChromeClient_10(
          this,
          Invocation.method(
            #pigeon_copy,
            [],
          ),
        ),
      ) as _i2.WebChromeClient);
}

/// A class which mocks [WebViewClient].
///
/// See the documentation for Mockito's code generation for more information.
class MockWebViewClient extends _i1.Mock implements _i2.WebViewClient {
  MockWebViewClient() {
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
  _i4.Future<void> setSynchronousReturnValueForShouldOverrideUrlLoading(
          bool? value) =>
      (super.noSuchMethod(
        Invocation.method(
          #setSynchronousReturnValueForShouldOverrideUrlLoading,
          [value],
        ),
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);

  @override
  _i2.WebViewClient pigeon_copy() => (super.noSuchMethod(
        Invocation.method(
          #pigeon_copy,
          [],
        ),
        returnValue: _FakeWebViewClient_11(
          this,
          Invocation.method(
            #pigeon_copy,
            [],
          ),
        ),
      ) as _i2.WebViewClient);
}

/// A class which mocks [JavascriptChannelRegistry].
///
/// See the documentation for Mockito's code generation for more information.
class MockJavascriptChannelRegistry extends _i1.Mock
    implements _i3.JavascriptChannelRegistry {
  MockJavascriptChannelRegistry() {
    _i1.throwOnMissingStub(this);
  }

  @override
  Map<String, _i3.JavascriptChannel> get channels => (super.noSuchMethod(
        Invocation.getter(#channels),
        returnValue: <String, _i3.JavascriptChannel>{},
      ) as Map<String, _i3.JavascriptChannel>);

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
  void updateJavascriptChannelsFromSet(Set<_i3.JavascriptChannel>? channels) =>
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
    implements _i3.WebViewPlatformCallbacksHandler {
  MockWebViewPlatformCallbacksHandler() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i4.FutureOr<bool> onNavigationRequest({
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
        returnValue: _i4.Future<bool>.value(false),
      ) as _i4.FutureOr<bool>);

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
  void onWebResourceError(_i3.WebResourceError? error) => super.noSuchMethod(
        Invocation.method(
          #onWebResourceError,
          [error],
        ),
        returnValueForMissingStub: null,
      );
}

/// A class which mocks [WebViewProxy].
///
/// See the documentation for Mockito's code generation for more information.
class MockWebViewProxy extends _i1.Mock implements _i7.WebViewProxy {
  MockWebViewProxy() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i2.WebView createWebView() => (super.noSuchMethod(
        Invocation.method(
          #createWebView,
          [],
        ),
        returnValue: _FakeWebView_4(
          this,
          Invocation.method(
            #createWebView,
            [],
          ),
        ),
      ) as _i2.WebView);

  @override
  _i2.WebViewClient createWebViewClient({
    void Function(
      _i2.WebViewClient,
      _i2.WebView,
      String,
    )? onPageStarted,
    void Function(
      _i2.WebViewClient,
      _i2.WebView,
      String,
    )? onPageFinished,
    void Function(
      _i2.WebViewClient,
      _i2.WebView,
      _i2.WebResourceRequest,
      _i2.WebResourceError,
    )? onReceivedRequestError,
    void Function(
      _i2.WebViewClient,
      _i2.WebView,
      int,
      String,
      String,
    )? onReceivedError,
    void Function(
      _i2.WebViewClient,
      _i2.WebView,
      _i2.WebResourceRequest,
    )? requestLoading,
    void Function(
      _i2.WebViewClient,
      _i2.WebView,
      String,
    )? urlLoading,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #createWebViewClient,
          [],
          {
            #onPageStarted: onPageStarted,
            #onPageFinished: onPageFinished,
            #onReceivedRequestError: onReceivedRequestError,
            #onReceivedError: onReceivedError,
            #requestLoading: requestLoading,
            #urlLoading: urlLoading,
          },
        ),
        returnValue: _FakeWebViewClient_11(
          this,
          Invocation.method(
            #createWebViewClient,
            [],
            {
              #onPageStarted: onPageStarted,
              #onPageFinished: onPageFinished,
              #onReceivedRequestError: onReceivedRequestError,
              #onReceivedError: onReceivedError,
              #requestLoading: requestLoading,
              #urlLoading: urlLoading,
            },
          ),
        ),
      ) as _i2.WebViewClient);

  @override
  _i4.Future<void> setWebContentsDebuggingEnabled(bool? enabled) =>
      (super.noSuchMethod(
        Invocation.method(
          #setWebContentsDebuggingEnabled,
          [enabled],
        ),
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);
}
