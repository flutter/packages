// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

library _web_impl;

import 'dart:async';
import 'dart:html';
import 'dart:js';
import 'dart:js_util';

import '../flutter_service_worker.dart';

/// An implementation of the [ServiceWorkerApi] that delegates to the JS Window
/// object.
class ServiceWorkerImpl extends ServiceWorkerApi {
  @override
  void init() {
    window.addEventListener('beforeinstallprompt', allowInterop((Object event) {
      if (_installPromptReady.isCompleted) {
        return;
      }
      _installPrompt = JsObject.fromBrowserObject(event)
        ..callMethod('preventDefault');
      _installPromptReady.complete(_WebInstallResponse(_installPrompt));
    }));
    window.navigator.serviceWorker.ready
        .then((ServiceWorkerRegistration registration) {
      if (registration.waiting != null) {
        if (!_newVersionReady.isCompleted) {
          _newVersionReady.complete(_WebUpdateResponse());
        }
      }
      if (registration.installing != null) {
        _handleInstall(registration.installing);
      }
      registration.addEventListener('updatefound', (_) {
        _handleInstall(registration.installing);
      });
    });
  }

  void _handleInstall(ServiceWorker serviceWorker) {
    serviceWorker.addEventListener('statechange', (_) {
      if (serviceWorker.state == 'installed') {
        if (!_newVersionReady.isCompleted) {
          _newVersionReady.complete();
        }
      }
    });
  }

  final Completer<_WebInstallResponse> _installPromptReady =
      Completer<_WebInstallResponse>();
  final Completer<_WebUpdateResponse> _newVersionReady =
      Completer<_WebUpdateResponse>();
  JsObject _installPrompt;

  @override
  Future<InstallResponse> get installPromptReady => _installPromptReady.future;

  @override
  Future<UpdateResponse> get newVersionReady => _newVersionReady.future;
}

class _WebInstallResponse extends InstallResponse {
  _WebInstallResponse(this._installPrompt);

  final JsObject _installPrompt;

  @override
  Future<bool> showInstallPrompt() async {
    assert(_installPrompt != null,
        'The installation future needs to resolve before acceptInstallPrompt can be called');
    if (_installPrompt == null) {
      throw StateError('missing installPrompt');
    }
    try {
      await promiseToFuture<void>(_installPrompt.callMethod('prompt'));
    } catch (err) {
      throw StateError(err.toString());
    }
    final String result =
        await promiseToFuture(getProperty(_installPrompt, 'userChoice'));
    return result == 'accepted';
  }
}

class _WebUpdateResponse extends UpdateResponse {
  @override
  void reload() {
    // TODO(jonahwilliams): on Safari force refresh.
    window.location.reload();
  }
}
