// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import android.webkit.WebChromeClient;
import androidx.annotation.NonNull;
import io.flutter.plugin.common.BinaryMessenger;
import java.util.Arrays;

/**
 * Flutter Api implementation for {@link android.webkit.WebChromeClient.FileChooserParams}.
 *
 * <p>Passes arguments of callbacks methods from a {@link
 * android.webkit.WebChromeClient.FileChooserParams} to Dart.
 */
public class FileChooserParamsFlutterApiImpl
    extends GeneratedAndroidWebView.FileChooserParamsFlutterApi {
  private final InstanceManager instanceManager;

  /**
   * Creates a Flutter api that sends messages to Dart.
   *
   * @param binaryMessenger handles sending messages to Dart
   * @param instanceManager maintains instances stored to communicate with Dart objects
   */
  public FileChooserParamsFlutterApiImpl(
      @NonNull BinaryMessenger binaryMessenger, @NonNull InstanceManager instanceManager) {
    super(binaryMessenger);
    this.instanceManager = instanceManager;
  }

  private static GeneratedAndroidWebView.FileChooserMode toFileChooserEnumData(int mode) {

    switch (mode) {
      case WebChromeClient.FileChooserParams.MODE_OPEN:
        return GeneratedAndroidWebView.FileChooserMode.OPEN;

      case WebChromeClient.FileChooserParams.MODE_OPEN_MULTIPLE:
        return GeneratedAndroidWebView.FileChooserMode.OPEN_MULTIPLE;

      case WebChromeClient.FileChooserParams.MODE_SAVE:
        return GeneratedAndroidWebView.FileChooserMode.SAVE;

      default:
        throw new IllegalArgumentException(String.format("Unsupported FileChooserMode: %d", mode));
    }
  }

  /**
   * Stores the FileChooserParams instance and notifies Dart to create a new FileChooserParams
   * instance that is attached to this one.
   */
  public void create(
      @NonNull WebChromeClient.FileChooserParams instance, @NonNull Reply<Void> callback) {
    if (!instanceManager.containsInstance(instance)) {
      create(
          instanceManager.addHostCreatedInstance(instance),
          instance.isCaptureEnabled(),
          Arrays.asList(instance.getAcceptTypes()),
          toFileChooserEnumData(instance.getMode()),
          instance.getFilenameHint(),
          callback);
    }
  }
}
