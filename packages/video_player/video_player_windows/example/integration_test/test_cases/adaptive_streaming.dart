// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:video_player/video_player.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  for (final format in <String>['hls', 'dash']) {
    testWidgets('$format authenticates every resource and renders selected qualities', (
      WidgetTester tester,
    ) async {
      final _FixtureServer fixture = await _FixtureServer.open();
      addTearDown(fixture.close);
      final controller = VideoPlayerController.networkUrl(
        fixture.uri('/redirect/$format'),
        httpHeaders: <String, String>{
          'Authorization': 'Bearer fixture',
          'X-Media-Token': 'custom-value',
        },
      );
      addTearDown(controller.dispose);
      await controller.initialize().timeout(const Duration(seconds: 20));
      await controller.setVolume(0);
      final List<VideoTrack> tracks = await controller.getVideoTracks();
      expect(tracks, hasLength(2));
      tracks.sort((VideoTrack a, VideoTrack b) => a.bitrate!.compareTo(b.bitrate!));
      final GlobalKey<State<StatefulWidget>> key = GlobalKey();
      await tester.pumpWidget(
        MaterialApp(
          home: RepaintBoundary(
            key: key,
            child: SizedBox(width: 320, height: 180, child: VideoPlayer(controller)),
          ),
        ),
      );

      Future<void> expectColor(int channel) async {
        var red = 0;
        var blue = 0;
        for (var attempt = 0; attempt < 30; attempt++) {
          await tester.pump(const Duration(milliseconds: 200));
          final boundary = key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
          final ui.Image image = await boundary.toImage();
          final ByteData data = (await image.toByteData())!;
          final int offset = ((image.height ~/ 2) * image.width + image.width ~/ 2) * 4;
          red = data.getUint8(offset);
          blue = data.getUint8(offset + 2);
          image.dispose();
          if ((channel == 0 ? red - blue : blue - red) > 100) {
            return;
          }
        }
        fail(
          'The requested $format quality did not reach the rendered texture: red=$red blue=$blue position=${controller.value.position} error=${controller.value.errorDescription} requests=${fixture.paths}',
        );
      }

      await controller.play();
      await tester.pump(const Duration(seconds: 1));

      for (final (int index, int seconds) in <(int, int)>[(0, 20), (1, 40), (0, 10)]) {
        await controller.selectVideoTrack(tracks[index]);
        expect(
          (await controller.getVideoTracks())
              .singleWhere((VideoTrack track) => track.isSelected)
              .id,
          tracks[index].id,
        );
        await controller.seekTo(Duration(seconds: seconds));
        await controller.play();
        await expectColor(index == 0 ? 0 : 2);
        expect(controller.value.position, greaterThanOrEqualTo(Duration(seconds: seconds)));
      }

      await expectLater(
        controller.selectVideoTrack(const VideoTrack(id: '4294967294', isSelected: false)),
        throwsA(isA<PlatformException>()),
      );
      expect(
        (await controller.getVideoTracks()).singleWhere((VideoTrack track) => track.isSelected).id,
        tracks.first.id,
      );

      await controller.selectVideoTrack(null);
      expect(
        (await controller.getVideoTracks()).where((VideoTrack track) => track.isSelected),
        isEmpty,
      );
      await controller.seekTo(const Duration(seconds: 50));
      for (
        var attempt = 0;
        attempt < 30 && controller.value.position <= const Duration(seconds: 50);
        attempt++
      ) {
        await tester.pump(const Duration(milliseconds: 200));
      }
      expect(controller.value.position, greaterThan(const Duration(seconds: 50)));
      expect(controller.value.hasError, isFalse);
      expect(fixture.unauthorized, isEmpty);

      if (format == 'hls') {
        expect(fixture.paths, contains('/hls/key.bin'));
        expect(
          fixture.paths.any((String path) => path.startsWith('/hls/low/') && path.endsWith('.ts')),
          isTrue,
        );
        expect(
          fixture.paths.any((String path) => path.startsWith('/hls/high/') && path.endsWith('.ts')),
          isTrue,
        );
      } else {
        expect(
          fixture.paths,
          containsAll(<String>['/dash/init-stream0.m4s', '/dash/init-stream1.m4s']),
        );
        expect(fixture.paths.any((String path) => path.contains('chunk-stream0-')), isTrue);
        expect(fixture.paths.any((String path) => path.contains('chunk-stream1-')), isTrue);
      }
    }, skip: !Platform.isWindows);
  }

  testWidgets('adaptive sources seek before the first play, including a locked quality', (
    WidgetTester tester,
  ) async {
    final _FixtureServer fixture = await _FixtureServer.open();
    addTearDown(fixture.close);
    for (final path in <String>['/hls/master.m3u8', '/dash/manifest.mpd']) {
      for (final lock in <bool>[false, true]) {
        final controller = VideoPlayerController.networkUrl(
          fixture.uri(path),
          httpHeaders: <String, String>{
            'Authorization': 'Bearer fixture',
            'X-Media-Token': 'custom-value',
          },
        );
        addTearDown(controller.dispose);
        await controller.initialize().timeout(const Duration(seconds: 20));
        await controller.setVolume(0);
        if (lock) {
          final List<VideoTrack> tracks = await controller.getVideoTracks();
          tracks.sort((VideoTrack a, VideoTrack b) => a.bitrate!.compareTo(b.bitrate!));
          await controller.selectVideoTrack(tracks.first);
        }

        // Do not warm up playback here: metadata can precede the MSE buffers.
        await controller.seekTo(const Duration(seconds: 20));
        await controller.play();
        for (
          var attempt = 0;
          attempt < 30 && controller.value.position <= const Duration(seconds: 20);
          attempt++
        ) {
          await tester.pump(const Duration(milliseconds: 200));
        }
        expect(
          controller.value.position,
          greaterThan(const Duration(seconds: 20)),
          reason: '$path locked=$lock',
        );
        expect(controller.value.hasError, isFalse);
        await controller.dispose();
      }
    }
  }, skip: !Platform.isWindows);

  testWidgets(
    'adaptive authentication failure reports an error and disposal cancels a stalled segment',
    (WidgetTester tester) async {
      final _FixtureServer fixture = await _FixtureServer.open();
      addTearDown(fixture.close);
      final rejected = VideoPlayerController.networkUrl(
        fixture.uri('/hls/master.m3u8'),
        httpHeaders: <String, String>{'Authorization': 'wrong'},
      );
      await expectLater(
        rejected.initialize().timeout(const Duration(seconds: 15)),
        throwsA(isA<PlatformException>()),
      );
      await rejected.dispose();
      fixture.stallSegments = true;
      final loading = VideoPlayerController.networkUrl(
        fixture.uri('/dash/manifest.mpd'),
        httpHeaders: <String, String>{
          'Authorization': 'Bearer fixture',
          'X-Media-Token': 'custom-value',
        },
      );
      unawaited(loading.initialize().catchError((Object _) {}));
      await fixture.stalled.future.timeout(const Duration(seconds: 15));
      await loading.dispose().timeout(const Duration(seconds: 5));
    },
    skip: !Platform.isWindows,
  );
}

class _FixtureServer {
  _FixtureServer(this.server, this.files) {
    server.listen(_serve);
  }

  final HttpServer server;
  final Map<String, List<int>> files;
  final List<String> paths = <String>[];
  final List<String> unauthorized = <String>[];
  final Completer<void> stalled = Completer<void>();
  bool stallSegments = false;

  static Future<_FixtureServer> open() async {
    final ByteData asset = await rootBundle.load('assets/adaptive_streams.json.gz');
    final data =
        jsonDecode(
              utf8.decode(
                gzip.decode(asset.buffer.asUint8List(asset.offsetInBytes, asset.lengthInBytes)),
              ),
            )
            as Map<String, dynamic>;
    return _FixtureServer(
      await HttpServer.bind(InternetAddress.loopbackIPv4, 0),
      data.map(
        (String path, dynamic bytes) =>
            MapEntry<String, List<int>>(path, base64Decode(bytes as String)),
      ),
    );
  }

  Uri uri(String path) => Uri(scheme: 'http', host: '127.0.0.1', port: server.port, path: path);
  Future<void> close() async {
    await server.close(force: true);
  }

  Future<void> _serve(HttpRequest request) async {
    try {
      final String path = request.uri.path;
      paths.add(path);
      if (request.headers.value('authorization') != 'Bearer fixture' ||
          request.headers.value('x-media-token') != 'custom-value') {
        unauthorized.add(path);
        request.response.statusCode = HttpStatus.unauthorized;
      } else if (path.startsWith('/redirect/')) {
        request.response.statusCode = HttpStatus.temporaryRedirect;
        request.response.headers.set(
          'location',
          path.endsWith('hls') ? '/hls/master.m3u8' : '/dash/manifest.mpd',
        );
      } else if (stallSegments && path.contains('chunk-')) {
        if (!stalled.isCompleted) {
          stalled.complete();
        }
        return;
      } else if (!files.containsKey(path)) {
        request.response.statusCode = HttpStatus.notFound;
      } else {
        if (path.endsWith('.ts') || path.endsWith('.m4s')) {
          // Keep future segments outside the decoder's buffer so bitrate changes
          // are exercised on new downloads, not already decoded frames.
          await Future<void>.delayed(const Duration(milliseconds: 200));
        }
        final List<int> bytes = files[path]!;
        const types = <String, String>{
          '.m3u8': 'application/vnd.apple.mpegurl',
          '.mpd': 'application/dash+xml',
          '.ts': 'video/mp2t',
          '.m4s': 'video/mp4',
        };
        request.response.headers.set(
          'content-type',
          types.entries
              .firstWhere(
                (MapEntry<String, String> type) => path.endsWith(type.key),
                orElse: () => const MapEntry<String, String>('', 'application/octet-stream'),
              )
              .value,
        );
        request.response.headers.set('accept-ranges', 'bytes');
        final String? range = request.headers.value('range');
        final RegExpMatch? match = range == null
            ? null
            : RegExp(r'bytes=(\d+)-(\d*)').firstMatch(range);
        final int start = match == null ? 0 : int.parse(match[1]!);
        final int end = match == null || match[2]!.isEmpty
            ? bytes.length - 1
            : int.parse(match[2]!);
        if (match != null) {
          request.response.statusCode = HttpStatus.partialContent;
          request.response.headers.set('content-range', 'bytes $start-$end/${bytes.length}');
        }
        request.response.contentLength = end - start + 1;
        if (request.method != 'HEAD') {
          request.response.add(bytes.sublist(start, end + 1));
        }
      }
      await request.response.close();
    } on IOException {
      return;
    }
  }
}
