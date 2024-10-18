// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import android.annotation.SuppressLint;
import android.net.http.SslCertificate;
import android.net.http.SslError;
import android.os.Build;
import android.webkit.HttpAuthHandler;
import android.webkit.SslErrorHandler;
import android.webkit.WebResourceError;
import android.webkit.WebResourceRequest;
import android.webkit.WebResourceResponse;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import androidx.annotation.NonNull;
import androidx.annotation.RequiresApi;
import androidx.webkit.WebResourceErrorCompat;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugins.webviewflutter.GeneratedAndroidWebView.WebViewClientFlutterApi;

import java.security.cert.CertificateEncodingException;
import java.security.cert.X509Certificate;
import java.text.SimpleDateFormat;
import java.util.HashMap;
import java.util.Locale;
import java.util.Objects;

/**
 * Flutter Api implementation for {@link WebViewClient}.
 *
 * <p>Passes arguments of callbacks methods from a {@link WebViewClient} to Dart.
 */
public class WebViewClientFlutterApiImpl extends WebViewClientFlutterApi {
  // To ease adding additional methods, this value is added prematurely.
  @SuppressWarnings({"unused", "FieldCanBeLocal"})
  private final BinaryMessenger binaryMessenger;

  private final InstanceManager instanceManager;
  private final WebViewFlutterApiImpl webViewFlutterApi;

  @RequiresApi(api = Build.VERSION_CODES.M)
  static GeneratedAndroidWebView.WebResourceErrorData createWebResourceErrorData(
      WebResourceError error) {
    return new GeneratedAndroidWebView.WebResourceErrorData.Builder()
        .setErrorCode((long) error.getErrorCode())
        .setDescription(error.getDescription().toString())
        .build();
  }

  @SuppressLint("RequiresFeature")
  static GeneratedAndroidWebView.WebResourceErrorData createWebResourceErrorData(
      WebResourceErrorCompat error) {
    return new GeneratedAndroidWebView.WebResourceErrorData.Builder()
        .setErrorCode((long) error.getErrorCode())
        .setDescription(error.getDescription().toString())
        .build();
  }

  static GeneratedAndroidWebView.WebResourceRequestData createWebResourceRequestData(
      WebResourceRequest request) {
    final GeneratedAndroidWebView.WebResourceRequestData.Builder requestData =
        new GeneratedAndroidWebView.WebResourceRequestData.Builder()
            .setUrl(request.getUrl().toString())
            .setIsForMainFrame(request.isForMainFrame())
            .setHasGesture(request.hasGesture())
            .setMethod(request.getMethod())
            .setRequestHeaders(
                request.getRequestHeaders() != null
                    ? request.getRequestHeaders()
                    : new HashMap<>());
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
      requestData.setIsRedirect(request.isRedirect());
    }

    return requestData.build();
  }

  static GeneratedAndroidWebView.WebResourceResponseData createWebResourceResponseData(
      WebResourceResponse response) {
    final GeneratedAndroidWebView.WebResourceResponseData.Builder responseData =
        new GeneratedAndroidWebView.WebResourceResponseData.Builder()
            .setStatusCode((long) response.getStatusCode());

    return responseData.build();
  }

  static GeneratedAndroidWebView.SslErrorData createSslErrorData(SslError error) {
      final SslCertificate certificate = error.getCertificate();
      SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ssZ", Locale.US);
      String notValidNotAfterIso8601Date = sdf.format(certificate.getValidNotAfterDate());
      String notValidNotBeforeIso8601Date = sdf.format(certificate.getValidNotBeforeDate());

      GeneratedAndroidWebView.SslCertificateData.Builder sslCertificateData =
              new GeneratedAndroidWebView.SslCertificateData.Builder()
                      .setIssuedBy(certificate.getIssuedBy().toString())
                      .setIssuedTo(certificate.getIssuedTo().toString())
                      .setValidNotAfterIso8601Date(notValidNotAfterIso8601Date)
                      .setValidNotBeforeIso8601Date(notValidNotBeforeIso8601Date);

      if (android.os.Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
          X509Certificate x509Certificate = error.getCertificate().getX509Certificate();
          if (x509Certificate != null) {
              try {
                  byte[] encoded = x509Certificate.getEncoded();
                  sslCertificateData.setX509CertificateDer(encoded);
              } catch (CertificateEncodingException e) {
                  //Do nothing
              }
          }
      }

    GeneratedAndroidWebView.SslErrorData.Builder sslErrorData =
            new GeneratedAndroidWebView.SslErrorData.Builder()
                    .setErrorTypeData(toSslErrorTypeData(error.getPrimaryError()))
                    .setCertificateData(sslCertificateData.build())
                    .setUrl(error.getUrl());

    return sslErrorData.build();
  }

 static GeneratedAndroidWebView.SslErrorTypeData toSslErrorTypeData(int error) {
    switch (error) {
        case SslError.SSL_DATE_INVALID:
            return GeneratedAndroidWebView.SslErrorTypeData.DATE_INVALID;
        case SslError.SSL_EXPIRED:
            return GeneratedAndroidWebView.SslErrorTypeData.EXPIRED;
        case SslError.SSL_IDMISMATCH:
            return GeneratedAndroidWebView.SslErrorTypeData.ID_MISMATCH;
        case SslError.SSL_NOTYETVALID:
            return GeneratedAndroidWebView.SslErrorTypeData.NOT_YET_VALID;
        case SslError.SSL_UNTRUSTED:
            return GeneratedAndroidWebView.SslErrorTypeData.UNTRUSTED;
        default:
            return GeneratedAndroidWebView.SslErrorTypeData.INVALID;
    }
  }

  /**
   * Creates a Flutter api that sends messages to Dart.
   *
   * @param binaryMessenger handles sending messages to Dart
   * @param instanceManager maintains instances stored to communicate with Dart objects
   */
  public WebViewClientFlutterApiImpl(
      @NonNull BinaryMessenger binaryMessenger, @NonNull InstanceManager instanceManager) {
    super(binaryMessenger);
    this.binaryMessenger = binaryMessenger;
    this.instanceManager = instanceManager;
    webViewFlutterApi = new WebViewFlutterApiImpl(binaryMessenger, instanceManager);
  }

  /** Passes arguments from {@link WebViewClient#onPageStarted} to Dart. */
  public void onPageStarted(
      @NonNull WebViewClient webViewClient,
      @NonNull WebView webView,
      @NonNull String urlArg,
      @NonNull Reply<Void> callback) {
    webViewFlutterApi.create(webView, reply -> {});

    final Long webViewIdentifier =
        Objects.requireNonNull(instanceManager.getIdentifierForStrongReference(webView));
    onPageStarted(getIdentifierForClient(webViewClient), webViewIdentifier, urlArg, callback);
  }

  /** Passes arguments from {@link WebViewClient#onPageFinished} to Dart. */
  public void onPageFinished(
      @NonNull WebViewClient webViewClient,
      @NonNull WebView webView,
      @NonNull String urlArg,
      @NonNull Reply<Void> callback) {
    webViewFlutterApi.create(webView, reply -> {});

    final Long webViewIdentifier =
        Objects.requireNonNull(instanceManager.getIdentifierForStrongReference(webView));
    onPageFinished(getIdentifierForClient(webViewClient), webViewIdentifier, urlArg, callback);
  }

  /** Passes arguments from {@link WebViewClient#onReceivedHttpError} to Dart. */
  public void onReceivedHttpError(
      @NonNull WebViewClient webViewClient,
      @NonNull WebView webView,
      @NonNull WebResourceRequest request,
      @NonNull WebResourceResponse response,
      @NonNull Reply<Void> callback) {
    webViewFlutterApi.create(webView, reply -> {});

    final Long webViewIdentifier = instanceManager.getIdentifierForStrongReference(webView);
    onReceivedHttpError(
        getIdentifierForClient(webViewClient),
        webViewIdentifier,
        createWebResourceRequestData(request),
        createWebResourceResponseData(response),
        callback);
  }

  /**
   * Passes arguments from {@link WebViewClient#onReceivedError(WebView, WebResourceRequest,
   * WebResourceError)} to Dart.
   */
  @RequiresApi(api = Build.VERSION_CODES.M)
  public void onReceivedRequestError(
      @NonNull WebViewClient webViewClient,
      @NonNull WebView webView,
      @NonNull WebResourceRequest request,
      @NonNull WebResourceError error,
      @NonNull Reply<Void> callback) {
    webViewFlutterApi.create(webView, reply -> {});

    final Long webViewIdentifier =
        Objects.requireNonNull(instanceManager.getIdentifierForStrongReference(webView));
    onReceivedRequestError(
        getIdentifierForClient(webViewClient),
        webViewIdentifier,
        createWebResourceRequestData(request),
        createWebResourceErrorData(error),
        callback);
  }

  /**
   * Passes arguments from {@link androidx.webkit.WebViewClientCompat#onReceivedError(WebView,
   * WebResourceRequest, WebResourceError)} to Dart.
   */
  public void onReceivedRequestError(
      @NonNull WebViewClient webViewClient,
      @NonNull WebView webView,
      @NonNull WebResourceRequest request,
      @NonNull WebResourceErrorCompat error,
      @NonNull Reply<Void> callback) {
    webViewFlutterApi.create(webView, reply -> {});

    final Long webViewIdentifier =
        Objects.requireNonNull(instanceManager.getIdentifierForStrongReference(webView));
    onReceivedRequestError(
        getIdentifierForClient(webViewClient),
        webViewIdentifier,
        createWebResourceRequestData(request),
        createWebResourceErrorData(error),
        callback);
  }

  /**
   * Passes arguments from {@link WebViewClient#onReceivedError(WebView, int, String, String)} to
   * Dart.
   */
  public void onReceivedError(
      @NonNull WebViewClient webViewClient,
      @NonNull WebView webView,
      @NonNull Long errorCodeArg,
      @NonNull String descriptionArg,
      @NonNull String failingUrlArg,
      @NonNull Reply<Void> callback) {
    webViewFlutterApi.create(webView, reply -> {});

    final Long webViewIdentifier =
        Objects.requireNonNull(instanceManager.getIdentifierForStrongReference(webView));
    onReceivedError(
        getIdentifierForClient(webViewClient),
        webViewIdentifier,
        errorCodeArg,
        descriptionArg,
        failingUrlArg,
        callback);
  }

  /**
   * Passes arguments from {@link WebViewClient#shouldOverrideUrlLoading(WebView,
   * WebResourceRequest)} to Dart.
   */
  public void requestLoading(
      @NonNull WebViewClient webViewClient,
      @NonNull WebView webView,
      @NonNull WebResourceRequest request,
      @NonNull Reply<Void> callback) {
    webViewFlutterApi.create(webView, reply -> {});

    final Long webViewIdentifier =
        Objects.requireNonNull(instanceManager.getIdentifierForStrongReference(webView));
    requestLoading(
        getIdentifierForClient(webViewClient),
        webViewIdentifier,
        createWebResourceRequestData(request),
        callback);
  }

  /**
   * Passes arguments from {@link WebViewClient#shouldOverrideUrlLoading(WebView, String)} to Dart.
   */
  public void urlLoading(
      @NonNull WebViewClient webViewClient,
      @NonNull WebView webView,
      @NonNull String urlArg,
      @NonNull Reply<Void> callback) {
    webViewFlutterApi.create(webView, reply -> {});

    final Long webViewIdentifier =
        Objects.requireNonNull(instanceManager.getIdentifierForStrongReference(webView));
    urlLoading(getIdentifierForClient(webViewClient), webViewIdentifier, urlArg, callback);
  }

  /** Passes arguments from {@link WebViewClient#doUpdateVisitedHistory} to Dart. */
  public void doUpdateVisitedHistory(
      @NonNull WebViewClient webViewClient,
      @NonNull WebView webView,
      @NonNull String url,
      boolean isReload,
      @NonNull Reply<Void> callback) {
    webViewFlutterApi.create(webView, reply -> {});

    final Long webViewIdentifier =
        Objects.requireNonNull(instanceManager.getIdentifierForStrongReference(webView));
    doUpdateVisitedHistory(
        getIdentifierForClient(webViewClient), webViewIdentifier, url, isReload, callback);
  }

  /** Passes arguments from {@link WebViewClient#onReceivedHttpAuthRequest} to Dart. */
  public void onReceivedHttpAuthRequest(
      @NonNull WebViewClient webViewClient,
      @NonNull WebView webview,
      @NonNull HttpAuthHandler httpAuthHandler,
      @NonNull String host,
      @NonNull String realm,
      @NonNull Reply<Void> callback) {
    new HttpAuthHandlerFlutterApiImpl(binaryMessenger, instanceManager)
        .create(httpAuthHandler, reply -> {});

    onReceivedHttpAuthRequest(
        Objects.requireNonNull(instanceManager.getIdentifierForStrongReference(webViewClient)),
        Objects.requireNonNull(instanceManager.getIdentifierForStrongReference(webview)),
        Objects.requireNonNull(instanceManager.getIdentifierForStrongReference(httpAuthHandler)),
        host,
        realm,
        callback);
  }

  /** Passes arguments from {@link WebViewClient#onReceivedSslError} to Dart. */
  public void onReceivedSslError(
          @NonNull WebViewClient webViewClient,
          @NonNull WebView webview,
          @NonNull SslErrorHandler sslErrorHandler,
          @NonNull SslError error,
          @NonNull Reply<Void> callback) {
    new SslErrorHandlerFlutterApiImpl(binaryMessenger, instanceManager)
            .create(sslErrorHandler, reply -> {});

    onReceivedSslError(
        Objects.requireNonNull(instanceManager.getIdentifierForStrongReference(webViewClient)),
        Objects.requireNonNull(instanceManager.getIdentifierForStrongReference(webview)),
        Objects.requireNonNull(instanceManager.getIdentifierForStrongReference(sslErrorHandler)),
        createSslErrorData(error),
        callback);
  }
  private long getIdentifierForClient(WebViewClient webViewClient) {
    final Long identifier = instanceManager.getIdentifierForStrongReference(webViewClient);
    if (identifier == null) {
      throw new IllegalStateException("Could not find identifier for WebViewClient.");
    }
    return identifier;
  }
}
