// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.urllauncher;

import android.app.Activity;
import android.content.ActivityNotFoundException;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.provider.Browser;
import android.util.Log;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.VisibleForTesting;
import androidx.browser.customtabs.CustomTabsClient;
import androidx.browser.customtabs.CustomTabsIntent;
import io.flutter.plugins.urllauncher.Messages.BrowserOptions;
import io.flutter.plugins.urllauncher.Messages.UrlLauncherApi;
import io.flutter.plugins.urllauncher.Messages.WebViewOptions;
import java.util.Collections;
import java.util.Locale;
import java.util.Map;

/** Implements the Pigeon-defined interface for calls from Dart. */
final class UrlLauncher implements UrlLauncherApi {
  @VisibleForTesting
  interface IntentResolver {
    String getHandlerComponentName(@NonNull Intent intent);
  }

  private static final String TAG = "UrlLauncher";

  private final @NonNull Context applicationContext;

  private final @NonNull IntentResolver intentResolver;

  private @Nullable Activity activity;

  /**
   * Creates an instance that uses {@code intentResolver} to look up the handler for intents. This
   * is to allow injecting an alternate resolver for unit testing.
   */
  @VisibleForTesting
  UrlLauncher(@NonNull Context context, @NonNull IntentResolver intentResolver) {
    this.applicationContext = context;
    this.intentResolver = intentResolver;
  }

  UrlLauncher(@NonNull Context context) {
    this(
        context,
        intent -> {
          ComponentName componentName = intent.resolveActivity(context.getPackageManager());
          return componentName == null ? null : componentName.toShortString();
        });
  }

  void setActivity(@Nullable Activity activity) {
    this.activity = activity;
  }

  @Override
  public @NonNull Boolean canLaunchUrl(@NonNull String url) {
    Intent launchIntent = new Intent(Intent.ACTION_VIEW);
    launchIntent.setData(Uri.parse(url));
    String componentName = intentResolver.getHandlerComponentName(launchIntent);
    if (BuildConfig.DEBUG) {
      Log.i(TAG, "component name for " + url + " is " + componentName);
    }
    if (componentName == null) {
      return false;
    } else {
      // Ignore the emulator fallback activity.
      return !"{com.android.fallback/com.android.fallback.Fallback}".equals(componentName);
    }
  }

  @Override
  public @NonNull Boolean launchUrl(
      @NonNull String url,
      @NonNull Map<String, String> headers,
      @NonNull Boolean requireNonBrowser) {
    ensureActivity();
    assert activity != null;

    Intent launchIntent =
        new Intent(Intent.ACTION_VIEW)
            .setData(Uri.parse(url))
            .putExtra(Browser.EXTRA_HEADERS, extractBundle(headers));
    if (requireNonBrowser && Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
      launchIntent.addFlags(Intent.FLAG_ACTIVITY_REQUIRE_NON_BROWSER);
    }
    try {
      activity.startActivity(launchIntent);
    } catch (ActivityNotFoundException e) {
      return false;
    }

    return true;
  }

  @Override
  public @NonNull Boolean openUrlInApp(
      @NonNull String url,
      @NonNull Boolean allowCustomTab,
      @NonNull WebViewOptions webViewOptions,
      @NonNull BrowserOptions browserOptions) {
    ensureActivity();
    assert activity != null;

    Bundle headersBundle = extractBundle(webViewOptions.getHeaders());

    // Try to launch using Custom Tabs if they have the necessary functionality, unless the caller
    // specifically requested a web view.
    if (allowCustomTab && !containsRestrictedHeader(webViewOptions.getHeaders())) {
      Uri uri = Uri.parse(url);
      if (openCustomTab(activity, uri, headersBundle, browserOptions)) {
        return true;
      }
    }

    // Fall back to a web view if necessary.
    Intent launchIntent =
        WebViewActivity.createIntent(
            activity,
            url,
            webViewOptions.getEnableJavaScript(),
            webViewOptions.getEnableDomStorage(),
            headersBundle);
    try {
      activity.startActivity(launchIntent);
    } catch (ActivityNotFoundException e) {
      return false;
    }

    return true;
  }

  @Override
  public void closeWebView() {
    applicationContext.sendBroadcast(new Intent(WebViewActivity.ACTION_CLOSE));
  }

  @Override
  public @NonNull Boolean supportsCustomTabs() {
    return CustomTabsClient.getPackageName(applicationContext, Collections.emptyList()) != null;
  }

  private static boolean openCustomTab(
      @NonNull Context context,
      @NonNull Uri uri,
      @NonNull Bundle headersBundle,
      @NonNull BrowserOptions options) {
    CustomTabsIntent customTabsIntent =
        new CustomTabsIntent.Builder().setShowTitle(options.getShowTitle()).build();
    customTabsIntent.intent.putExtra(Browser.EXTRA_HEADERS, headersBundle);

    try {
      customTabsIntent.launchUrl(context, uri);
    } catch (ActivityNotFoundException ex) {
      return false;
    }
    return true;
  }

  // Checks if headers contains a CORS restricted header.
  //  https://developer.mozilla.org/en-US/docs/Glossary/CORS-safelisted_request_header
  private static boolean containsRestrictedHeader(Map<String, String> headersMap) {
    for (String key : headersMap.keySet()) {
      switch (key.toLowerCase(Locale.US)) {
        case "accept":
        case "accept-language":
        case "content-language":
        case "content-type":
          continue;
        default:
          return true;
      }
    }
    return false;
  }

  private static @NonNull Bundle extractBundle(Map<String, String> headersMap) {
    final Bundle headersBundle = new Bundle();
    for (String key : headersMap.keySet()) {
      final String value = headersMap.get(key);
      headersBundle.putString(key, value);
    }
    return headersBundle;
  }

  private void ensureActivity() {
    if (activity == null) {
      throw new Messages.FlutterError(
          "NO_ACTIVITY", "Launching a URL requires a foreground activity.", null);
    }
  }
}
