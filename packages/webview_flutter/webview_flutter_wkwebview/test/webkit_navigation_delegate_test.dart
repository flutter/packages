// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';
import 'package:webview_flutter_wkwebview/src/common/web_kit.g.dart';
import 'package:webview_flutter_wkwebview/src/common/webkit_constants.dart';
import 'package:webview_flutter_wkwebview/src/webkit_proxy.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

import 'webkit_navigation_delegate_test.mocks.dart';

@GenerateMocks(<Type>[
  URLAuthenticationChallenge,
  URLProtectionSpace,
  URLRequest,
  URL,
])
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  group('WebKitNavigationDelegate', () {
    test('WebKitNavigationDelegate uses params field in constructor', () async {
      await runZonedGuarded(
        () async => WebKitNavigationDelegate(
          const PlatformNavigationDelegateCreationParams(),
        ),
        (Object error, __) {
          expect(error, isNot(isA<TypeError>()));
        },
      );
    });

    test('setOnPageFinished', () async {
      final WebKitNavigationDelegate webKitDelegate = WebKitNavigationDelegate(
        const WebKitNavigationDelegateCreationParams(
          webKitProxy: WebKitProxy(
            newWKNavigationDelegate: CapturingNavigationDelegate.new,
          ),
        ),
      );

      late final String callbackUrl;
      await webKitDelegate.setOnPageFinished((String url) => callbackUrl = url);

      CapturingNavigationDelegate.lastCreatedDelegate.didFinishNavigation!(
        WKNavigationDelegate.pigeon_detached(
          pigeon_instanceManager: TestInstanceManager(),
          decidePolicyForNavigationAction: (_, __, ___) async {
            return NavigationActionPolicy.cancel;
          },
          decidePolicyForNavigationResponse: (_, __, ___) async {
            return NavigationResponsePolicy.cancel;
          },
          didReceiveAuthenticationChallenge: (_, __, ___) async {
            return AuthenticationChallengeResponse.pigeon_detached(
              disposition:
                  UrlSessionAuthChallengeDisposition.performDefaultHandling,
              pigeon_instanceManager: TestInstanceManager(),
            );
          },
        ),
        WKWebView.pigeon_detached(
          pigeon_instanceManager: TestInstanceManager(),
        ),
        'https://www.google.com',
      );

      expect(callbackUrl, 'https://www.google.com');
    });

    test('setOnPageStarted', () async {
      final WebKitNavigationDelegate webKitDelegate = WebKitNavigationDelegate(
        const WebKitNavigationDelegateCreationParams(
          webKitProxy: WebKitProxy(
            newWKNavigationDelegate: CapturingNavigationDelegate.new,
          ),
        ),
      );

      late final String callbackUrl;
      await webKitDelegate.setOnPageStarted((String url) => callbackUrl = url);

      CapturingNavigationDelegate
          .lastCreatedDelegate.didStartProvisionalNavigation!(
        WKNavigationDelegate.pigeon_detached(
          pigeon_instanceManager: TestInstanceManager(),
          decidePolicyForNavigationAction: (_, __, ___) async {
            return NavigationActionPolicy.cancel;
          },
          decidePolicyForNavigationResponse: (_, __, ___) async {
            return NavigationResponsePolicy.cancel;
          },
          didReceiveAuthenticationChallenge: (_, __, ___) async {
            return AuthenticationChallengeResponse.pigeon_detached(
              disposition:
                  UrlSessionAuthChallengeDisposition.performDefaultHandling,
              pigeon_instanceManager: TestInstanceManager(),
            );
          },
        ),
        WKWebView.pigeon_detached(
          pigeon_instanceManager: TestInstanceManager(),
        ),
        'https://www.google.com',
      );

      expect(callbackUrl, 'https://www.google.com');
    });

    test('setOnHttpError from decidePolicyForNavigationResponse', () async {
      final WebKitNavigationDelegate webKitDelegate = WebKitNavigationDelegate(
        const WebKitNavigationDelegateCreationParams(
          webKitProxy: WebKitProxy(
            newWKNavigationDelegate: CapturingNavigationDelegate.new,
          ),
        ),
      );

      late final HttpResponseError callbackError;
      void onHttpError(HttpResponseError error) {
        callbackError = error;
      }

      await webKitDelegate.setOnHttpError(onHttpError);

      await CapturingNavigationDelegate.lastCreatedDelegate
          .decidePolicyForNavigationResponse(
        WKNavigationDelegate.pigeon_detached(
          pigeon_instanceManager: TestInstanceManager(),
          decidePolicyForNavigationAction: (_, __, ___) async {
            return NavigationActionPolicy.cancel;
          },
          decidePolicyForNavigationResponse: (_, __, ___) async {
            return NavigationResponsePolicy.cancel;
          },
          didReceiveAuthenticationChallenge: (_, __, ___) async {
            return AuthenticationChallengeResponse.pigeon_detached(
              disposition:
                  UrlSessionAuthChallengeDisposition.performDefaultHandling,
              pigeon_instanceManager: TestInstanceManager(),
            );
          },
        ),
        WKWebView.pigeon_detached(
          pigeon_instanceManager: TestInstanceManager(),
        ),
        WKNavigationResponse.pigeon_detached(
          response: HTTPURLResponse.pigeon_detached(
            statusCode: 401,
            pigeon_instanceManager: TestInstanceManager(),
          ),
          isForMainFrame: true,
          pigeon_instanceManager: TestInstanceManager(),
        ),
      );

      expect(callbackError.response?.statusCode, 401);
    });

    test('setOnHttpError is not called for error codes < 400', () async {
      final WebKitNavigationDelegate webKitDelegate = WebKitNavigationDelegate(
        const WebKitNavigationDelegateCreationParams(
          webKitProxy: WebKitProxy(
            newWKNavigationDelegate: CapturingNavigationDelegate.new,
          ),
        ),
      );

      HttpResponseError? callbackError;
      void onHttpError(HttpResponseError error) {
        callbackError = error;
      }

      await webKitDelegate.setOnHttpError(onHttpError);

      await CapturingNavigationDelegate.lastCreatedDelegate
          .decidePolicyForNavigationResponse(
        WKNavigationDelegate.pigeon_detached(
          pigeon_instanceManager: TestInstanceManager(),
          decidePolicyForNavigationAction: (_, __, ___) async {
            return NavigationActionPolicy.cancel;
          },
          decidePolicyForNavigationResponse: (_, __, ___) async {
            return NavigationResponsePolicy.cancel;
          },
          didReceiveAuthenticationChallenge: (_, __, ___) async {
            return AuthenticationChallengeResponse.pigeon_detached(
              disposition:
                  UrlSessionAuthChallengeDisposition.performDefaultHandling,
              pigeon_instanceManager: TestInstanceManager(),
            );
          },
        ),
        WKWebView.pigeon_detached(
          pigeon_instanceManager: TestInstanceManager(),
        ),
        WKNavigationResponse.pigeon_detached(
          response: HTTPURLResponse.pigeon_detached(
            statusCode: 399,
            pigeon_instanceManager: TestInstanceManager(),
          ),
          isForMainFrame: true,
          pigeon_instanceManager: TestInstanceManager(),
        ),
      );

      expect(callbackError, isNull);
    });

    test('onWebResourceError from didFailNavigation', () async {
      final WebKitNavigationDelegate webKitDelegate = WebKitNavigationDelegate(
        const WebKitNavigationDelegateCreationParams(
          webKitProxy: WebKitProxy(
            newWKNavigationDelegate: CapturingNavigationDelegate.new,
          ),
        ),
      );

      late final WebKitWebResourceError callbackError;
      void onWebResourceError(WebResourceError error) {
        callbackError = error as WebKitWebResourceError;
      }

      await webKitDelegate.setOnWebResourceError(onWebResourceError);

      CapturingNavigationDelegate.lastCreatedDelegate.didFailNavigation!(
        WKNavigationDelegate.pigeon_detached(
          pigeon_instanceManager: TestInstanceManager(),
          decidePolicyForNavigationAction: (_, __, ___) async {
            return NavigationActionPolicy.cancel;
          },
          decidePolicyForNavigationResponse: (_, __, ___) async {
            return NavigationResponsePolicy.cancel;
          },
          didReceiveAuthenticationChallenge: (_, __, ___) async {
            return AuthenticationChallengeResponse.pigeon_detached(
              disposition:
                  UrlSessionAuthChallengeDisposition.performDefaultHandling,
              pigeon_instanceManager: TestInstanceManager(),
            );
          },
        ),
        WKWebView.pigeon_detached(
          pigeon_instanceManager: TestInstanceManager(),
        ),
        NSError.pigeon_detached(
          code: WKErrorCode.webViewInvalidated,
          domain: 'domain',
          userInfo: const <String, Object?>{
            NSErrorUserInfoKey.NSURLErrorFailingURLStringError:
                'www.flutter.dev',
            NSErrorUserInfoKey.NSLocalizedDescription: 'my desc',
          },
        ),
      );

      expect(callbackError.description, 'my desc');
      expect(callbackError.errorCode, WKErrorCode.webViewInvalidated);
      expect(callbackError.url, 'www.flutter.dev');
      expect(callbackError.domain, 'domain');
      expect(callbackError.errorType, WebResourceErrorType.webViewInvalidated);
      expect(callbackError.isForMainFrame, true);
    });

    test('onWebResourceError from didFailProvisionalNavigation', () async {
      final WebKitNavigationDelegate webKitDelegate = WebKitNavigationDelegate(
        const WebKitNavigationDelegateCreationParams(
          webKitProxy: WebKitProxy(
            newWKNavigationDelegate: CapturingNavigationDelegate.new,
          ),
        ),
      );

      late final WebKitWebResourceError callbackError;
      void onWebResourceError(WebResourceError error) {
        callbackError = error as WebKitWebResourceError;
      }

      await webKitDelegate.setOnWebResourceError(onWebResourceError);

      CapturingNavigationDelegate
          .lastCreatedDelegate.didFailProvisionalNavigation!(
        WKNavigationDelegate.pigeon_detached(
          pigeon_instanceManager: TestInstanceManager(),
          decidePolicyForNavigationAction: (_, __, ___) async {
            return NavigationActionPolicy.cancel;
          },
          decidePolicyForNavigationResponse: (_, __, ___) async {
            return NavigationResponsePolicy.cancel;
          },
          didReceiveAuthenticationChallenge: (_, __, ___) async {
            return AuthenticationChallengeResponse.pigeon_detached(
              disposition:
                  UrlSessionAuthChallengeDisposition.performDefaultHandling,
              pigeon_instanceManager: TestInstanceManager(),
            );
          },
        ),
        WKWebView.pigeon_detached(
          pigeon_instanceManager: TestInstanceManager(),
        ),
        NSError.pigeon_detached(
          code: WKErrorCode.webViewInvalidated,
          domain: 'domain',
          userInfo: const <String, Object?>{
            NSErrorUserInfoKey.NSURLErrorFailingURLStringError:
                'www.flutter.dev',
            NSErrorUserInfoKey.NSLocalizedDescription: 'my desc',
          },
        ),
      );

      expect(callbackError.description, 'my desc');
      expect(callbackError.url, 'www.flutter.dev');
      expect(callbackError.errorCode, WKErrorCode.webViewInvalidated);
      expect(callbackError.domain, 'domain');
      expect(callbackError.errorType, WebResourceErrorType.webViewInvalidated);
      expect(callbackError.isForMainFrame, true);
    });

    test('onWebResourceError from webViewWebContentProcessDidTerminate',
        () async {
      final WebKitNavigationDelegate webKitDelegate = WebKitNavigationDelegate(
        const WebKitNavigationDelegateCreationParams(
          webKitProxy: WebKitProxy(
            newWKNavigationDelegate: CapturingNavigationDelegate.new,
          ),
        ),
      );

      late final WebKitWebResourceError callbackError;
      void onWebResourceError(WebResourceError error) {
        callbackError = error as WebKitWebResourceError;
      }

      await webKitDelegate.setOnWebResourceError(onWebResourceError);

      CapturingNavigationDelegate
          .lastCreatedDelegate.webViewWebContentProcessDidTerminate!(
        WKNavigationDelegate.pigeon_detached(
          pigeon_instanceManager: TestInstanceManager(),
          decidePolicyForNavigationAction: (_, __, ___) async {
            return NavigationActionPolicy.cancel;
          },
          decidePolicyForNavigationResponse: (_, __, ___) async {
            return NavigationResponsePolicy.cancel;
          },
          didReceiveAuthenticationChallenge: (_, __, ___) async {
            return AuthenticationChallengeResponse.pigeon_detached(
              disposition:
                  UrlSessionAuthChallengeDisposition.performDefaultHandling,
              pigeon_instanceManager: TestInstanceManager(),
            );
          },
        ),
        WKWebView.pigeon_detached(
          pigeon_instanceManager: TestInstanceManager(),
        ),
      );

      expect(callbackError.description, '');
      expect(callbackError.errorCode, WKErrorCode.webContentProcessTerminated);
      expect(callbackError.domain, 'WKErrorDomain');
      expect(
        callbackError.errorType,
        WebResourceErrorType.webContentProcessTerminated,
      );
      expect(callbackError.isForMainFrame, true);
    });

    test('onNavigationRequest from decidePolicyForNavigationAction', () async {
      final WebKitNavigationDelegate webKitDelegate = WebKitNavigationDelegate(
        const WebKitNavigationDelegateCreationParams(
          webKitProxy: WebKitProxy(
            newWKNavigationDelegate: CapturingNavigationDelegate.new,
          ),
        ),
      );

      late final NavigationRequest callbackRequest;
      FutureOr<NavigationDecision> onNavigationRequest(
        NavigationRequest request,
      ) {
        callbackRequest = request;
        return NavigationDecision.navigate;
      }

      await webKitDelegate.setOnNavigationRequest(onNavigationRequest);

      final MockURLRequest mockRequest = MockURLRequest();
      when(mockRequest.getUrl()).thenAnswer(
        (_) => Future<String>.value('https://www.google.com'),
      );

      expect(
        await CapturingNavigationDelegate.lastCreatedDelegate
            .decidePolicyForNavigationAction(
          WKNavigationDelegate.pigeon_detached(
            pigeon_instanceManager: TestInstanceManager(),
            decidePolicyForNavigationAction: (_, __, ___) async {
              return NavigationActionPolicy.cancel;
            },
            decidePolicyForNavigationResponse: (_, __, ___) async {
              return NavigationResponsePolicy.cancel;
            },
            didReceiveAuthenticationChallenge: (_, __, ___) async {
              return AuthenticationChallengeResponse.pigeon_detached(
                disposition:
                    UrlSessionAuthChallengeDisposition.performDefaultHandling,
                pigeon_instanceManager: TestInstanceManager(),
              );
            },
          ),
          WKWebView.pigeon_detached(
            pigeon_instanceManager: TestInstanceManager(),
          ),
          WKNavigationAction.pigeon_detached(
            request: mockRequest,
            targetFrame: WKFrameInfo.pigeon_detached(
              isMainFrame: false,
              request: URLRequest.pigeon_detached(
                pigeon_instanceManager: TestInstanceManager(),
              ),
            ),
            navigationType: NavigationType.linkActivated,
            pigeon_instanceManager: TestInstanceManager(),
          ),
        ),
        NavigationActionPolicy.allow,
      );

      expect(callbackRequest.url, 'https://www.google.com');
      expect(callbackRequest.isMainFrame, isFalse);
    });

    test('onHttpBasicAuthRequest emits host and realm', () async {
      final WebKitNavigationDelegate iosNavigationDelegate =
          WebKitNavigationDelegate(
        WebKitNavigationDelegateCreationParams(
          webKitProxy: WebKitProxy(
            newWKNavigationDelegate: CapturingNavigationDelegate.new,
            createAsyncAuthenticationChallengeResponse: (
              UrlSessionAuthChallengeDisposition disposition,
              URLCredential? credential,
            ) async {
              return AuthenticationChallengeResponse.pigeon_detached(
                disposition:
                    UrlSessionAuthChallengeDisposition.performDefaultHandling,
                pigeon_instanceManager: TestInstanceManager(),
              );
            },
          ),
        ),
      );

      String? callbackHost;
      String? callbackRealm;

      await iosNavigationDelegate.setOnHttpAuthRequest(
        (HttpAuthRequest request) {
          callbackHost = request.host;
          callbackRealm = request.realm;
          request.onCancel();
        },
      );

      const String expectedHost = 'expectedHost';
      const String expectedRealm = 'expectedRealm';

      final MockURLAuthenticationChallenge mockChallenge =
          MockURLAuthenticationChallenge();
      when(mockChallenge.getProtectionSpace()).thenAnswer(
        (_) {
          return Future<URLProtectionSpace>.value(
            URLProtectionSpace.pigeon_detached(
              port: 0,
              host: expectedHost,
              realm: expectedRealm,
              authenticationMethod: NSUrlAuthenticationMethod.httpBasic,
              pigeon_instanceManager: TestInstanceManager(),
            ),
          );
        },
      );

      await CapturingNavigationDelegate.lastCreatedDelegate
          .didReceiveAuthenticationChallenge(
        WKNavigationDelegate.pigeon_detached(
          pigeon_instanceManager: TestInstanceManager(),
          decidePolicyForNavigationAction: (_, __, ___) async {
            return NavigationActionPolicy.cancel;
          },
          decidePolicyForNavigationResponse: (_, __, ___) async {
            return NavigationResponsePolicy.cancel;
          },
          didReceiveAuthenticationChallenge: (_, __, ___) async {
            return AuthenticationChallengeResponse.pigeon_detached(
              disposition:
                  UrlSessionAuthChallengeDisposition.performDefaultHandling,
              pigeon_instanceManager: TestInstanceManager(),
            );
          },
        ),
        WKWebView.pigeon_detached(
          pigeon_instanceManager: TestInstanceManager(),
        ),
        mockChallenge,
      );

      expect(callbackHost, expectedHost);
      expect(callbackRealm, expectedRealm);
    });

    test('onHttpNtlmAuthRequest emits host and realm', () async {
      const String expectedUser = 'user';
      const String expectedPassword = 'password';
      const UrlCredentialPersistence expectedPersistence =
          UrlCredentialPersistence.forSession;

      final WebKitNavigationDelegate iosNavigationDelegate =
          WebKitNavigationDelegate(
        WebKitNavigationDelegateCreationParams(
          webKitProxy: WebKitProxy(
              newWKNavigationDelegate: CapturingNavigationDelegate.new,
              createAsyncAuthenticationChallengeResponse: (
                UrlSessionAuthChallengeDisposition disposition,
                URLCredential? credential,
              ) async {
                return AuthenticationChallengeResponse.pigeon_detached(
                  disposition: disposition,
                  credential: credential,
                  pigeon_instanceManager: TestInstanceManager(),
                );
              },
              withUserAsyncURLCredential: (
                String user,
                String password,
                UrlCredentialPersistence persistence,
              ) async {
                expect(user, expectedUser);
                expect(password, expectedPassword);
                expect(persistence, expectedPersistence);
                return URLCredential.pigeon_detached(
                  pigeon_instanceManager: TestInstanceManager(),
                );
              }),
        ),
      );

      String? callbackHost;
      String? callbackRealm;

      await iosNavigationDelegate.setOnHttpAuthRequest(
        (HttpAuthRequest request) {
          callbackHost = request.host;
          callbackRealm = request.realm;
          request.onProceed(
            const WebViewCredential(
              user: expectedUser,
              password: expectedPassword,
            ),
          );
        },
      );

      const String expectedHost = 'expectedHost';
      const String expectedRealm = 'expectedRealm';

      final MockURLAuthenticationChallenge mockChallenge =
          MockURLAuthenticationChallenge();
      when(mockChallenge.getProtectionSpace()).thenAnswer(expectAsync1(
        (_) {
          return Future<URLProtectionSpace>.value(
            URLProtectionSpace.pigeon_detached(
              port: 0,
              host: expectedHost,
              realm: expectedRealm,
              authenticationMethod: NSUrlAuthenticationMethod.httpNtlm,
              pigeon_instanceManager: TestInstanceManager(),
            ),
          );
        },
      ));

      final AuthenticationChallengeResponse result =
          await CapturingNavigationDelegate.lastCreatedDelegate
              .didReceiveAuthenticationChallenge(
        WKNavigationDelegate.pigeon_detached(
          pigeon_instanceManager: TestInstanceManager(),
          decidePolicyForNavigationAction: (_, __, ___) async {
            return NavigationActionPolicy.cancel;
          },
          decidePolicyForNavigationResponse: (_, __, ___) async {
            return NavigationResponsePolicy.cancel;
          },
          didReceiveAuthenticationChallenge: (_, __, ___) async {
            return AuthenticationChallengeResponse.pigeon_detached(
              disposition:
                  UrlSessionAuthChallengeDisposition.performDefaultHandling,
              pigeon_instanceManager: TestInstanceManager(),
            );
          },
        ),
        WKWebView.pigeon_detached(
          pigeon_instanceManager: TestInstanceManager(),
        ),
        mockChallenge,
      );

      expect(
        result.disposition,
        UrlSessionAuthChallengeDisposition.useCredential,
      );

      expect(callbackHost, expectedHost);
      expect(callbackRealm, expectedRealm);
    });

    test('setOnSSlAuthError', () async {
      const String exceptionCode = 'code';
      const String exceptionMessage = 'message';
      final Uint8List copiedExceptions = Uint8List(0);
      final SecCertificate leafCertificate = SecCertificate.pigeon_detached(
        pigeon_instanceManager: TestInstanceManager(),
      );
      final Uint8List certificateData = Uint8List(0);

      final WebKitNavigationDelegate iosNavigationDelegate =
          WebKitNavigationDelegate(
        WebKitNavigationDelegateCreationParams(
          webKitProxy: WebKitProxy(
            newWKNavigationDelegate: CapturingNavigationDelegate.new,
            createAsyncAuthenticationChallengeResponse: (
              UrlSessionAuthChallengeDisposition disposition,
              URLCredential? credential,
            ) async {
              return AuthenticationChallengeResponse.pigeon_detached(
                disposition: disposition,
                credential: credential,
                pigeon_instanceManager: TestInstanceManager(),
              );
            },
            serverTrustAsyncURLCredential: (_) async {
              return URLCredential.pigeon_detached(
                pigeon_instanceManager: TestInstanceManager(),
              );
            },
            evaluateWithErrorSecTrust: (_) async {
              throw PlatformException(
                code: exceptionCode,
                message: exceptionMessage,
              );
            },
            copyExceptionsSecTrust: (_) async => copiedExceptions,
            setExceptionsSecTrust: expectAsync2(
              (_, Uint8List? exceptions) async {
                expect(exceptions, copiedExceptions);
                return true;
              },
            ),
            getTrustResultSecTrust: (_) async {
              return GetTrustResultResponse.pigeon_detached(
                result: DartSecTrustResultType.recoverableTrustFailure,
                resultCode: 0,
                pigeon_instanceManager: TestInstanceManager(),
              );
            },
            copyCertificateChainSecTrust: (_) async {
              return <SecCertificate>[leafCertificate];
            },
            copyDataSecCertificate: (_) async => certificateData,
          ),
        ),
      );

      Completer<PlatformSslAuthError> errorCompleter =
          Completer<PlatformSslAuthError>();
      await iosNavigationDelegate.setOnSSlAuthError(
        (PlatformSslAuthError error) {
          errorCompleter.complete(error);
        },
      );

      const int port = 65;
      const String host = 'host';

      final MockURLAuthenticationChallenge mockChallenge =
          MockURLAuthenticationChallenge();
      final SecTrust testTrust = SecTrust.pigeon_detached(
        pigeon_instanceManager: TestInstanceManager(),
      );
      when(mockChallenge.getProtectionSpace()).thenAnswer(
        (_) async {
          final MockURLProtectionSpace mockProtectionSpace =
              MockURLProtectionSpace();
          when(mockProtectionSpace.port).thenReturn(port);
          when(mockProtectionSpace.host).thenReturn(host);
          when(mockProtectionSpace.authenticationMethod).thenReturn(
            NSUrlAuthenticationMethod.serverTrust,
          );
          when(mockProtectionSpace.getServerTrust()).thenAnswer(
            (_) async => testTrust,
          );
          return mockProtectionSpace;
        },
      );

      final WKNavigationDelegate testDelegate =
          WKNavigationDelegate.pigeon_detached(
        pigeon_instanceManager: TestInstanceManager(),
        decidePolicyForNavigationAction: (_, __, ___) async {
          return NavigationActionPolicy.cancel;
        },
        decidePolicyForNavigationResponse: (_, __, ___) async {
          return NavigationResponsePolicy.cancel;
        },
        didReceiveAuthenticationChallenge: (_, __, ___) async {
          return AuthenticationChallengeResponse.pigeon_detached(
            disposition:
                UrlSessionAuthChallengeDisposition.performDefaultHandling,
            pigeon_instanceManager: TestInstanceManager(),
          );
        },
      );
      final WKWebView testWebView = WKWebView.pigeon_detached(
        pigeon_instanceManager: TestInstanceManager(),
      );

      Future<AuthenticationChallengeResponse> authReplyFuture =
          CapturingNavigationDelegate.lastCreatedDelegate
              .didReceiveAuthenticationChallenge(
        testDelegate,
        testWebView,
        mockChallenge,
      );

      WebKitSslAuthError error =
          await errorCompleter.future as WebKitSslAuthError;
      expect(error.certificate?.data, certificateData);
      expect(error.description, '$exceptionCode: $exceptionMessage');
      expect(error.host, host);
      expect(error.port, port);

      // Test proceed.
      await error.proceed();

      AuthenticationChallengeResponse authReply = await authReplyFuture;
      expect(
        authReply.disposition,
        UrlSessionAuthChallengeDisposition.useCredential,
      );

      // Test cancel.
      errorCompleter = Completer<PlatformSslAuthError>();
      authReplyFuture = CapturingNavigationDelegate.lastCreatedDelegate
          .didReceiveAuthenticationChallenge(
        testDelegate,
        testWebView,
        mockChallenge,
      );

      error = await errorCompleter.future as WebKitSslAuthError;
      await error.cancel();

      authReply = await authReplyFuture;
      expect(
        authReply.disposition,
        UrlSessionAuthChallengeDisposition.cancelAuthenticationChallenge,
      );
    });

    test(
        'didReceiveAuthenticationChallenge calls performDefaultHandling by default',
        () async {
      WebKitNavigationDelegate(
        WebKitNavigationDelegateCreationParams(
          webKitProxy: WebKitProxy(
            newWKNavigationDelegate: CapturingNavigationDelegate.new,
            createAsyncAuthenticationChallengeResponse: (
              UrlSessionAuthChallengeDisposition disposition,
              URLCredential? credential,
            ) async {
              return AuthenticationChallengeResponse.pigeon_detached(
                disposition: disposition,
                credential: credential,
                pigeon_instanceManager: TestInstanceManager(),
              );
            },
          ),
        ),
      );

      final MockURLAuthenticationChallenge mockChallenge =
          MockURLAuthenticationChallenge();
      when(mockChallenge.getProtectionSpace()).thenAnswer(
        (_) async {
          final MockURLProtectionSpace mockProtectionSpace =
              MockURLProtectionSpace();
          when(mockProtectionSpace.authenticationMethod).thenReturn(
            NSUrlAuthenticationMethod.httpBasic,
          );
          return mockProtectionSpace;
        },
      );

      final WKNavigationDelegate testDelegate =
          WKNavigationDelegate.pigeon_detached(
        pigeon_instanceManager: TestInstanceManager(),
        decidePolicyForNavigationAction: (_, __, ___) async {
          return NavigationActionPolicy.cancel;
        },
        decidePolicyForNavigationResponse: (_, __, ___) async {
          return NavigationResponsePolicy.cancel;
        },
        didReceiveAuthenticationChallenge: (_, __, ___) async {
          return AuthenticationChallengeResponse.pigeon_detached(
            disposition:
                UrlSessionAuthChallengeDisposition.performDefaultHandling,
            pigeon_instanceManager: TestInstanceManager(),
          );
        },
      );
      final WKWebView testWebView = WKWebView.pigeon_detached(
        pigeon_instanceManager: TestInstanceManager(),
      );

      final AuthenticationChallengeResponse authReply =
          await CapturingNavigationDelegate.lastCreatedDelegate
              .didReceiveAuthenticationChallenge(
        testDelegate,
        testWebView,
        mockChallenge,
      );

      expect(
        authReply.disposition,
        UrlSessionAuthChallengeDisposition.performDefaultHandling,
      );
      expect(authReply.credential, isNull);
    });
  });
}

// Records the last created instance of itself.
class CapturingNavigationDelegate extends WKNavigationDelegate {
  CapturingNavigationDelegate({
    super.didFinishNavigation,
    super.didStartProvisionalNavigation,
    required super.decidePolicyForNavigationResponse,
    super.didFailNavigation,
    super.didFailProvisionalNavigation,
    required super.decidePolicyForNavigationAction,
    super.webViewWebContentProcessDidTerminate,
    required super.didReceiveAuthenticationChallenge,
  }) : super.pigeon_detached(pigeon_instanceManager: TestInstanceManager()) {
    lastCreatedDelegate = this;
  }
  static CapturingNavigationDelegate lastCreatedDelegate =
      CapturingNavigationDelegate(
    decidePolicyForNavigationAction: (_, __, ___) async {
      return NavigationActionPolicy.cancel;
    },
    decidePolicyForNavigationResponse: (_, __, ___) async {
      return NavigationResponsePolicy.cancel;
    },
    didReceiveAuthenticationChallenge: (_, __, ___) async {
      return AuthenticationChallengeResponse.pigeon_detached(
        disposition: UrlSessionAuthChallengeDisposition.performDefaultHandling,
        pigeon_instanceManager: TestInstanceManager(),
      );
    },
  );
}

// Test InstanceManager that sets `onWeakReferenceRemoved` as a noop.
class TestInstanceManager extends PigeonInstanceManager {
  TestInstanceManager() : super(onWeakReferenceRemoved: (_) {});
}
