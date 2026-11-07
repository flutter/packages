// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

Future<void> main(List<String> arguments) async {
  final String executable = arguments.isEmpty ? 'ffmpeg' : arguments.single;
  final Directory temporary = await Directory.systemTemp.createTemp('adaptive_fixture_');
  Future<void> encode(List<String> arguments) async {
    final ProcessResult result = await Process.run(executable, <String>[
      '-y',
      '-hide_banner',
      '-loglevel',
      'error',
      ...arguments,
    ], workingDirectory: temporary.path);
    if (result.exitCode != 0) {
      throw ProcessException(executable, arguments, result.stderr.toString(), result.exitCode);
    }
  }

  try {
    await Directory('${temporary.path}/hls').create();
    await Directory('${temporary.path}/dash').create();
    await File('${temporary.path}/hls/key.bin').writeAsBytes(List<int>.generate(16, (int i) => i));

    // The key URI is relative to each nested variant playlist, not the master.
    await File(
      '${temporary.path}/key-info',
    ).writeAsString('../key.bin\n${temporary.path}/hls/key.bin\n');

    const inputs = <String>[
      '-f',
      'lavfi',
      '-i',
      'color=c=red:s=160x90:r=10:d=60',
      '-f',
      'lavfi',
      '-i',
      'color=c=blue:s=320x180:r=10:d=60',
      '-f',
      'lavfi',
      '-i',
      'sine=frequency=440:sample_rate=44100:duration=60',
    ];
    const encoding = <String>[
      '-c:v',
      'libx264',
      '-preset',
      'ultrafast',
      '-pix_fmt',
      'yuv420p',
      '-g',
      '20',
      '-sc_threshold',
      '0',
      '-c:a',
      'aac',
      '-b:a',
      '32k',
    ];
    for (final (int index, String name) in <(int, String)>[(0, 'low'), (1, 'high')]) {
      await Directory('${temporary.path}/hls/$name').create();
      await encode(<String>[
        ...inputs,
        '-map',
        '$index:v',
        '-map',
        '2:a',
        ...encoding,
        '-hls_time',
        '2',
        '-hls_playlist_type',
        'vod',
        '-hls_flags',
        'independent_segments',
        '-hls_key_info_file',
        'key-info',
        'hls/$name/index.m3u8',
      ]);
    }
    await File('${temporary.path}/hls/master.m3u8').writeAsString(
      '#EXTM3U\n'
      '#EXT-X-STREAM-INF:BANDWIDTH=200000,RESOLUTION=160x90\nlow/index.m3u8\n'
      '#EXT-X-STREAM-INF:BANDWIDTH=600000,RESOLUTION=320x180\nhigh/index.m3u8\n',
    );
    await encode(<String>[
      ...inputs,
      '-map',
      '0:v',
      '-map',
      '1:v',
      '-map',
      '2:a',
      ...encoding,
      '-b:v:0',
      '150k',
      '-b:v:1',
      '500k',
      '-f',
      'dash',
      '-seg_duration',
      '2',
      '-adaptation_sets',
      'id=0,streams=v id=1,streams=a',
      'dash/manifest.mpd',
    ]);
    final files = <String, String>{};
    for (final directory in <String>['hls', 'dash']) {
      await for (final FileSystemEntity entry in Directory(
        '${temporary.path}/$directory',
      ).list(recursive: true)) {
        if (entry is File) {
          files[entry.path.substring(temporary.path.length).replaceAll(r'\', '/')] = base64Encode(
            await entry.readAsBytes(),
          );
        }
      }
    }
    await File(
      'example/assets/adaptive_streams.json.gz',
    ).writeAsBytes(gzip.encode(utf8.encode(jsonEncode(files))));
  } finally {
    await temporary.delete(recursive: true);
  }
}
