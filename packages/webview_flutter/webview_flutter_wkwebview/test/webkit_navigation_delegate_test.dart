// Copyright 2013 The Flutter Authors
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

  setUp(() {
    PigeonOverrides.pigeon_reset();
  });

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
      PigeonOverrides.wKNavigationDelegate_new =
          CapturingNavigationDelegate.new;
      final webKitDelegate = WebKitNavigationDelegate(
        const WebKitNavigationDelegateCreationParams(),
      );

      late final String callbackUrl;
      await webKitDelegate.setOnPageFinished((String url) => callbackUrl = url);

      CapturingNavigationDelegate.lastCreatedDelegate.didFinishNavigation!(
        WKNavigationDelegate.pigeon_detached(
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
            );
          },
        ),
        WKWebView.pigeon_detached(),
        'https://www.google.com',
      );

      expect(callbackUrl, 'https://www.google.com');
    });

    test('setOnPageStarted', () async {
      PigeonOverrides.wKNavigationDelegate_new =
          CapturingNavigationDelegate.new;
      final webKitDelegate = WebKitNavigationDelegate(
        const WebKitNavigationDelegateCreationParams(),
      );

      late final String callbackUrl;
      await webKitDelegate.setOnPageStarted((String url) => callbackUrl = url);

      CapturingNavigationDelegate
          .lastCreatedDelegate
          .didStartProvisionalNavigation!(
        WKNavigationDelegate.pigeon_detached(
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
            );
          },
        ),
        WKWebView.pigeon_detached(),
        'https://www.google.com',
      );

      expect(callbackUrl, 'https://www.google.com');
    });

    test('setOnHttpError from decidePolicyForNavigationResponse', () async {
      PigeonOverrides.wKNavigationDelegate_new =
          CapturingNavigationDelegate.new;
      final webKitDelegate = WebKitNavigationDelegate(
        const WebKitNavigationDelegateCreationParams(),
      );

      late final HttpResponseError callbackError;
      void onHttpError(HttpResponseError error) {
        callbackError = error;
      }

      await webKitDelegate.setOnHttpError(onHttpError);

      await CapturingNavigationDelegate.lastCreatedDelegate
          .decidePolicyForNavigationResponse(
            WKNavigationDelegate.pigeon_detached(
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
                );
              },
            ),
            WKWebView.pigeon_detached(),
            WKNavigationResponse.pigeon_detached(
              response: HTTPURLResponse.pigeon_detached(statusCode: 401),
              isForMainFrame: true,
            ),
          );

      expect(callbackError.response?.statusCode, 401);
    });

    test('setOnHttpError is not called for error codes < 400', () async {
      PigeonOverrides.wKNavigationDelegate_new =
          CapturingNavigationDelegate.new;
      final webKitDelegate = WebKitNavigationDelegate(
        const WebKitNavigationDelegateCreationParams(),
      );

      HttpResponseError? callbackError;
      void onHttpError(HttpResponseError error) {
        callbackError = error;
      }

      await webKitDelegate.setOnHttpError(onHttpError);

      await CapturingNavigationDelegate.lastCreatedDelegate
          .decidePolicyForNavigationResponse(
            WKNavigationDelegate.pigeon_detached(
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
                );
              },
            ),
            WKWebView.pigeon_detached(),
            WKNavigationResponse.pigeon_detached(
              response: HTTPURLResponse.pigeon_detached(statusCode: 399),
              isForMainFrame: true,
            ),
          );

      expect(callbackError, isNull);
    });

    test('onWebResourceError from didFailNavigation', () async {
      PigeonOverrides.wKNavigationDelegate_new =
          CapturingNavigationDelegate.new;
      final webKitDelegate = WebKitNavigationDelegate(
        const WebKitNavigationDelegateCreationParams(),
      );

      late final WebKitWebResourceError callbackError;
      void onWebResourceError(WebResourceError error) {
        callbackError = error as WebKitWebResourceError;
      }

      await webKitDelegate.setOnWebResourceError(onWebResourceError);

      CapturingNavigationDelegate.lastCreatedDelegate.didFailNavigation!(
        WKNavigationDelegate.pigeon_detached(
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
            );
          },
        ),
        WKWebView.pigeon_detached(),
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
      PigeonOverrides.wKNavigationDelegate_new =
          CapturingNavigationDelegate.new;
      final webKitDelegate = WebKitNavigationDelegate(
        const WebKitNavigationDelegateCreationParams(),
      );

      late final WebKitWebResourceError callbackError;
      void onWebResourceError(WebResourceError error) {
        callbackError = error as WebKitWebResourceError;
      }

      await webKitDelegate.setOnWebResourceError(onWebResourceError);

      CapturingNavigationDelegate
          .lastCreatedDelegate
          .didFailProvisionalNavigation!(
        WKNavigationDelegate.pigeon_detached(
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
            );
          },
        ),
        WKWebView.pigeon_detached(),
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

    test(
      'onWebResourceError from webViewWebContentProcessDidTerminate',
      () async {
        PigeonOverrides.wKNavigationDelegate_new =
            CapturingNavigationDelegate.new;
        final webKitDelegate = WebKitNavigationDelegate(
          const WebKitNavigationDelegateCreationParams(),
        );

        late final WebKitWebResourceError callbackError;
        void onWebResourceError(WebResourceError error) {
          callbackError = error as WebKitWebResourceError;
        }

        await webKitDelegate.setOnWebResourceError(onWebResourceError);

        CapturingNavigationDelegate
            .lastCreatedDelegate
            .webViewWebContentProcessDidTerminate!(
          WKNavigationDelegate.pigeon_detached(
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
              );
            },
          ),
          WKWebView.pigeon_detached(),
        );

        expect(callbackError.description, '');
        expect(
          callbackError.errorCode,
          WKErrorCode.webContentProcessTerminated,
        );
        expect(callbackError.domain, 'WKErrorDomain');
        expect(
          callbackError.errorType,
          WebResourceErrorType.webContentProcessTerminated,
        );
        expect(callbackError.isForMainFrame, true);
      },
    );

    test('onNavigationRequest from decidePolicyForNavigationAction', () async {
      PigeonOverrides.wKNavigationDelegate_new =
          CapturingNavigationDelegate.new;
      final webKitDelegate = WebKitNavigationDelegate(
        const WebKitNavigationDelegateCreationParams(),
      );

      late final NavigationRequest callbackRequest;
      FutureOr<NavigationDecision> onNavigationRequest(
        NavigationRequest request,
      ) {
        callbackRequest = request;
        return NavigationDecision.navigate;
      }

      await webKitDelegate.setOnNavigationRequest(onNavigationRequest);

      final mockRequest = MockURLRequest();
      when(
        mockRequest.getUrl(),
      ).thenAnswer((_) => Future<String>.value('https://www.google.com'));

      expect(
        await CapturingNavigationDelegate.lastCreatedDelegate
            .decidePolicyForNavigationAction(
              WKNavigationDelegate.pigeon_detached(
                decidePolicyForNavigationAction: (_, __, ___) async {
                  return NavigationActionPolicy.cancel;
                },
                decidePolicyForNavigationResponse: (_, __, ___) async {
                  return NavigationResponsePolicy.cancel;
                },
                didReceiveAuthenticationChallenge: (_, __, ___) async {
                  return AuthenticationChallengeResponse.pigeon_detached(
                    disposition: UrlSessionAuthChallengeDisposition
                        .performDefaultHandling,
                  );
                },
              ),
              WKWebView.pigeon_detached(),
              WKNavigationAction.pigeon_detached(
                request: mockRequest,
                targetFrame: WKFrameInfo.pigeon_detached(
                  isMainFrame: false,
                  request: URLRequest.pigeon_detached(),
                ),
                navigationType: NavigationType.linkActivated,
              ),
            ),
        NavigationActionPolicy.allow,
      );

      expect(callbackRequest.url, 'https://www.google.com');
      expect(callbackRequest.isMainFrame, isFalse);
    });

    test('onHttpBasicAuthRequest emits host and realm', () async {
      PigeonOverrides.wKNavigationDelegate_new =
          CapturingNavigationDelegate.new;
      PigeonOverrides.authenticationChallengeResponse_createAsync =
          (
            UrlSessionAuthChallengeDisposition disposition,
            URLCredential? credential,
          ) async {
            return AuthenticationChallengeResponse.pigeon_detached(
              disposition:
                  UrlSessionAuthChallengeDisposition.performDefaultHandling,
            );
          };
      final iosNavigationDelegate = WebKitNavigationDelegate(
        const WebKitNavigationDelegateCreationParams(),
      );

      String? callbackHost;
      String? callbackRealm;

      await iosNavigationDelegate.setOnHttpAuthRequest((
        HttpAuthRequest request,
      ) {
        callbackHost = request.host;
        callbackRealm = request.realm;
        request.onCancel();
      });

      const expectedHost = 'expectedHost';
      const expectedRealm = 'expectedRealm';

      final mockChallenge = MockURLAuthenticationChallenge();
      when(mockChallenge.getProtectionSpace()).thenAnswer((_) {
        return Future<URLProtectionSpace>.value(
          URLProtectionSpace.pigeon_detached(
            port: 0,
            host: expectedHost,
            realm: expectedRealm,
            authenticationMethod: NSUrlAuthenticationMethod.httpBasic,
          ),
        );
      });

      await CapturingNavigationDelegate.lastCreatedDelegate
          .didReceiveAuthenticationChallenge(
            WKNavigationDelegate.pigeon_detached(
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
                );
              },
            ),
            WKWebView.pigeon_detached(),
            mockChallenge,
          );

      expect(callbackHost, expectedHost);
      expect(callbackRealm, expectedRealm);
    });

    test('onHttpNtlmAuthRequest emits host and realm', () async {
      const expectedUser = 'user';
      const expectedPassword = 'password';
      const UrlCredentialPersistence expectedPersistence =
          UrlCredentialPersistence.forSession;

      PigeonOverrides.wKNavigationDelegate_new =
          CapturingNavigationDelegate.new;
      PigeonOverrides.authenticationChallengeResponse_createAsync =
          (
            UrlSessionAuthChallengeDisposition disposition,
            URLCredential? credential,
          ) async {
            return AuthenticationChallengeResponse.pigeon_detached(
              disposition: disposition,
              credential: credential,
            );
          };
      PigeonOverrides.uRLCredential_withUserAsync =
          (
            String user,
            String password,
            UrlCredentialPersistence persistence,
          ) async {
            expect(user, expectedUser);
            expect(password, expectedPassword);
            expect(persistence, expectedPersistence);
            return URLCredential.pigeon_detached();
          };
      final iosNavigationDelegate = WebKitNavigationDelegate(
        const WebKitNavigationDelegateCreationParams(),
      );

      String? callbackHost;
      String? callbackRealm;

      await iosNavigationDelegate.setOnHttpAuthRequest((
        HttpAuthRequest request,
      ) {
        callbackHost = request.host;
        callbackRealm = request.realm;
        request.onProceed(
          const WebViewCredential(
            user: expectedUser,
            password: expectedPassword,
          ),
        );
      });

      const expectedHost = 'expectedHost';
      const expectedRealm = 'expectedRealm';

      final mockChallenge = MockURLAuthenticationChallenge();
      when(mockChallenge.getProtectionSpace()).thenAnswer(
        expectAsync1((_) {
          return Future<URLProtectionSpace>.value(
            URLProtectionSpace.pigeon_detached(
              port: 0,
              host: expectedHost,
              realm: expectedRealm,
              authenticationMethod: NSUrlAuthenticationMethod.httpNtlm,
            ),
          );
        }),
      );

      final AuthenticationChallengeResponse result =
          await CapturingNavigationDelegate.lastCreatedDelegate
              .didReceiveAuthenticationChallenge(
                WKNavigationDelegate.pigeon_detached(
                  decidePolicyForNavigationAction: (_, __, ___) async {
                    return NavigationActionPolicy.cancel;
                  },
                  decidePolicyForNavigationResponse: (_, __, ___) async {
                    return NavigationResponsePolicy.cancel;
                  },
                  didReceiveAuthenticationChallenge: (_, __, ___) async {
                    return AuthenticationChallengeResponse.pigeon_detached(
                      disposition: UrlSessionAuthChallengeDisposition
                          .performDefaultHandling,
                    );
                  },
                ),
                WKWebView.pigeon_detached(),
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
      const exceptionCode = 'code';
      const exceptionMessage = 'message';
      final copiedExceptions = Uint8List(0);
      final leafCertificate = SecCertificate.pigeon_detached();
      final certificateData = Uint8List(0);

      PigeonOverrides.wKNavigationDelegate_new =
          CapturingNavigationDelegate.new;
      PigeonOverrides.authenticationChallengeResponse_createAsync =
          (
            UrlSessionAuthChallengeDisposition disposition,
            URLCredential? credential,
          ) async {
            return AuthenticationChallengeResponse.pigeon_detached(
              disposition: disposition,
              credential: credential,
            );
          };
      PigeonOverrides.uRLCredential_serverTrustAsync = (_) async {
        return URLCredential.pigeon_detached();
      };
      PigeonOverrides.secTrust_evaluateWithError = (_) async {
        throw PlatformException(code: exceptionCode, message: exceptionMessage);
      };
      PigeonOverrides.secTrust_copyExceptions = (_) async => copiedExceptions;
      PigeonOverrides.secTrust_setExceptions = expectAsync2((
        _,
        Uint8List? exceptions,
      ) async {
        expect(exceptions, copiedExceptions);
        return true;
      });
      PigeonOverrides.secTrust_getTrustResult = (_) async {
        return GetTrustResultResponse.pigeon_detached(
          result: DartSecTrustResultType.recoverableTrustFailure,
          resultCode: 0,
        );
      };
      PigeonOverrides.secTrust_copyCertificateChain = (_) async {
        return <SecCertificate>[leafCertificate];
      };
      PigeonOverrides.secCertificate_copyData = (_) async => certificateData;
      final iosNavigationDelegate = WebKitNavigationDelegate(
        const WebKitNavigationDelegateCreationParams(),
      );

      var errorCompleter = Completer<PlatformSslAuthError>();
      await iosNavigationDelegate.setOnSSlAuthError((
        PlatformSslAuthError error,
      ) {
        errorCompleter.complete(error);
      });

      const port = 65;
      const host = 'host';

      final mockChallenge = MockURLAuthenticationChallenge();
      final testTrust = SecTrust.pigeon_detached();
      when(mockChallenge.getProtectionSpace()).thenAnswer((_) async {
        final mockProtectionSpace = MockURLProtectionSpace();
        when(mockProtectionSpace.port).thenReturn(port);
        when(mockProtectionSpace.host).thenReturn(host);
        when(
          mockProtectionSpace.authenticationMethod,
        ).thenReturn(NSUrlAuthenticationMethod.serverTrust);
        when(
          mockProtectionSpace.getServerTrust(),
        ).thenAnswer((_) async => testTrust);
        return mockProtectionSpace;
      });

      final testDelegate = WKNavigationDelegate.pigeon_detached(
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
          );
        },
      );
      final testWebView = WKWebView.pigeon_detached();

      Future<AuthenticationChallengeResponse> authReplyFuture =
          CapturingNavigationDelegate.lastCreatedDelegate
              .didReceiveAuthenticationChallenge(
                testDelegate,
                testWebView,
                mockChallenge,
              );

      var error = await errorCompleter.future as WebKitSslAuthError;
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
        PigeonOverrides.wKNavigationDelegate_new =
            CapturingNavigationDelegate.new;
        PigeonOverrides.authenticationChallengeResponse_createAsync =
            (
              UrlSessionAuthChallengeDisposition disposition,
              URLCredential? credential,
            ) async {
              return AuthenticationChallengeResponse.pigeon_detached(
                disposition: disposition,
                credential: credential,
              );
            };
        WebKitNavigationDelegate(
          const WebKitNavigationDelegateCreationParams(),
        );

        final mockChallenge = MockURLAuthenticationChallenge();
        when(mockChallenge.getProtectionSpace()).thenAnswer((_) async {
          final mockProtectionSpace = MockURLProtectionSpace();
          when(
            mockProtectionSpace.authenticationMethod,
          ).thenReturn(NSUrlAuthenticationMethod.httpBasic);
          return mockProtectionSpace;
        });

        final testDelegate = WKNavigationDelegate.pigeon_detached(
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
            );
          },
        );
        final testWebView = WKWebView.pigeon_detached();

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
      },
    );
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
    super.observeValue,
  }) : super.pigeon_detached() {
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
            disposition:
                UrlSessionAuthChallengeDisposition.performDefaultHandling,
          );
        },
      );
}
