// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
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

  testWidgets('disposing authenticated playback aborts a stalled media server', (
    WidgetTester tester,
  ) async {
    final HttpServer server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    addTearDown(() => server.close(force: true));
    final arrived = Completer<void>();
    server.listen((HttpRequest request) {
      if (!arrived.isCompleted) {
        arrived.complete();
      }
    });
    final controller = VideoPlayerController.networkUrl(
      Uri.parse('http://127.0.0.1:${server.port}/media'),
      httpHeaders: <String, String>{'Authorization': 'fixture'},
    );
    unawaited(controller.initialize().catchError((Object _) {}));
    await arrived.future.timeout(const Duration(seconds: 10));
    await controller.dispose().timeout(const Duration(seconds: 5));
    final next = VideoPlayerController.asset('assets/windows_tracks.mp4');
    addTearDown(next.dispose);
    await next.initialize().timeout(const Duration(seconds: 15));
    expect(next.value.isInitialized, isTrue);
  }, skip: !Platform.isWindows);

  testWidgets('authenticated HTTP supports seek and independent audio/video selection', (
    WidgetTester tester,
  ) async {
    final ByteData asset = await rootBundle.load('assets/windows_tracks.mp4');
    final Uint8List bytes = asset.buffer.asUint8List(asset.offsetInBytes, asset.lengthInBytes);
    final HttpServer server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    addTearDown(() => server.close(force: true));
    final received = <Map<String, String?>>[];
    server.listen((HttpRequest request) async {
      received.add(<String, String?>{
        'authorization': request.headers.value('authorization'),
        'x-media-token': request.headers.value('x-media-token'),
        'range': request.headers.value('range'),
      });
      if (request.headers.value('authorization') != 'Bearer fixture' ||
          request.headers.value('x-media-token') != 'custom-value') {
        request.response.statusCode = HttpStatus.unauthorized;
      } else if (request.uri.path == '/redirect') {
        request.response.statusCode = HttpStatus.temporaryRedirect;
        request.response.headers.set('location', '/media.mp4');
      } else {
        request.response.headers.contentType = ContentType('video', 'mp4');
        request.response.headers.set('accept-ranges', 'bytes');
        final String? range = request.headers.value('range');
        final RegExpMatch? match = range == null
            ? null
            : RegExp(r'bytes=(\d+)-(\d*)').firstMatch(range);
        final int start = match == null ? 0 : int.parse(match[1]!);
        final int end = match == null || match[2]!.isEmpty
            ? bytes.length - 1
            : int.parse(match[2]!);
        request.response.statusCode = match == null ? HttpStatus.ok : HttpStatus.partialContent;
        if (match != null) {
          request.response.headers.set('content-range', 'bytes $start-$end/${bytes.length}');
        }
        request.response.contentLength = end - start + 1;
        if (request.method != 'HEAD') {
          request.response.add(bytes.sublist(start, end + 1));
        }
      }
      await request.response.close();
    });
    final controller = VideoPlayerController.networkUrl(
      Uri.parse('http://127.0.0.1:${server.port}/redirect'),
      httpHeaders: <String, String>{
        'Authorization': 'Bearer fixture',
        'X-Media-Token': 'custom-value',
      },
    );
    addTearDown(controller.dispose);
    await controller.initialize().timeout(const Duration(seconds: 20));
    await controller.setVolume(0);
    final List<VideoAudioTrack> audio = await controller.getAudioTracks();
    final List<VideoTrack> video = await controller.getVideoTracks();
    expect(audio, hasLength(2));
    expect(video, hasLength(2));

    // The red stream's 2:1 pixel aspect ratio doubles its encoded width.
    expect(video.singleWhere((VideoTrack t) => t.height == 120).width, 320);
    expect(audio.where((VideoAudioTrack t) => t.isSelected), hasLength(1));
    expect(video.where((VideoTrack t) => t.isSelected), hasLength(1));
    final VideoTrack originalVideo = video.singleWhere((VideoTrack t) => t.isSelected);
    final VideoTrack otherVideo = video.singleWhere((VideoTrack t) => !t.isSelected);
    final VideoAudioTrack otherAudio = audio.singleWhere((VideoAudioTrack t) => !t.isSelected);

    final GlobalKey<State<StatefulWidget>> key = GlobalKey();
    await tester.pumpWidget(
      MaterialApp(
        home: RepaintBoundary(
          key: key,
          child: SizedBox(width: 320, height: 180, child: VideoPlayer(controller)),
        ),
      ),
    );

    Future<List<int>> pixel() async {
      await tester.pump(const Duration(milliseconds: 700));
      final boundary = key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage();
      final ByteData data = (await image.toByteData())!;
      final int offset = ((image.height ~/ 2) * image.width + image.width ~/ 2) * 4;
      final color = <int>[data.getUint8(offset), data.getUint8(offset + 2)];
      image.dispose();
      return color;
    }

    await controller.play();
    final List<int> initial = await pixel();
    final originalChannel = originalVideo.height == 120 ? 0 : 1;
    expect(initial[originalChannel], greaterThan(initial[1 - originalChannel] + 100));

    await controller.selectAudioTrack(otherAudio.id);
    expect(
      (await controller.getAudioTracks()).singleWhere((VideoAudioTrack t) => t.isSelected).id,
      otherAudio.id,
    );
    expect(
      (await controller.getVideoTracks()).singleWhere((VideoTrack t) => t.isSelected).id,
      originalVideo.id,
    );
    await controller.selectVideoTrack(otherVideo);
    expect(
      controller.value.size,
      Size(otherVideo.width!.toDouble(), otherVideo.height!.toDouble()),
    );
    final List<int> switched = await pixel();
    expect(switched[1 - originalChannel], greaterThan(switched[originalChannel] + 100));
    expect(
      (await controller.getAudioTracks()).singleWhere((VideoAudioTrack t) => t.isSelected).id,
      otherAudio.id,
    );
    await controller.seekTo(const Duration(seconds: 4));
    await tester.pump(const Duration(milliseconds: 600));
    expect(controller.value.position, greaterThanOrEqualTo(const Duration(seconds: 4)));
    await controller.pause();
    await expectLater(controller.selectAudioTrack('999999'), throwsA(isA<PlatformException>()));
    await expectLater(
      controller.selectAudioTrack(otherVideo.id),
      throwsA(isA<PlatformException>()),
    );
    expect(
      (await controller.getAudioTracks()).singleWhere((VideoAudioTrack t) => t.isSelected).id,
      otherAudio.id,
    );
    await controller.selectVideoTrack(null);
    expect(
      controller.value.size,
      Size(originalVideo.width!.toDouble(), originalVideo.height!.toDouble()),
    );
    await controller.seekTo(const Duration(seconds: 1));
    await controller.play();
    final List<int> restored = await pixel();
    expect(restored[originalChannel], greaterThan(restored[1 - originalChannel] + 100));
    expect(controller.value.hasError, isFalse);
    expect(received, isNotEmpty);
    expect(
      received.every(
        (Map<String, String?> r) =>
            r['authorization'] == 'Bearer fixture' && r['x-media-token'] == 'custom-value',
      ),
      isTrue,
    );
    expect(received.any((Map<String, String?> r) => r['range'] != null), isTrue);
    await tester.pumpWidget(const SizedBox.shrink());

    final denied = VideoPlayerController.networkUrl(
      Uri.parse('http://127.0.0.1:${server.port}/media.mp4'),
      httpHeaders: <String, String>{'Authorization': 'wrong'},
    );
    addTearDown(denied.dispose);
    await expectLater(
      denied.initialize().timeout(const Duration(seconds: 15)),
      throwsA(isA<PlatformException>()),
    );
  }, skip: !Platform.isWindows);
}
