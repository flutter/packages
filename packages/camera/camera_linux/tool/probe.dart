// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: avoid_print

// Diagnostic: lists devices, streams from the default one for a few seconds
// and writes the frames it received as JPEG files.
//
//   dart run tool/probe.dart [output_dir] [seconds]

import 'dart:io';
import 'dart:typed_data';

import 'package:camera_linux/src/v4l2_camera.dart';

void main(List<String> args) async {
  final outDir = Directory(args.isNotEmpty ? args[0] : 'probe_out')..createSync(recursive: true);
  final int seconds = args.length > 1 ? int.parse(args[1]) : 3;

  final List<V4l2Device> devices = V4l2Camera.availableDevices();
  print('devices: $devices');
  if (devices.isEmpty) {
    print('no usable device');
    exit(1);
  }

  final sw = Stopwatch()..start();
  final V4l2Camera camera = V4l2Camera.open();
  print(
    'opened ${camera.devicePath} ${camera.width}x${camera.height} '
    'in ${sw.elapsedMilliseconds} ms',
  );

  var frames = 0, polls = 0, firstMs = -1, bytes = 0;
  final readTimes = <int>[];
  while (sw.elapsedMilliseconds < 1000 + seconds * 1000) {
    final t = Stopwatch()..start();
    final Uint8List? frame = camera.readJpeg();
    polls++;
    if (frame != null) {
      readTimes.add(t.elapsedMicroseconds);
      if (firstMs < 0) {
        firstMs = sw.elapsedMilliseconds;
      }
      frames++;
      bytes += frame.length;
      if (frames <= 3 || frames % 10 == 0) {
        File(
          '${outDir.path}/frame_${frames.toString().padLeft(3, '0')}.jpg',
        ).writeAsBytesSync(frame);
      }
    }
    await Future<void>.delayed(const Duration(milliseconds: 20));
  }
  camera.close();
  readTimes.sort();
  print(
    'first frame after $firstMs ms; $frames frames in $polls polls over '
    '${sw.elapsedMilliseconds} ms; '
    'avg ${frames == 0 ? 0 : bytes ~/ frames} bytes; '
    'read (convert+encode) median '
    '${readTimes.isEmpty ? 0 : readTimes[readTimes.length ~/ 2]} us, '
    'max ${readTimes.isEmpty ? 0 : readTimes.last} us',
  );
  print('running after close: ${camera.isRunning}');
}
