// Guards the OpenGL ES texture-origin compatibility contract in shaders/.
//
// Flutter 3.46 (PR #186556) made Impeller's GLES backend store
// render-to-texture content top-down, matching Metal and Vulkan. Shaders that
// still compensate with `uv.y = 1.0 - uv.y` under a bare
// `#ifdef IMPELLER_TARGET_OPENGLES` mirror every sample vertically on GLES —
// the regression reported in issue #201 (garbled GlassTabbar on the Pixel 9
// emulator, which falls back to Impeller GLES while physical devices run
// Vulkan).
//
// The correct guard is `LGR_GLES_FLIP_SAMPLE_Y` from shaders/gles_compat.glsl,
// which is only defined when the toolchain is a pre-3.46 SDK that still needs
// the flip. See that header for the full explanation.
//
// This is a source-level test on purpose. The defect only manifests on the GLES
// backend, which `flutter test` never exercises — it renders through Skia. A
// widget or golden test therefore cannot catch it, but a grep over the shader
// sources can, and it costs nothing.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GLES texture-origin compatibility', () {
    final shaderDir = Directory('shaders');

    test('shaders/ is discoverable from the test working directory', () {
      expect(
        shaderDir.existsSync(),
        isTrue,
        reason: 'Expected to run with the package root as cwd.',
      );
    });

    test('gles_compat.glsl gates the flip on the deprecation macro', () {
      final header = File('shaders/gles_compat.glsl');
      expect(header.existsSync(), isTrue);

      final source = header.readAsStringSync();

      // Both halves of the condition matter. Dropping IMPELLER_TARGET_OPENGLES
      // would flip on every backend; dropping the UNFLIPPED_DEPRECATED negation
      // would reintroduce #201 on Flutter 3.46+.
      expect(
        source,
        contains('IMPELLER_TARGET_OPENGLES'),
        reason: 'The flip must remain scoped to the GLES stages.',
      );
      expect(
        source,
        contains('!defined(IMPELLER_OPENGLES_UNFLIPPED_DEPRECATED)'),
        reason: 'The flip must be suppressed on Flutter 3.46+, which '
            'no longer stores GLES render targets bottom-up.',
      );
      expect(source, contains('#define LGR_GLES_FLIP_SAMPLE_Y'));
    });

    test('no shader guards a Y-flip on a bare IMPELLER_TARGET_OPENGLES', () {
      final offenders = <String>[];

      for (final entity in shaderDir.listSync()) {
        if (entity is! File) continue;
        final path = entity.path.replaceAll(r'\', '/');
        if (!path.endsWith('.frag') && !path.endsWith('.glsl')) continue;
        // The compat header is the one place allowed to name the raw macro.
        if (path.endsWith('gles_compat.glsl')) continue;

        final lines = entity.readAsLinesSync();
        for (var i = 0; i < lines.length; i++) {
          final line = lines[i];
          if (!line.contains('IMPELLER_TARGET_OPENGLES')) continue;
          // A comment referring to the macro by name is fine; a preprocessor
          // conditional branching on it directly is not.
          final trimmed = line.trimLeft();
          if (!trimmed.startsWith('#')) continue;
          offenders.add('$path:${i + 1}: $trimmed');
        }
      }

      expect(
        offenders,
        isEmpty,
        reason: 'These shaders branch on IMPELLER_TARGET_OPENGLES directly. '
            'Use LGR_GLES_FLIP_SAMPLE_Y (shaders/gles_compat.glsl) so the '
            'compensation is skipped on Flutter 3.46+:\n'
            '${offenders.join('\n')}',
      );
    });

    test('every shader that flips a sampling UV includes gles_compat.glsl', () {
      final missing = <String>[];

      for (final entity in shaderDir.listSync()) {
        if (entity is! File) continue;
        final path = entity.path.replaceAll(r'\', '/');
        if (!path.endsWith('.frag')) continue;

        final source = entity.readAsStringSync();
        if (!source.contains('LGR_GLES_FLIP_SAMPLE_Y')) continue;
        if (source.contains('#include "gles_compat.glsl"')) continue;
        missing.add(path);
      }

      expect(
        missing,
        isEmpty,
        reason: 'LGR_GLES_FLIP_SAMPLE_Y is undefined without the header, so '
            'the guarded branch would silently never compile in:\n'
            '${missing.join('\n')}',
      );
    });
  });
}
