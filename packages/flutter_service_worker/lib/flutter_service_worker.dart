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
///  * https://web.dev/customize-install/
abstract class ServiceWorkerApi {
  /// Initialize the service worker API.
  ///
  /// This method should be called immediately in main, before calling
  /// [runApp].
  void init();

  /// A future that resolves when the browser will allow an "add to home screen"
  /// prompt to be shown.
  ///
  /// If the application is not compatible with a service worker installation,
  /// for example by running on http instead of https, then this future
  /// will never resolve.
  ///
  /// This installation prompt event is currently only supported on Chrome.
  /// On other browsers this future will never resolve.
  Future<InstallResponse> get installPromptReady;

  /// A future that resolves when a new version of the application is ready.
  Future<UpdateResponse> get newVersionReady;
}

/// An handler provided when a new service worker has downloaded and activated.
abstract class UpdateResponse {
  /// Reload the application.
  ///
  /// This can be used after [newVersionReady] completes to refresh the page
  /// with the new application loaded.
  void reload();
}

/// A handler provided when the browser indicates this application is
/// permitted to show an install prompt.
abstract class InstallResponse {
  /// Trigger a prompt that allows users to install their application to the
  /// device/home screen location.
  ///
  /// Returns a boolean that indicates whether the installation prompt was
  /// accepted.
  ///
  /// This installation prompt event is currently only supported on Chrome.
  /// On other browsers [installPromptReady] will never resolve.
  Future<bool> showInstallPrompt();
}

/// The singleton [ServiceWorkerApi] instance.
ServiceWorkerApi get serviceWorkerApi =>
    _serviceWorkerApi ??= ServiceWorkerImpl();
ServiceWorkerApi _serviceWorkerApi;
