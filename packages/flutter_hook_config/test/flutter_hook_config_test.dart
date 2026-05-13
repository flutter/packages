// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:flutter_hook_config/flutter_hook_config.dart';
import 'package:hooks/hooks.dart';
import 'package:test/test.dart';

void main() {
  // Absolute, OS-correct URIs so the file-path encoding round-trips on every
  // platform CI runs on.
  final Uri engineArtifactsDir = Directory.systemTemp.uri.resolve(
    'flutter_hook_config_test/engine/',
  );
  final Uri impellerc = engineArtifactsDir.resolve('impellerc');
  final Uri libtessellator = engineArtifactsDir.resolve('libtessellator');
  const engineVersion = 'a1b2c3d4e5';

  BuildInput buildInput({List<ProtocolExtension> extensions = const []}) {
    final builder = BuildInputBuilder()
      ..setupShared(
        packageRoot: Directory.systemTemp.uri.resolve('pkg/'),
        packageName: 'example',
        outputFile: Directory.systemTemp.uri.resolve('out/output.json'),
        outputDirectoryShared: Directory.systemTemp.uri.resolve('out/shared/'),
      )
      ..setupBuildInput()
      ..config.setupBuild(linkingEnabled: false);
    extensions.forEach(builder.addExtension);
    return builder.build();
  }

  test('FlutterExtension injects impellerc and libtessellator', () {
    final BuildInput input = buildInput(
      extensions: <ProtocolExtension>[
        FlutterExtension(
          engineVersion: engineVersion,
          impellerc: impellerc,
          libtessellator: libtessellator,
        ),
      ],
    );

    expect(input.config.buildForFlutter, isTrue);
    expect(input.config.flutter.engineVersion, equals(engineVersion));
    expect(input.config.flutter.impellerc, equals(impellerc));
    expect(input.config.flutter.libtessellator, equals(libtessellator));
  });

  test('buildForFlutter is false and flutter throws when the extension is '
      'absent', () {
    final BuildInput input = buildInput();

    expect(input.config.buildForFlutter, isFalse);
    expect(() => input.config.flutter, throwsStateError);
  });

  test('configuration round-trips through JSON', () {
    final BuildInput input = buildInput(
      extensions: <ProtocolExtension>[
        FlutterExtension(
          engineVersion: engineVersion,
          impellerc: impellerc,
          libtessellator: libtessellator,
        ),
      ],
    );

    final roundTripped = BuildInput(Map<String, Object?>.from(input.json));

    expect(roundTripped.config.buildForFlutter, isTrue);
    expect(roundTripped.config.flutter.engineVersion, equals(engineVersion));
    expect(roundTripped.config.flutter.impellerc, equals(impellerc));
    expect(roundTripped.config.flutter.libtessellator, equals(libtessellator));
  });

  test('engineVersion participates in the hook config JSON', () {
    BuildInput buildWithVersion(String version) => buildInput(
      extensions: <ProtocolExtension>[
        FlutterExtension(
          engineVersion: version,
          impellerc: impellerc,
          libtessellator: libtessellator,
        ),
      ],
    );

    final BuildInput a = buildWithVersion('engine-rev-A');
    final BuildInput b = buildWithVersion('engine-rev-B');

    expect(
      a.config.flutter.engineVersion,
      isNot(equals(b.config.flutter.engineVersion)),
    );
    expect(a.json, isNot(equals(b.json)));
  });
}
