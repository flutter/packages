// Mocks generated by Mockito 5.4.0 from annotations
// in webview_flutter_wkwebview/test/src/ui_kit/ui_kit_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i4;

import 'package:mockito/mockito.dart' as _i1;
import 'package:webview_flutter_wkwebview/src/common/web_kit.g.dart' as _i3;

import '../common/test_web_kit.g.dart' as _i2;

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

/// A class which mocks [TestWKWebViewConfigurationHostApi].
///
/// See the documentation for Mockito's code generation for more information.
class MockTestWKWebViewConfigurationHostApi extends _i1.Mock
    implements _i2.TestWKWebViewConfigurationHostApi {
  MockTestWKWebViewConfigurationHostApi() {
    _i1.throwOnMissingStub(this);
  }

  @override
  void create(int? identifier) => super.noSuchMethod(
        Invocation.method(
          #create,
          [identifier],
        ),
        returnValueForMissingStub: null,
      );
  @override
  void createFromWebView(
    int? identifier,
    int? webViewIdentifier,
  ) =>
      super.noSuchMethod(
        Invocation.method(
          #createFromWebView,
          [
            identifier,
            webViewIdentifier,
          ],
        ),
        returnValueForMissingStub: null,
      );
  @override
  void setAllowsInlineMediaPlayback(
    int? identifier,
    bool? allow,
  ) =>
      super.noSuchMethod(
        Invocation.method(
          #setAllowsInlineMediaPlayback,
          [
            identifier,
            allow,
          ],
        ),
        returnValueForMissingStub: null,
      );
  @override
  void setLimitsNavigationsToAppBoundDomains(
    int? identifier,
    bool? limit,
  ) =>
      super.noSuchMethod(
        Invocation.method(
          #setLimitsNavigationsToAppBoundDomains,
          [
            identifier,
            limit,
          ],
        ),
        returnValueForMissingStub: null,
      );
  @override
  void setMediaTypesRequiringUserActionForPlayback(
    int? identifier,
    List<_i3.WKAudiovisualMediaTypeEnumData?>? types,
  ) =>
      super.noSuchMethod(
        Invocation.method(
          #setMediaTypesRequiringUserActionForPlayback,
          [
            identifier,
            types,
          ],
        ),
        returnValueForMissingStub: null,
      );
}

/// A class which mocks [TestWKWebViewHostApi].
///
/// See the documentation for Mockito's code generation for more information.
class MockTestWKWebViewHostApi extends _i1.Mock
    implements _i2.TestWKWebViewHostApi {
  MockTestWKWebViewHostApi() {
    _i1.throwOnMissingStub(this);
  }

  @override
  void create(
    int? identifier,
    int? configurationIdentifier,
  ) =>
      super.noSuchMethod(
        Invocation.method(
          #create,
          [
            identifier,
            configurationIdentifier,
          ],
        ),
        returnValueForMissingStub: null,
      );
  @override
  void setUIDelegate(
    int? identifier,
    int? uiDelegateIdentifier,
  ) =>
      super.noSuchMethod(
        Invocation.method(
          #setUIDelegate,
          [
            identifier,
            uiDelegateIdentifier,
          ],
        ),
        returnValueForMissingStub: null,
      );
  @override
  void setNavigationDelegate(
    int? identifier,
    int? navigationDelegateIdentifier,
  ) =>
      super.noSuchMethod(
        Invocation.method(
          #setNavigationDelegate,
          [
            identifier,
            navigationDelegateIdentifier,
          ],
        ),
        returnValueForMissingStub: null,
      );
  @override
  String? getUrl(int? identifier) => (super.noSuchMethod(Invocation.method(
        #getUrl,
        [identifier],
      )) as String?);
  @override
  double getEstimatedProgress(int? identifier) => (super.noSuchMethod(
        Invocation.method(
          #getEstimatedProgress,
          [identifier],
        ),
        returnValue: 0.0,
      ) as double);
  @override
  void loadRequest(
    int? identifier,
    _i3.NSUrlRequestData? request,
  ) =>
      super.noSuchMethod(
        Invocation.method(
          #loadRequest,
          [
            identifier,
            request,
          ],
        ),
        returnValueForMissingStub: null,
      );
  @override
  void loadHtmlString(
    int? identifier,
    String? string,
    String? baseUrl,
  ) =>
      super.noSuchMethod(
        Invocation.method(
          #loadHtmlString,
          [
            identifier,
            string,
            baseUrl,
          ],
        ),
        returnValueForMissingStub: null,
      );
  @override
  void loadFileUrl(
    int? identifier,
    String? url,
    String? readAccessUrl,
  ) =>
      super.noSuchMethod(
        Invocation.method(
          #loadFileUrl,
          [
            identifier,
            url,
            readAccessUrl,
          ],
        ),
        returnValueForMissingStub: null,
      );
  @override
  void loadFlutterAsset(
    int? identifier,
    String? key,
  ) =>
      super.noSuchMethod(
        Invocation.method(
          #loadFlutterAsset,
          [
            identifier,
            key,
          ],
        ),
        returnValueForMissingStub: null,
      );
  @override
  bool canGoBack(int? identifier) => (super.noSuchMethod(
        Invocation.method(
          #canGoBack,
          [identifier],
        ),
        returnValue: false,
      ) as bool);
  @override
  bool canGoForward(int? identifier) => (super.noSuchMethod(
        Invocation.method(
          #canGoForward,
          [identifier],
        ),
        returnValue: false,
      ) as bool);
  @override
  void goBack(int? identifier) => super.noSuchMethod(
        Invocation.method(
          #goBack,
          [identifier],
        ),
        returnValueForMissingStub: null,
      );
  @override
  void goForward(int? identifier) => super.noSuchMethod(
        Invocation.method(
          #goForward,
          [identifier],
        ),
        returnValueForMissingStub: null,
      );
  @override
  void reload(int? identifier) => super.noSuchMethod(
        Invocation.method(
          #reload,
          [identifier],
        ),
        returnValueForMissingStub: null,
      );
  @override
  String? getTitle(int? identifier) => (super.noSuchMethod(Invocation.method(
        #getTitle,
        [identifier],
      )) as String?);
  @override
  void setAllowsBackForwardNavigationGestures(
    int? identifier,
    bool? allow,
  ) =>
      super.noSuchMethod(
        Invocation.method(
          #setAllowsBackForwardNavigationGestures,
          [
            identifier,
            allow,
          ],
        ),
        returnValueForMissingStub: null,
      );
  @override
  void setCustomUserAgent(
    int? identifier,
    String? userAgent,
  ) =>
      super.noSuchMethod(
        Invocation.method(
          #setCustomUserAgent,
          [
            identifier,
            userAgent,
          ],
        ),
        returnValueForMissingStub: null,
      );
  @override
  _i4.Future<Object?> evaluateJavaScript(
    int? identifier,
    String? javaScriptString,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #evaluateJavaScript,
          [
            identifier,
            javaScriptString,
          ],
        ),
        returnValue: _i4.Future<Object?>.value(),
      ) as _i4.Future<Object?>);
  @override
  void setInspectable(
    int? identifier,
    bool? inspectable,
  ) =>
      super.noSuchMethod(
        Invocation.method(
          #setInspectable,
          [
            identifier,
            inspectable,
          ],
        ),
        returnValueForMissingStub: null,
      );
}

/// A class which mocks [TestUIScrollViewHostApi].
///
/// See the documentation for Mockito's code generation for more information.
class MockTestUIScrollViewHostApi extends _i1.Mock
    implements _i2.TestUIScrollViewHostApi {
  MockTestUIScrollViewHostApi() {
    _i1.throwOnMissingStub(this);
  }

  @override
  void createFromWebView(
    int? identifier,
    int? webViewIdentifier,
  ) =>
      super.noSuchMethod(
        Invocation.method(
          #createFromWebView,
          [
            identifier,
            webViewIdentifier,
          ],
        ),
        returnValueForMissingStub: null,
      );
  @override
  List<double?> getContentOffset(int? identifier) => (super.noSuchMethod(
        Invocation.method(
          #getContentOffset,
          [identifier],
        ),
        returnValue: <double?>[],
      ) as List<double?>);
  @override
  void scrollBy(
    int? identifier,
    double? x,
    double? y,
  ) =>
      super.noSuchMethod(
        Invocation.method(
          #scrollBy,
          [
            identifier,
            x,
            y,
          ],
        ),
        returnValueForMissingStub: null,
      );
  @override
  void setContentOffset(
    int? identifier,
    double? x,
    double? y,
  ) =>
      super.noSuchMethod(
        Invocation.method(
          #setContentOffset,
          [
            identifier,
            x,
            y,
          ],
        ),
        returnValueForMissingStub: null,
      );
}

/// A class which mocks [TestUIViewHostApi].
///
/// See the documentation for Mockito's code generation for more information.
class MockTestUIViewHostApi extends _i1.Mock implements _i2.TestUIViewHostApi {
  MockTestUIViewHostApi() {
    _i1.throwOnMissingStub(this);
  }

  @override
  void setBackgroundColor(
    int? identifier,
    int? value,
  ) =>
      super.noSuchMethod(
        Invocation.method(
          #setBackgroundColor,
          [
            identifier,
            value,
          ],
        ),
        returnValueForMissingStub: null,
      );
  @override
  void setOpaque(
    int? identifier,
    bool? opaque,
  ) =>
      super.noSuchMethod(
        Invocation.method(
          #setOpaque,
          [
            identifier,
            opaque,
          ],
        ),
        returnValueForMissingStub: null,
      );
}
