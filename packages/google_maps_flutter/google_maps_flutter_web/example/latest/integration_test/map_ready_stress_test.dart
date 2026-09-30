// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// DO NOT LAND: A/B measurement for https://github.com/flutter/flutter/issues/193452.
//
// Creates many real maps at random locations (so tiles never come from cache)
// and records, for each one, when `idle` (with a laid-out div) and
// `tilesloaded` fire. This tells apart:
//   * `tilesloaded` never fires but `idle` does -> fixed by the idle fallback.
//   * neither fires                                -> not fixed by it.
// Results are printed by the driver (see test_driver/integration_test.dart).

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps/google_maps.dart' as gmaps;
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmf;
import 'package:integration_test/integration_test.dart';
import 'package:web/web.dart' as web;

import 'resources/map_diagnostics.dart';

const int _rawMaps = 200;
const int _pluginMaps = 200;
const Duration _pluginTimeout = Duration(seconds: 10);
const Duration _perMapTimeout = Duration(seconds: 15);
const Duration _phaseBudget = Duration(seconds: 100);

final Random _random = Random();

({double lat, double lng}) _randomCenter() =>
    (lat: _random.nextDouble() * 120 - 60, lng: _random.nextDouble() * 360 - 180);

Map<String, Object?> _diag() => mapDiagnosticsMap();

bool _laidOut(web.HTMLElement div) =>
    div.isConnected && div.offsetWidth > 0 && div.offsetHeight > 0;

Map<String, Object?> _summarize(List<Map<String, Object?>> samples) {
  int count(bool Function(Map<String, Object?>) f) => samples.where(f).length;
  List<int> sorted(String key) => samples.map((s) => s[key]).whereType<int>().toList()..sort();
  Map<String, int?> stats(String key) {
    final List<int> v = sorted(key);
    if (v.isEmpty) {
      return <String, int?>{'n': 0};
    }
    return <String, int?>{
      'n': v.length,
      'p50': v[v.length ~/ 2],
      'p95': v[min(v.length - 1, (v.length * 0.95).floor())],
      'max': v.last,
    };
  }

  return <String, Object?>{
    'samples': samples.length,
    'both': count((s) => s['idleMs'] != null && s['tilesMs'] != null),
    'idleOnly': count((s) => s['idleMs'] != null && s['tilesMs'] == null),
    'tilesOnly': count((s) => s['idleMs'] == null && s['tilesMs'] != null),
    'neither': count((s) => s['idleMs'] == null && s['tilesMs'] == null),
    'idleBeforeTiles': count(
      (s) =>
          s['idleMs'] != null &&
          s['tilesMs'] != null &&
          (s['idleMs']! as int) <= (s['tilesMs']! as int),
    ),
    'unlaidOutIdle': count((s) => s.containsKey('firstIdleMs') && s['firstIdleMs'] != s['idleMs']),
    'idleMs': stats('idleMs'),
    'tilesMs': stats('tilesMs'),
    if (samples.any((s) => s.containsKey('projectionMs'))) 'projectionMs': stats('projectionMs'),
    if (samples.any((s) => s.containsKey('boundsMs'))) 'boundsMs': stats('boundsMs'),
    if (samples.any((s) => s.containsKey('readyMs'))) 'readyMs': stats('readyMs'),
  };
}

void main() {
  final IntegrationTestWidgetsFlutterBinding binding =
      IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final report = <String, Object?>{};

  setUpAll(installMapDiagnostics);

  // Set after every test, since the binding may send results before any
  // tearDownAll registered here runs.
  void publish() {
    report['resourcesByType'] = _diag()['resourcesByType'];
    binding.reportData = <String, Object?>{'gm_stress': report};
  }

  testWidgets('raw google.maps.Map readiness', (WidgetTester tester) async {
    recordBreadcrumb('stress:raw:start');
    report['mapsVersion'] = _diag()['mapsVersion'];
    final samples = <Map<String, Object?>>[];
    final anomalies = <Object?>[];
    final phase = Stopwatch()..start();

    for (var i = 0; i < _rawMaps && phase.elapsed < _phaseBudget; i++) {
      final div = web.document.createElement('div') as web.HTMLDivElement;
      div.style
        ..width = '320px'
        ..height = '240px';
      web.document.body!.append(div);

      final ({double lat, double lng}) c = _randomCenter();
      final watch = Stopwatch()..start();
      final idle = Completer<int>();
      final tiles = Completer<int>();
      final map = gmaps.Map(div, gmaps.MapOptions(center: gmaps.LatLng(c.lat, c.lng), zoom: 14));
      final StreamSubscription<void> idleSub = map.onIdle.listen((_) {
        if (!idle.isCompleted && _laidOut(div)) {
          idle.complete(watch.elapsedMilliseconds);
        }
      });
      final StreamSubscription<void> tilesSub = map.onTilesloaded.listen((_) {
        if (!tiles.isCompleted) {
          tiles.complete(watch.elapsedMilliseconds);
        }
      });

      await Future.any(<Future<Object?>>[
        Future.wait(<Future<int>>[idle.future, tiles.future]),
        Future<void>.delayed(_perMapTimeout),
      ]);

      final sample = <String, Object?>{
        'i': i,
        'idleMs': idle.isCompleted ? await idle.future : null,
        'tilesMs': tiles.isCompleted ? await tiles.future : null,
      };
      samples.add(sample);
      if (sample['idleMs'] == null || sample['tilesMs'] == null) {
        anomalies.add(<String, Object?>{
          ...sample,
          'center': <double>[c.lat, c.lng],
          'diag': _diag(),
        });
      }

      await idleSub.cancel();
      await tilesSub.cancel();
      div.remove();
    }

    report['raw'] = _summarize(samples);
    report['rawElapsedMs'] = phase.elapsedMilliseconds;
    report['rawAnomalies'] = anomalies.take(5).toList();
    recordBreadcrumb('stress:raw:done:${samples.length}');
    publish();
  });

  // `onePump` mirrors what projection_test/overlays_test do: pumpWidget, one
  // extra pump, then wait for onMapCreated without pumping further frames.
  // `keepPumping` keeps producing frames while waiting.
  for (final mode in <String>['onePump', 'keepPumping']) {
    testWidgets('plugin GoogleMap readiness ($mode)', (WidgetTester tester) async {
      recordBreadcrumb('stress:$mode:start');
      final int n = mode == 'onePump' ? _pluginMaps : _pluginMaps ~/ 4;
      final samples = <Map<String, Object?>>[];
      final anomalies = <Object?>[];
      final phase = Stopwatch()..start();

      for (var i = 0; i < n && phase.elapsed < _phaseBudget; i++) {
        final ({double lat, double lng}) c = _randomCenter();
        final created = Completer<void>();
        final watch = Stopwatch()..start();

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: Center(
              child: SizedBox(
                width: 320,
                height: 240,
                child: gmf.GoogleMap(
                  key: ValueKey<String>('$mode-$i'),
                  initialCameraPosition: gmf.CameraPosition(
                    target: gmf.LatLng(c.lat, c.lng),
                    zoom: 14,
                  ),
                  onMapCreated: (_) {
                    if (!created.isCompleted) {
                      created.complete();
                    }
                  },
                ),
              ),
            ),
          ),
        );
        await tester.pump();

        int? readyMs;
        if (mode == 'onePump') {
          try {
            await created.future.timeout(_pluginTimeout);
            readyMs = watch.elapsedMilliseconds;
          } on TimeoutException {
            readyMs = null;
          }
        } else {
          while (!created.isCompleted && watch.elapsed < _pluginTimeout) {
            await tester.pump(const Duration(milliseconds: 16));
            await Future<void>.delayed(const Duration(milliseconds: 16));
          }
          readyMs = created.isCompleted ? watch.elapsedMilliseconds : null;
        }

        // Give `tilesloaded` a chance to arrive after the plugin reported ready.
        final settle = Stopwatch()..start();
        var record = <String, Object?>{};
        while (true) {
          final List<Object?> maps = (_diag()['maps'] as List<Object?>?) ?? <Object?>[];
          record = maps.isEmpty ? <String, Object?>{} : maps.last! as Map<String, Object?>;
          if (readyMs == null ||
              settle.elapsed > _pluginTimeout ||
              (record['firstTilesloadedMs'] != null && record['firstLaidOutIdleMs'] != null)) {
            break;
          }
          await Future<void>.delayed(const Duration(milliseconds: 100));
        }

        final List<Object?> resizes = (record['resizes'] as List<Object?>?) ?? <Object?>[];
        final sample = <String, Object?>{
          'i': i,
          'readyMs': readyMs,
          'projectionMs': record['firstProjectionMs'],
          'boundsMs': record['firstBoundsMs'],
          'firstIdleMs': record['firstIdleMs'],
          'idleMs': record['firstLaidOutIdleMs'],
          'tilesMs': record['firstTilesloadedMs'],
          'layoutAtCreation': record['layoutAtCreation'],
          'everConnected': resizes.any(
            (Object? r) => (r! as Map<String, Object?>)['connected'] == true,
          ),
        };
        samples.add(sample);
        if (readyMs == null || sample['tilesMs'] == null || sample['idleMs'] == null) {
          anomalies.add(<String, Object?>{
            ...sample,
            'center': <double>[c.lat, c.lng],
            'diag': _diag(),
          });
        }

        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump();
      }

      final Map<String, Object?> summary = _summarize(samples);
      summary['notReady'] = samples.where((s) => s['readyMs'] == null).length;
      summary['neverConnected'] = samples.where((s) => s['everConnected'] != true).length;
      report['plugin_$mode'] = summary;
      report['plugin_${mode}_elapsedMs'] = phase.elapsedMilliseconds;
      report['plugin_${mode}_anomalies'] = anomalies.take(3).toList();
      recordBreadcrumb('stress:$mode:done:${samples.length}');
      publish();
    });
  }
}
