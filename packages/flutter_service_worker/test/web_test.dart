// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@TestOn('chrome')
import 'package:test/test.dart';
import 'package:flutter_service_worker/src/_web_impl.dart';

void main() {
  test(
      'throws an Error if showInstallPrompt is called before installPromptReady resolves',
      () {
    final ServiceWorkerImpl api = ServiceWorkerImpl()..init();

    // Could be either assertion or StateError depending on mode.
    expect(() => api.showInstallPrompt(), throwsA(isA<Error>()));
  });
}
