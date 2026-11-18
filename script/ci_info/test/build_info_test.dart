// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:ci_info/build_info.dart';
import 'package:test/test.dart';

Map<String, dynamic> _tag(String key, String value) => <String, dynamic>{
  'key': key,
  'value': value,
};

void main() {
  group('buildChange', () {
    test('reads the PR and head commit of a try build', () {
      final BuildChange change = buildChange(<String, dynamic>{
        'tags': <Map<String, dynamic>>[
          _tag('buildset', 'sha/git/0123456789abcdef'),
          _tag('github_link', 'https://github.com/flutter/packages/pull/13017'),
        ],
      });

      expect(change.pr, 13017);
      expect(change.commit, '0123456789abcdef');
      expect(change.label, 'PR #13017');
      expect(change.url, 'https://github.com/flutter/packages/pull/13017');
    });

    test('reads the commit and repo of a postsubmit build', () {
      final BuildChange change = buildChange(<String, dynamic>{
        'tags': <Map<String, dynamic>>[
          _tag(
            'buildset',
            'commit/gitiles/flutter.googlesource.com/mirrors/packages/+/0123456789abcdef',
          ),
        ],
      });

      expect(change.pr, isNull);
      expect(change.repo, 'flutter/packages');
      expect(change.label, 'commit 012345678');
      expect(change.url, 'https://github.com/flutter/packages/commit/0123456789abcdef');
    });

    test('handles builds without tags', () {
      final BuildChange change = buildChange(<String, dynamic>{});

      expect(change.label, '?');
      expect(change.url, isNull);
      expect(change.toJson()['label'], '?');
    });
  });

  group('buildDate', () {
    test('prefers the end time', () {
      expect(
        buildDate(<String, dynamic>{
          'createTime': '2026-09-13T00:00:00Z',
          'startTime': '2026-09-14T00:00:00Z',
          'endTime': '2026-09-15T00:00:00Z',
        }),
        '2026-09-15',
      );
    });

    test('falls back to start or create time for running builds', () {
      expect(
        buildDate(<String, dynamic>{
          'createTime': '2026-09-13T00:00:00Z',
          'startTime': '2026-09-14T00:00:00Z',
        }),
        '2026-09-14',
      );
      expect(buildDate(<String, dynamic>{'createTime': '2026-09-13T00:00:00Z'}), '2026-09-13');
    });
  });

  group('parseBuildTime', () {
    test('accepts nanosecond precision', () {
      expect(
        parseBuildTime('2026-09-15T01:02:03.123456789Z'),
        DateTime.utc(2026, 9, 15, 1, 2, 3, 123, 456),
      );
    });

    test('returns null for missing or invalid times', () {
      expect(parseBuildTime(null), isNull);
      expect(parseBuildTime('not a time'), isNull);
    });
  });

  group('staleBuilderWarning', () {
    final now = DateTime.utc(2026, 9, 25);

    test('is null for recently active builders', () {
      expect(
        staleBuilderWarning(<String, dynamic>{'createTime': '2026-09-20T00:00:00Z'}, now: now),
        isNull,
      );
    });

    test('warns when the newest build is old', () {
      expect(
        staleBuilderWarning(<String, dynamic>{'createTime': '2026-04-10T00:00:00Z'}, now: now),
        allOf(contains('168 days old'), contains('2026-04-10')),
      );
    });

    test('is null when the time is unknown', () {
      expect(staleBuilderWarning(<String, dynamic>{}, now: now), isNull);
    });
  });
}
