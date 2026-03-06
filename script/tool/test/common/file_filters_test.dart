// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_plugin_tools/src/common/file_filters.dart';
import 'package:test/test.dart';

void main() {
  group('isRepoLevelNonCodeImpactingFile', () {
    test('returns true for known non-code files', () {
      expect(isRepoLevelNonCodeImpactingFile('AUTHORS'), isTrue);
      expect(isRepoLevelNonCodeImpactingFile('CODEOWNERS'), isTrue);
      expect(isRepoLevelNonCodeImpactingFile('CONTRIBUTING.md'), isTrue);
      expect(isRepoLevelNonCodeImpactingFile('LICENSE'), isTrue);
      expect(isRepoLevelNonCodeImpactingFile('README.md'), isTrue);
      expect(isRepoLevelNonCodeImpactingFile('AGENTS.md'), isTrue);
      expect(
        isRepoLevelNonCodeImpactingFile('.github/PULL_REQUEST_TEMPLATE.md'),
        isTrue,
      );
      expect(isRepoLevelNonCodeImpactingFile('.github/dependabot.yml'), isTrue);
      expect(isRepoLevelNonCodeImpactingFile('.github/labeler.yml'), isTrue);
      expect(
        isRepoLevelNonCodeImpactingFile('.github/post_merge_labeler.yml'),
        isTrue,
      );
      expect(
        isRepoLevelNonCodeImpactingFile('.github/workflows/release.yml'),
        isTrue,
      );
      expect(
        isRepoLevelNonCodeImpactingFile(
          '.github/workflows/pull_request_label.yml',
        ),
        isTrue,
      );
      expect(
        isRepoLevelNonCodeImpactingFile(
          '.github/workflows/batch_release_pr.yml',
        ),
        isTrue,
      );
      expect(
        isRepoLevelNonCodeImpactingFile(
          '.github/workflows/go_router_batch.yml',
        ),
        isTrue,
      );
      expect(
        isRepoLevelNonCodeImpactingFile('.github/workflows/ci.yml'),
        isTrue,
      );
      expect(
        isRepoLevelNonCodeImpactingFile(
          '.github/workflows/any_new_workflow.yml',
        ),
        isTrue,
      );
    });

    test('returns true for .gemini/ files', () {
      expect(isRepoLevelNonCodeImpactingFile('.gemini/foo'), isTrue);
      expect(isRepoLevelNonCodeImpactingFile('.gemini/bar/baz'), isTrue);
    });

    test('returns false for other files', () {
      expect(isRepoLevelNonCodeImpactingFile('pubspec.yaml'), isFalse);
      expect(isRepoLevelNonCodeImpactingFile('lib/main.dart'), isFalse);
    });
  });
}
