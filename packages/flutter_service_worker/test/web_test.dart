// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@TestOn('chrome')
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:flutter_service_worker/src/_web_impl.dart';

void main() {
  test('listens to the beforeinstallprompt on the window', () {
    final MockWindow window = MockWindow();
    ServiceWorkerImpl(window);

    verify(window.addEventListener('beforeinstallprompt', any)).called(1);
  });

  test('resolves the installPromptReady when an Event is received', () async {
    final MockWindow window = MockWindow();
    final MockEvent event = MockEvent();
    final ServiceWorkerImpl api = ServiceWorkerImpl(window);

    final void Function(Event) callback =
        verify(window.addEventListener('beforeinstallprompt', captureAny))
            .captured
            .first as void Function(Event);
    callback(event);

    verify(event.preventDefault()).called(1);
    await expectLater(api.installPromptReady, completes);
  });

  test(
      'resolves the installPromptReady when an Event is received multiple times',
      () async {
    final MockWindow window = MockWindow();
    final MockEvent event = MockEvent();
    final ServiceWorkerImpl api = ServiceWorkerImpl(window);

    final void Function(Event) callback =
        verify(window.addEventListener('beforeinstallprompt', captureAny))
            .captured
            .first as void Function(Event);
    callback(event);
    callback(event);

    verify(event.preventDefault()).called(1);
    await expectLater(api.installPromptReady, completes);
  });

  test(
      'throws an Error if showInstallPrompt is called before installPromptReady resolves',
      () {
    final MockWindow window = MockWindow();
    final ServiceWorkerImpl api = ServiceWorkerImpl(window);

    // Could be either assertion or StateError depending on mode.
    expect(() => api.showInstallPrompt(), throwsA(isA<Error>()));
  });

  test('Will invoke the install prompt and return success', () async {
    final MockWindow window = MockWindow();
    final MockEvent event = MockEvent();
    final ServiceWorkerImpl api = ServiceWorkerImpl(window);

    final void Function(Event) callback =
        verify(window.addEventListener('beforeinstallprompt', captureAny))
            .captured
            .first as void Function(Event);
    callback(event);

    await api.installPromptReady;

    when(event.prompt()).thenAnswer((_) async {});
    when(event.userChoice).thenAnswer((_) async {
      return 'accepted';
    });

    expect(await api.showInstallPrompt(), true);
  });

  test('Will invoke the install prompt and return failure', () async {
    final MockWindow window = MockWindow();
    final MockEvent event = MockEvent();
    final ServiceWorkerImpl api = ServiceWorkerImpl(window);

    final void Function(Event) callback =
        verify(window.addEventListener('beforeinstallprompt', captureAny))
            .captured
            .first as void Function(Event);
    callback(event);

    await api.installPromptReady;

    when(event.prompt()).thenAnswer((_) async {});
    when(event.userChoice).thenAnswer((_) async {
      return 'something else';
    });

    expect(await api.showInstallPrompt(), false);
  });
}

class MockWindow extends Mock implements Window {}

class MockEvent extends Mock implements Event {}
