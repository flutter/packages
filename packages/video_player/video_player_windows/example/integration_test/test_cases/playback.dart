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

  Future<void> waitFor(WidgetTester tester, bool Function() predicate) async {
    final DateTime deadline = DateTime.now().add(const Duration(seconds: 15));
    while (!predicate() && DateTime.now().isBefore(deadline)) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(predicate(), isTrue);
  }

  Future<Uint8List> pixels(GlobalKey key) async {
    final boundary = key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final ui.Image image = await boundary.toImage();
    final ByteData bytes = (await image.toByteData())!;
    image.dispose();
    return bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes);
  }

  testWidgets('renders asset frames and supports playback, pause, seek and rate', (
    WidgetTester tester,
  ) async {
    final controller = VideoPlayerController.asset('assets/Butterfly-209.mp4');
    addTearDown(controller.dispose);
    await controller.initialize().timeout(const Duration(seconds: 15));
    expect(controller.value.size.width, greaterThan(0));
    expect(controller.value.duration, greaterThan(Duration.zero));
    final GlobalKey key = GlobalKey();
    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: RepaintBoundary(
            key: key,
            child: SizedBox(width: 320, height: 180, child: VideoPlayer(controller)),
          ),
        ),
      ),
    );
    await controller.setVolume(0);
    await controller.play();
    await waitFor(tester, () => controller.value.position > const Duration(milliseconds: 500));
    await controller.pause();
    await tester.pump(const Duration(milliseconds: 250));
    final Uint8List first = await pixels(key);
    expect(first.toSet().length, greaterThan(10));

    final Duration paused = controller.value.position;
    await tester.pump(const Duration(milliseconds: 300));
    expect((controller.value.position - paused).inMilliseconds.abs(), lessThan(200));

    await controller.seekTo(const Duration(seconds: 3));
    await tester.pump(const Duration(milliseconds: 500));
    final Uint8List second = await pixels(key);
    expect(second, isNot(orderedEquals(first)));
    expect(
      (controller.value.position - const Duration(seconds: 3)).inMilliseconds.abs(),
      lessThan(250),
    );

    await controller.setPlaybackSpeed(1.5);
    await controller.play();
    await waitFor(tester, () => controller.value.position > const Duration(seconds: 4));
    await controller.pause();
    await tester.pumpWidget(const SizedBox.shrink());
  }, skip: !Platform.isWindows);

  testWidgets('plays a Unicode local path and completes without looping', (
    WidgetTester tester,
  ) async {
    final Directory directory = await Directory.systemTemp.createTemp('video_player_');
    addTearDown(() => directory.delete(recursive: true));
    // The literal percent must survive file-URL encoding and decoding.
    final file = File('${directory.path}/فیلم با فاصله %.mp4');
    final ByteData asset = await rootBundle.load('assets/Butterfly-209.mp4');
    await file.writeAsBytes(asset.buffer.asUint8List(asset.offsetInBytes, asset.lengthInBytes));
    final controller = VideoPlayerController.file(file);
    addTearDown(controller.dispose);
    await controller.initialize().timeout(const Duration(seconds: 15));
    await controller.setVolume(0);
    await controller.seekTo(controller.value.duration - const Duration(milliseconds: 700));
    await controller.play();
    await waitFor(tester, () => controller.value.isCompleted);
  }, skip: !Platform.isWindows);

  testWidgets('reports missing files and allows repeated disposal during loading', (
    WidgetTester tester,
  ) async {
    for (var i = 0; i < 5; i++) {
      final controller = VideoPlayerController.file(
        File('${Directory.systemTemp.path}/missing-video-$i.mp4'),
      );
      await expectLater(
        controller.initialize().timeout(const Duration(seconds: 10)),
        throwsA(isA<PlatformException>()),
      );
      await controller.dispose().timeout(const Duration(seconds: 10));
    }
    for (var i = 0; i < 5; i++) {
      final controller = VideoPlayerController.asset('assets/Butterfly-209.mp4');
      final Future<void> initialization = controller.initialize();
      await controller.dispose().timeout(const Duration(seconds: 10));
      await initialization.timeout(const Duration(seconds: 10));
    }
  }, skip: !Platform.isWindows);

  testWidgets('plays a local HTTP source', (WidgetTester tester) async {
    final ByteData asset = await rootBundle.load('assets/Butterfly-209.mp4');
    final Uint8List bytes = asset.buffer.asUint8List(asset.offsetInBytes, asset.lengthInBytes);
    final HttpServer server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    addTearDown(() => server.close(force: true));
    final StreamSubscription<HttpRequest> requests = server.listen((HttpRequest request) async {
      request.response.headers.contentType = ContentType('video', 'mp4');
      request.response.headers.set(HttpHeaders.acceptRangesHeader, 'bytes');
      final String? range = request.headers.value(HttpHeaders.rangeHeader);
      final RegExpMatch? match = range == null
          ? null
          : RegExp(r'bytes=(\d+)-(\d*)').firstMatch(range);
      final int start = match == null ? 0 : int.parse(match[1]!);
      final int end = match == null || match[2]!.isEmpty ? bytes.length - 1 : int.parse(match[2]!);
      if (match != null) {
        request.response.statusCode = HttpStatus.partialContent;
        request.response.headers.set(
          HttpHeaders.contentRangeHeader,
          'bytes $start-$end/${bytes.length}',
        );
      }
      request.response.contentLength = end - start + 1;
      if (request.method != 'HEAD') {
        request.response.add(bytes.sublist(start, end + 1));
      }
      await request.response.close();
    });
    addTearDown(requests.cancel);
    final controller = VideoPlayerController.networkUrl(
      Uri.parse('http://127.0.0.1:${server.port}/video.mp4'),
    );
    addTearDown(controller.dispose);
    await controller.initialize().timeout(const Duration(seconds: 15));
    await controller.setVolume(0);
    await controller.play();
    await waitFor(tester, () => controller.value.position > const Duration(milliseconds: 300));
  }, skip: !Platform.isWindows);

  testWidgets('looping and disposal of one player preserve another player', (
    WidgetTester tester,
  ) async {
    final first = VideoPlayerController.asset('assets/Butterfly-209.mp4');
    final second = VideoPlayerController.asset('assets/Butterfly-209.mp4');
    addTearDown(first.dispose);
    addTearDown(second.dispose);
    await Future.wait(<Future<void>>[
      first.initialize(),
      second.initialize(),
    ]).timeout(const Duration(seconds: 15));
    await first.setVolume(0);
    await second.setVolume(0);
    await first.setLooping(true);
    await first.seekTo(first.value.duration - const Duration(milliseconds: 300));
    await first.play();
    await waitFor(tester, () => first.value.position < const Duration(seconds: 1));
    expect(first.value.isCompleted, isFalse);
    expect(second.value.position, Duration.zero);
    await first.dispose();
    await second.play();
    await waitFor(tester, () => second.value.position > const Duration(milliseconds: 300));
    expect(second.value.hasError, isFalse);
  }, skip: !Platform.isWindows);
}
