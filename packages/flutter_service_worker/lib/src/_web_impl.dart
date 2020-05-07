// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@JS()
library _web_impl;

import 'dart:async';

import 'package:meta/meta.dart';
import 'package:js/js.dart';

import '../flutter_service_worker.dart';

const String _kPromptEvent = 'beforeinstallprompt';

/// An implementation of the [ServiceWorkerApi] that delegates to the JS Window
/// object.
class ServiceWorkerImpl extends ServiceWorkerApi {
  /// Create a new [ServiceWorkerImpl].
  ServiceWorkerImpl([@visibleForTesting Window overrideWindow]) {
    (overrideWindow ?? window).addEventListener(_kPromptEvent, allowInterop((Event event) {
      if (_installPromptReady.isCompleted) {
        return;
      }
      event.preventDefault();
      _installPrompt = event;
      _installPromptReady.complete();
    }));
  }

  final Completer<void> _installPromptReady = Completer<void>();
  Event _installPrompt;

  @override
  Future<void> get installPromptReady => _installPromptReady.future;

  @override
  Future<bool> showInstallPrompt() async {
    assert(_installPrompt != null,
        'The installation future needs to resolve before acceptInstallPrompt can be called');
    if (_installPrompt == null) {
      throw StateError('missing installPrompt');
    }
    _installPrompt.prompt();
    final String result = await _installPrompt.userChoice;
    return result == 'accepted';
  }
}

/// JS interop for Window access.
@visibleForTesting
@JS()
external Window get window;

/// JS interop for Window access.
@visibleForTesting
@JS()
class Window {
  /// JS interop for Event access.
  @visibleForTesting
  external void addEventListener(String name, void Function(Event) handler);
}

/// JS interop for Event access.
@visibleForTesting
@JS()
class Event {
  /// JS interop for Event access.
  @visibleForTesting
  external void preventDefault();

  /// JS interop for Event access.
  @visibleForTesting
  external void prompt();

  /// JS interop for Event access.
  @visibleForTesting
  external Future<String> get userChoice;
}
