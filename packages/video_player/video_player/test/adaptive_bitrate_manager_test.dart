// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:fake_async/fake_async.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:video_player/src/adaptive_bitrate_manager.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';

void main() {
  group('AdaptiveBitrateManager', () {
    late _FakePlatform platform;
    const playerId = 42;

    setUp(() {
      platform = _FakePlatform();
    });

    AdaptiveBitrateManager createManager(FakeAsync fakeAsync) {
      return AdaptiveBitrateManager(
        playerId: playerId,
        platform: platform,
        clock: () => fakeAsync.getClock(DateTime(2024)).now(),
      );
    }

    test('startAutoAdaptiveQuality sets unlimited bandwidth initially', () {
      fakeAsync((FakeAsync async) {
        final AdaptiveBitrateManager manager = createManager(async);

        manager.startAutoAdaptiveQuality();
        async.flushMicrotasks();

        expect(
          platform.bandwidthLimits[playerId],
          AdaptiveBitrateManager.qualityUnlimited,
        );
        expect(platform.setBandwidthCalls, 1);

        manager.dispose();
      });
    });

    test('startAutoAdaptiveQuality is idempotent', () {
      fakeAsync((FakeAsync async) {
        final AdaptiveBitrateManager manager = createManager(async);

        manager.startAutoAdaptiveQuality();
        async.flushMicrotasks();
        manager.startAutoAdaptiveQuality();
        async.flushMicrotasks();

        // Only one setBandwidthLimit call — second start is a no-op.
        expect(platform.setBandwidthCalls, 1);

        manager.dispose();
      });
    });

    test('recordBufferingEvent is ignored when not monitoring', () {
      fakeAsync((FakeAsync async) {
        final AdaptiveBitrateManager manager = createManager(async);

        // Record events before monitoring starts.
        manager.recordBufferingEvent();
        manager.recordBufferingEvent();

        // Start monitoring and wait for analysis.
        manager.startAutoAdaptiveQuality();
        async.flushMicrotasks();
        async.elapse(const Duration(seconds: 10));
        async.flushMicrotasks();

        // Only the initial unlimited call — no step-down since events were
        // recorded before monitoring started.
        expect(
          platform.bandwidthLimits[playerId],
          AdaptiveBitrateManager.qualityUnlimited,
        );

        manager.dispose();
      });
    });

    test('single buffering event steps down to 1080p', () {
      fakeAsync((FakeAsync async) {
        final AdaptiveBitrateManager manager = createManager(async);

        manager.startAutoAdaptiveQuality();
        async.flushMicrotasks();

        // Advance past cooldown.
        async.elapse(const Duration(seconds: 6));
        async.flushMicrotasks();

        // Record one buffering event.
        manager.recordBufferingEvent();

        // Advance to next monitoring tick (3 seconds).
        async.elapse(const Duration(seconds: 3));
        async.flushMicrotasks();

        expect(
          platform.bandwidthLimits[playerId],
          AdaptiveBitrateManager.quality1080p,
        );

        manager.dispose();
      });
    });

    test('two buffering events step down to 720p', () {
      fakeAsync((FakeAsync async) {
        final AdaptiveBitrateManager manager = createManager(async);

        manager.startAutoAdaptiveQuality();
        async.flushMicrotasks();

        async.elapse(const Duration(seconds: 6));
        async.flushMicrotasks();

        manager.recordBufferingEvent();
        manager.recordBufferingEvent();

        async.elapse(const Duration(seconds: 3));
        async.flushMicrotasks();

        expect(
          platform.bandwidthLimits[playerId],
          AdaptiveBitrateManager.quality720p,
        );

        manager.dispose();
      });
    });

    test('four buffering events step down to 480p', () {
      fakeAsync((FakeAsync async) {
        final AdaptiveBitrateManager manager = createManager(async);

        manager.startAutoAdaptiveQuality();
        async.flushMicrotasks();

        async.elapse(const Duration(seconds: 6));
        async.flushMicrotasks();

        for (var i = 0; i < 4; i++) {
          manager.recordBufferingEvent();
        }

        async.elapse(const Duration(seconds: 3));
        async.flushMicrotasks();

        expect(
          platform.bandwidthLimits[playerId],
          AdaptiveBitrateManager.quality480p,
        );

        manager.dispose();
      });
    });

    test('six buffering events step down to 360p', () {
      fakeAsync((FakeAsync async) {
        final AdaptiveBitrateManager manager = createManager(async);

        manager.startAutoAdaptiveQuality();
        async.flushMicrotasks();

        async.elapse(const Duration(seconds: 6));
        async.flushMicrotasks();

        for (var i = 0; i < 6; i++) {
          manager.recordBufferingEvent();
        }

        async.elapse(const Duration(seconds: 3));
        async.flushMicrotasks();

        expect(
          platform.bandwidthLimits[playerId],
          AdaptiveBitrateManager.quality360p,
        );

        manager.dispose();
      });
    });

    test('cooldown prevents rapid quality changes', () {
      fakeAsync((FakeAsync async) {
        final AdaptiveBitrateManager manager = createManager(async);

        manager.startAutoAdaptiveQuality();
        async.flushMicrotasks();

        // Advance past initial cooldown and record events.
        async.elapse(const Duration(seconds: 6));
        async.flushMicrotasks();

        manager.recordBufferingEvent();

        // First analysis fires → steps down to 1080p.
        async.elapse(const Duration(seconds: 3));
        async.flushMicrotasks();
        expect(
          platform.bandwidthLimits[playerId],
          AdaptiveBitrateManager.quality1080p,
        );
        final int callsAfterFirstChange = platform.setBandwidthCalls;

        // Record more events.
        manager.recordBufferingEvent();
        manager.recordBufferingEvent();

        // Next tick is within cooldown — should NOT change bandwidth.
        async.elapse(const Duration(seconds: 3));
        async.flushMicrotasks();
        expect(platform.setBandwidthCalls, callsAfterFirstChange);

        manager.dispose();
      });
    });

    test('quality recovers after buffering decays', () {
      fakeAsync((FakeAsync async) {
        final AdaptiveBitrateManager manager = createManager(async);

        manager.startAutoAdaptiveQuality();
        async.flushMicrotasks();

        // Advance past cooldown.
        async.elapse(const Duration(seconds: 6));
        async.flushMicrotasks();

        // Cause heavy buffering → 360p.
        for (var i = 0; i < 6; i++) {
          manager.recordBufferingEvent();
        }
        async.elapse(const Duration(seconds: 3));
        async.flushMicrotasks();
        expect(
          platform.bandwidthLimits[playerId],
          AdaptiveBitrateManager.quality360p,
        );

        // Let decay run with no new events. Each cycle multiplies by 0.7:
        // 6→4 (after first analysis above), then 4→2, then 2→1, then 1→0
        // We need multiple cycles past the cooldown for the quality to recover.
        // Advance past cooldown (5s) + multiple monitoring intervals.
        async.elapse(const Duration(seconds: 30));
        async.flushMicrotasks();

        // After enough decay cycles with no new buffering events,
        // the quality should have recovered toward unlimited.
        final int? finalLimit = platform.bandwidthLimits[playerId];
        expect(
          finalLimit == AdaptiveBitrateManager.qualityUnlimited ||
              finalLimit == AdaptiveBitrateManager.quality1080p ||
              finalLimit == AdaptiveBitrateManager.quality720p,
          isTrue,
          reason:
              'Quality should recover after buffering decays, '
              'got limit: $finalLimit',
        );

        manager.dispose();
      });
    });

    test('dispose stops the monitoring timer', () {
      fakeAsync((FakeAsync async) {
        final AdaptiveBitrateManager manager = createManager(async);

        manager.startAutoAdaptiveQuality();
        async.flushMicrotasks();
        final int callsBeforeDispose = platform.setBandwidthCalls;

        manager.dispose();

        // Record events and advance time — nothing should fire.
        manager.recordBufferingEvent();
        async.elapse(const Duration(seconds: 60));
        async.flushMicrotasks();

        expect(platform.setBandwidthCalls, callsBeforeDispose);
      });
    });

    test('platform error during start prevents monitoring', () {
      fakeAsync((FakeAsync async) {
        platform.failOnSetBandwidth = true;
        final AdaptiveBitrateManager manager = createManager(async);

        manager.startAutoAdaptiveQuality();
        async.flushMicrotasks();

        // Record events and advance time — nothing should fire since
        // monitoring failed to start.
        manager.recordBufferingEvent();
        async.elapse(const Duration(seconds: 10));
        async.flushMicrotasks();

        // Only the one failed call, no subsequent calls.
        expect(platform.setBandwidthCalls, 1);

        manager.dispose();
      });
    });

    test('platform error during adjustment is silently ignored', () {
      fakeAsync((FakeAsync async) {
        final AdaptiveBitrateManager manager = createManager(async);

        manager.startAutoAdaptiveQuality();
        async.flushMicrotasks();

        // Advance past cooldown.
        async.elapse(const Duration(seconds: 6));
        async.flushMicrotasks();

        // Now make future calls fail.
        platform.failOnSetBandwidth = true;

        manager.recordBufferingEvent();
        async.elapse(const Duration(seconds: 3));
        async.flushMicrotasks();

        // Should not throw — error is silently caught.
        // The bandwidth limit in the platform won't be updated since it threw,
        // but monitoring continues.
        manager.dispose();
      });
    });

    test('quality thresholds are correct constants', () {
      expect(AdaptiveBitrateManager.quality360p, 500000);
      expect(AdaptiveBitrateManager.quality480p, 800000);
      expect(AdaptiveBitrateManager.quality720p, 1200000);
      expect(AdaptiveBitrateManager.quality1080p, 2500000);
      expect(AdaptiveBitrateManager.qualityUnlimited, 0);
    });
  });
}

/// Minimal fake platform that only implements [setBandwidthLimit].
class _FakePlatform extends VideoPlayerPlatform {
  final Map<int, int> bandwidthLimits = <int, int>{};
  int setBandwidthCalls = 0;
  bool failOnSetBandwidth = false;

  @override
  Future<void> setBandwidthLimit(int playerId, int maxBandwidthBps) async {
    setBandwidthCalls++;
    if (failOnSetBandwidth) {
      throw Exception('setBandwidthLimit failed');
    }
    bandwidthLimits[playerId] = maxBandwidthBps;
  }

  // -- Unused stubs required by VideoPlayerPlatform. --

  @override
  Future<int?> create(DataSource dataSource) async => 0;

  @override
  Future<void> dispose(int playerId) async {}

  @override
  Future<void> init() async {}

  @override
  Stream<VideoEvent> videoEventsFor(int playerId) =>
      const Stream<VideoEvent>.empty();

  @override
  Future<void> pause(int playerId) async {}

  @override
  Future<void> play(int playerId) async {}

  @override
  Future<Duration> getPosition(int playerId) async => Duration.zero;

  @override
  Future<void> seekTo(int playerId, Duration position) async {}

  @override
  Future<void> setLooping(int playerId, bool looping) async {}

  @override
  Future<void> setVolume(int playerId, double volume) async {}

  @override
  Future<void> setPlaybackSpeed(int playerId, double speed) async {}

  @override
  Future<void> setMixWithOthers(bool mixWithOthers) async {}

  @override
  Widget buildView(int playerId) => const SizedBox.shrink();
}
