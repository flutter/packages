// Mocks generated by Mockito 5.3.2 from annotations
// in webview_flutter/test/navigation_delegate_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i8;

import 'package:mockito/mockito.dart' as _i1;
import 'package:webview_flutter_platform_interface/src/platform_navigation_delegate.dart'
    as _i3;
import 'package:webview_flutter_platform_interface/src/platform_webview_controller.dart'
    as _i4;
import 'package:webview_flutter_platform_interface/src/platform_webview_cookie_manager.dart'
    as _i2;
import 'package:webview_flutter_platform_interface/src/platform_webview_widget.dart'
    as _i5;
import 'package:webview_flutter_platform_interface/src/types/types.dart' as _i6;
import 'package:webview_flutter_platform_interface/src/webview_platform.dart'
    as _i7;

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

class _FakePlatformWebViewCookieManager_0 extends _i1.SmartFake
    implements _i2.PlatformWebViewCookieManager {
  _FakePlatformWebViewCookieManager_0(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakePlatformNavigationDelegate_1 extends _i1.SmartFake
    implements _i3.PlatformNavigationDelegate {
  _FakePlatformNavigationDelegate_1(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakePlatformWebViewController_2 extends _i1.SmartFake
    implements _i4.PlatformWebViewController {
  _FakePlatformWebViewController_2(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakePlatformWebViewWidget_3 extends _i1.SmartFake
    implements _i5.PlatformWebViewWidget {
  _FakePlatformWebViewWidget_3(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakePlatformNavigationDelegateCreationParams_4 extends _i1.SmartFake
    implements _i6.PlatformNavigationDelegateCreationParams {
  _FakePlatformNavigationDelegateCreationParams_4(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

/// A class which mocks [WebViewPlatform].
///
/// See the documentation for Mockito's code generation for more information.
class MockWebViewPlatform extends _i1.Mock implements _i7.WebViewPlatform {
  MockWebViewPlatform() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i2.PlatformWebViewCookieManager createPlatformCookieManager(
          _i6.PlatformWebViewCookieManagerCreationParams? params) =>
      (super.noSuchMethod(
        Invocation.method(
          #createPlatformCookieManager,
          [params],
        ),
        returnValue: _FakePlatformWebViewCookieManager_0(
          this,
          Invocation.method(
            #createPlatformCookieManager,
            [params],
          ),
        ),
      ) as _i2.PlatformWebViewCookieManager);
  @override
  _i3.PlatformNavigationDelegate createPlatformNavigationDelegate(
          _i6.PlatformNavigationDelegateCreationParams? params) =>
      (super.noSuchMethod(
        Invocation.method(
          #createPlatformNavigationDelegate,
          [params],
        ),
        returnValue: _FakePlatformNavigationDelegate_1(
          this,
          Invocation.method(
            #createPlatformNavigationDelegate,
            [params],
          ),
        ),
      ) as _i3.PlatformNavigationDelegate);
  @override
  _i4.PlatformWebViewController createPlatformWebViewController(
          _i6.PlatformWebViewControllerCreationParams? params) =>
      (super.noSuchMethod(
        Invocation.method(
          #createPlatformWebViewController,
          [params],
        ),
        returnValue: _FakePlatformWebViewController_2(
          this,
          Invocation.method(
            #createPlatformWebViewController,
            [params],
          ),
        ),
      ) as _i4.PlatformWebViewController);
  @override
  _i5.PlatformWebViewWidget createPlatformWebViewWidget(
          _i6.PlatformWebViewWidgetCreationParams? params) =>
      (super.noSuchMethod(
        Invocation.method(
          #createPlatformWebViewWidget,
          [params],
        ),
        returnValue: _FakePlatformWebViewWidget_3(
          this,
          Invocation.method(
            #createPlatformWebViewWidget,
            [params],
          ),
        ),
      ) as _i5.PlatformWebViewWidget);
}

/// A class which mocks [PlatformNavigationDelegate].
///
/// See the documentation for Mockito's code generation for more information.
class MockPlatformNavigationDelegate extends _i1.Mock
    implements _i3.PlatformNavigationDelegate {
  MockPlatformNavigationDelegate() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i6.PlatformNavigationDelegateCreationParams get params =>
      (super.noSuchMethod(
        Invocation.getter(#params),
        returnValue: _FakePlatformNavigationDelegateCreationParams_4(
          this,
          Invocation.getter(#params),
        ),
      ) as _i6.PlatformNavigationDelegateCreationParams);
  @override
  _i8.Future<void> setOnNavigationRequest(
          _i3.NavigationRequestCallback? onNavigationRequest) =>
      (super.noSuchMethod(
        Invocation.method(
          #setOnNavigationRequest,
          [onNavigationRequest],
        ),
        returnValue: _i8.Future<void>.value(),
        returnValueForMissingStub: _i8.Future<void>.value(),
      ) as _i8.Future<void>);
  @override
  _i8.Future<void> setOnPageStarted(_i3.PageEventCallback? onPageStarted) =>
      (super.noSuchMethod(
        Invocation.method(
          #setOnPageStarted,
          [onPageStarted],
        ),
        returnValue: _i8.Future<void>.value(),
        returnValueForMissingStub: _i8.Future<void>.value(),
      ) as _i8.Future<void>);
  @override
  _i8.Future<void> setOnPageFinished(_i3.PageEventCallback? onPageFinished) =>
      (super.noSuchMethod(
        Invocation.method(
          #setOnPageFinished,
          [onPageFinished],
        ),
        returnValue: _i8.Future<void>.value(),
        returnValueForMissingStub: _i8.Future<void>.value(),
      ) as _i8.Future<void>);
  @override
  _i8.Future<void> setOnProgress(_i3.ProgressCallback? onProgress) =>
      (super.noSuchMethod(
        Invocation.method(
          #setOnProgress,
          [onProgress],
        ),
        returnValue: _i8.Future<void>.value(),
        returnValueForMissingStub: _i8.Future<void>.value(),
      ) as _i8.Future<void>);
  @override
  _i8.Future<void> setOnWebResourceError(
          _i3.WebResourceErrorCallback? onWebResourceError) =>
      (super.noSuchMethod(
        Invocation.method(
          #setOnWebResourceError,
          [onWebResourceError],
        ),
        returnValue: _i8.Future<void>.value(),
        returnValueForMissingStub: _i8.Future<void>.value(),
      ) as _i8.Future<void>);
  @override
  _i8.Future<void> setOnUrlChange(_i3.UrlChangeCallback? onUrlChange) =>
      (super.noSuchMethod(
        Invocation.method(
          #setOnUrlChange,
          [onUrlChange],
        ),
        returnValue: _i8.Future<void>.value(),
        returnValueForMissingStub: _i8.Future<void>.value(),
      ) as _i8.Future<void>);
}
