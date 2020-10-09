// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import '../flutter_service_worker.dart';

/// An unsupported implementation of the [ServiceWorkerApi] for non-web
/// platforms.
class ServiceWorkerImpl extends ServiceWorkerApi {
  @override
  Future<InstallResponse> get installPromptReady => Completer<void>().future;

  @override
  void init() {}

  @override
  Future<UpdateResponse> get newVersionReady => Completer<void>().future;
}
