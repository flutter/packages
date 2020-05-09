// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'src/_io_impl.dart' if (dart.library.js) 'src/_web_impl.dart';

/// An API for interacting with the service worker for application caching and
/// installation.
///
/// On platforms other than the web, this delegates to a no-op implementation.
///
/// See also:
///
///  - https://web.dev/customize-install/
abstract class ServiceWorkerApi {
  /// Initialize the service worker API.
  ///
  /// This method should be called immediate in main, before calling
  /// [runApp].
  void init();

  /// A future that resolves when it is safe to call [showInstallPrompt].
  ///
  /// If the application is not compatible with a service worker installation,
  /// for example by running on http instead of https, then this future
  /// will never resolve.
  ///
  /// This installation prompt event is currently only supported on Chrome.
  /// On other browsers this future will never resolve.
  ///
  /// Not all browsers
  Future<void> get installPromptReady;

  /// Trigger a prompt that allows users to install their application to the
  /// device/home screen location.
  ///
  /// Returns a boolean that indicates whether the installation prompt was
  /// accepted.
  ///
  /// This installation prompt event is currently only supported on Chrome.
  /// On other browsers [installPromptReady] will never resolve.
  ///
  /// Throws a [StateError] if this function is called before [installPromptReady]
  /// resolves, or if it is not called in response to a user initiated gesture.
  Future<bool> showInstallPrompt();

  /// A future that resolves when a new version of the application is ready.
  Future<void> get newVersionReady;

  /// If a new version is available, skip a waiting period and force the browser
  /// to reload.
  ///
  /// This operation is disruptive and should only be called if there are no
  /// other user activities or in response to a prompt.
  Future<void> skipWaiting();

  /// For the service worker to cache all resources files for offline use.
  Future<void> downloadOffline();
}

/// The singleton [ServiceWorkerApi] instance.
ServiceWorkerApi get serviceWorkerApi =>
    _serviceWorkerApi ??= ServiceWorkerImpl();
ServiceWorkerApi _serviceWorkerApi;
