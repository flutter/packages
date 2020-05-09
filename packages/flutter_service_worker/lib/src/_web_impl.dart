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
      _installPromptReady.complete();
    }));
    window.navigator.serviceWorker.ready
        .then((ServiceWorkerRegistration registration) {
      if (registration.waiting != null) {
        if (!_installPromptReady.isCompleted) {
          _newVersionReady.complete();
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
        if (!_installPromptReady.isCompleted) {
          _installPromptReady.complete();
        }
      }
    });
  }

  final Completer<void> _installPromptReady = Completer<void>();
  final Completer<void> _newVersionReady = Completer<void>();
  JsObject _installPrompt;

  @override
  Future<void> get installPromptReady => _installPromptReady.future;

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

  @override
  Future<void> get newVersionReady => _newVersionReady.future;

  @override
  Future<void> skipWaiting() async {
    final ServiceWorkerRegistration registration =
        await window.navigator.serviceWorker.ready;
    bool refreshing = false;
    registration.active.addEventListener('controllerchange', (_) {
      if (refreshing) {
        return;
      }
      refreshing = true;
      window.location.reload();
    });
    registration.active.postMessage(<String, Object>{'message': 'skipWaiting'});
  }

  @override
  Future<void> downloadOffline() async {
    final ServiceWorkerRegistration registration =
        await window.navigator.serviceWorker.ready;
    final Completer<void> completer = Completer<void>();
    registration.active.addEventListener('message', (Event event) {
      if (completer.isCompleted) {
        return;
      }
      completer.complete();
    });
    registration.active
        .postMessage(<String, Object>{'message': 'downloadOffline'});
    await completer.future;
  }
}
