// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// Returns true for repository-level paths of files that do not affect *any*
/// code-related commands (example builds, Dart analysis, native code analysis,
/// native tests, Dart tests, etc.) for use in command-ignored-files lists for
/// commands that are only affected by package code.
bool isRepoLevelNonCodeImpactingFile(String path) {
  return <String>[
        'AUTHORS',
        'CODEOWNERS',
        'CONTRIBUTING.md',
        'LICENSE',
        'README.md',
        'AGENTS.md',
        // This deliberate lists specific files rather than excluding the whole
        // .github directory since it's better to have false negatives than to
        // accidentally skip tests if something is later added to the directory
        // that could affect packages.
        '.github/PULL_REQUEST_TEMPLATE.md',
        '.github/dependabot.yml',
        '.github/labeler.yml',
        '.github/post_merge_labeler.yml',
        '.github/workflows/pull_request_label.yml',
      ].contains(path) ||
      // This directory only affects automated code reviews, so cannot affect
      // any package tests.
      path.startsWith('.gemini/');
}

/// Returns true for native (non-Dart) code files, for use in command-ignored-
/// files lists for commands that aren't affected by native code (e.g., Dart
/// analysis and unit tests).
bool isNativeCodeFile(String path) {
  return path.endsWith('.c') ||
      path.endsWith('.cc') ||
      path.endsWith('.cpp') ||
      path.endsWith('.h') ||
      path.endsWith('.m') ||
      path.endsWith('.swift') ||
      path.endsWith('.java') ||
      path.endsWith('.kt');
}

/// Returns true for package-level human-focused support files, for use in
/// command-ignored-files lists for commands that aren't affected by files that
/// aren't used in any builds.
///
/// This must *not* include metadata files that do affect builds, such as
/// pubspec.yaml.
bool isPackageSupportFile(String path) {
  return path.endsWith('/AUTHORS') ||
      path.endsWith('/CHANGELOG.md') ||
      path.endsWith('/CONTRIBUTING.md') ||
      path.endsWith('/README.md');
}
