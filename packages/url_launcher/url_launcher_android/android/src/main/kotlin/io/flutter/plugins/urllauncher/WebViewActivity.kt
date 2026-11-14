// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
package io.flutter.plugins.urllauncher

import android.app.Activity
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Bundle
import android.os.Message
import android.provider.Browser
import android.view.KeyEvent
import android.webkit.WebChromeClient
import android.webkit.WebResourceRequest
import android.webkit.WebView
import android.webkit.WebView.WebViewTransport
import android.webkit.WebViewClient
import androidx.annotation.VisibleForTesting
import androidx.core.content.ContextCompat

/*  Launches WebView activity */
class WebViewActivity : Activity() {
  private val broadcastReceiver: BroadcastReceiver =
      object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent) {
          val action = intent.action
          if (ACTION_CLOSE == action) {
            finish()
          }
        }
      }

  private val webViewClient: WebViewClient =
      object : WebViewClient() {
        override fun shouldOverrideUrlLoading(view: WebView, request: WebResourceRequest): Boolean {
          view.loadUrl(request.url.toString())
          return false
        }
      }

  // Uses default (package-private) access since it's used by inner class implementations.
  lateinit var webview: WebView

  private val closeIntentFilter: IntentFilter = IntentFilter(ACTION_CLOSE)

  // Verifies that a url opened by `Window.open` has a secure url.
  internal inner class FlutterWebChromeClient : WebChromeClient() {
    override fun onCreateWindow(
        view: WebView?,
        isDialog: Boolean,
        isUserGesture: Boolean,
        resultMsg: Message
    ): Boolean {
      val webViewClient: WebViewClient =
          object : WebViewClient() {
            override fun shouldOverrideUrlLoading(
                view: WebView,
                request: WebResourceRequest
            ): Boolean {
              webview.loadUrl(request.url.toString())
              return true
            }
          }

      val newWebView = WebView(webview.context)
      newWebView.webViewClient = webViewClient

      val transport = resultMsg.obj as WebViewTransport
      transport.webView = newWebView
      resultMsg.sendToTarget()

      return true
    }
  }

  public override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    webview = WebView(this)
    setContentView(webview)
    // Get the Intent that started this activity and extract the string
    val intent = getIntent()
    val url = intent.getStringExtra(URL_EXTRA) ?: "about:blank"
    val enableJavaScript = intent.getBooleanExtra(ENABLE_JS_EXTRA, false)
    val enableDomStorage = intent.getBooleanExtra(ENABLE_DOM_EXTRA, false)
    val headersBundle = intent.getBundleExtra(Browser.EXTRA_HEADERS)

    val headersMap: Map<String, String> = extractHeaders(headersBundle)
    webview.loadUrl(url, headersMap)

    webview.settings.javaScriptEnabled = enableJavaScript
    webview.settings.domStorageEnabled = enableDomStorage

    // Open new urls inside the webview itself.
    webview.webViewClient = webViewClient

    // Multi windows is set with FlutterWebChromeClient by default to handle internal bug:
    // b/159892679.
    webview.settings.setSupportMultipleWindows(true)
    webview.webChromeClient = FlutterWebChromeClient()

    // Register receiver that may finish this Activity.
    ContextCompat.registerReceiver(
        this, broadcastReceiver, closeIntentFilter, ContextCompat.RECEIVER_EXPORTED)
  }

  override fun onDestroy() {
    super.onDestroy()
    unregisterReceiver(broadcastReceiver)
  }

  override fun onKeyDown(keyCode: Int, event: KeyEvent?): Boolean {
    if (keyCode == KeyEvent.KEYCODE_BACK && webview.canGoBack()) {
      webview.goBack()
      return true
    }
    return super.onKeyDown(keyCode, event)
  }

  companion object {
    /*
     * Use this to trigger a BroadcastReceiver inside WebViewActivity
     * that will request the current instance to finish.
     * */
    const val ACTION_CLOSE: String = "close action"

    @VisibleForTesting
    fun extractHeaders(headersBundle: Bundle?): Map<String, String> {
      if (headersBundle == null) {
        return emptyMap()
      }
      val headersMap: MutableMap<String, String> = HashMap()
      for (key in headersBundle.keySet()) {
        headersBundle.getString(key)?.let { headersMap.put(key, it) }
      }
      return headersMap
    }

    @VisibleForTesting const val URL_EXTRA: String = "url"

    @VisibleForTesting const val ENABLE_JS_EXTRA: String = "enableJavaScript"

    @VisibleForTesting const val ENABLE_DOM_EXTRA: String = "enableDomStorage"

    /* Hides the constants used to forward data to the Activity instance. */
    fun createIntent(
        context: Context,
        url: String,
        enableJavaScript: Boolean,
        enableDomStorage: Boolean,
        headersBundle: Bundle
    ): Intent {
      return Intent(context, WebViewActivity::class.java)
          .putExtra(URL_EXTRA, url)
          .putExtra(ENABLE_JS_EXTRA, enableJavaScript)
          .putExtra(ENABLE_DOM_EXTRA, enableDomStorage)
          .putExtra(Browser.EXTRA_HEADERS, headersBundle)
    }
  }
}
