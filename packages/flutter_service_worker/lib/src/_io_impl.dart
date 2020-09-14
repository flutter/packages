// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import '../flutter_service_worker.dart';

/// An unsupported implementation of the [ServiceWorkerApi] for non-web
/// platforms.
class ServiceWorkerImpl extends ServiceWorkerApi {
  @override
  Future<void> get installPromptReady => Completer<void>().future;

  @override
  void init() {}

  @override
  Future<bool> showInstallPrompt() {
    throw UnsupportedError('showInstallPrompt is only supported on the web.');
  }

  @override
  Future<void> get newVersionReady => Completer<void>().future;

  @override
  void reload() {
    throw UnsupportedError('reload is only supported on the web.');
  }
}
