// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('XTypeGroup', () {
    test('toJSON() creates correct map', () {
      const extensions = <String>['txt', 'jpg'];
      const mimeTypes = <String>['text/plain'];
      const uniformTypeIdentifiers = <String>['public.plain-text'];
      const webWildCards = <String>['image/*'];
      const label = 'test group';
      const group = XTypeGroup(
        label: label,
        extensions: extensions,
        mimeTypes: mimeTypes,
        uniformTypeIdentifiers: uniformTypeIdentifiers,
        webWildCards: webWildCards,
      );

      final Map<String, dynamic> jsonMap = group.toJSON();
      expect(jsonMap['label'], label);
      expect(jsonMap['extensions'], extensions);
      expect(jsonMap['mimeTypes'], mimeTypes);
      expect(jsonMap['uniformTypeIdentifiers'], uniformTypeIdentifiers);
      expect(jsonMap['webWildCards'], webWildCards);
      // Validate the legacy key for backwards compatibility.
      expect(jsonMap['macUTIs'], uniformTypeIdentifiers);
    });

    test('a wildcard group can be created', () {
      const group = XTypeGroup(label: 'Any');

      final Map<String, dynamic> jsonMap = group.toJSON();
      expect(jsonMap['extensions'], null);
      expect(jsonMap['mimeTypes'], null);
      expect(jsonMap['uniformTypeIdentifiers'], null);
      expect(jsonMap['webWildCards'], null);
      expect(group.allowsAny, true);
    });

    test('allowsAny treats empty arrays the same as null', () {
      const group = XTypeGroup(
        label: 'Any',
        extensions: <String>[],
        mimeTypes: <String>[],
        uniformTypeIdentifiers: <String>[],
        webWildCards: <String>[],
      );

      expect(group.allowsAny, true);
    });

    test('allowsAny returns false if anything is set', () {
      const extensionOnly = XTypeGroup(
        label: 'extensions',
        extensions: <String>['txt'],
      );
      const mimeOnly = XTypeGroup(
        label: 'mime',
        mimeTypes: <String>['text/plain'],
      );
      const utiOnly = XTypeGroup(
        label: 'utis',
        uniformTypeIdentifiers: <String>['public.text'],
      );
      const webOnly = XTypeGroup(label: 'web', webWildCards: <String>['.txt']);

      expect(extensionOnly.allowsAny, false);
      expect(mimeOnly.allowsAny, false);
      expect(utiOnly.allowsAny, false);
      expect(webOnly.allowsAny, false);
    });

    group('macUTIs -> uniformTypeIdentifiers transition', () {
      test('passing only macUTIs should fill uniformTypeIdentifiers', () {
        const uniformTypeIdentifiers = <String>['public.plain-text'];
        const group = XTypeGroup(macUTIs: uniformTypeIdentifiers);

        expect(group.uniformTypeIdentifiers, uniformTypeIdentifiers);
      });

      test(
        'passing only uniformTypeIdentifiers should fill uniformTypeIdentifiers',
        () {
          const uniformTypeIdentifiers = <String>['public.plain-text'];
          const group = XTypeGroup(
            uniformTypeIdentifiers: uniformTypeIdentifiers,
          );

          expect(group.uniformTypeIdentifiers, uniformTypeIdentifiers);
        },
      );

      test('macUTIs getter return macUTIs value passed in constructor', () {
        const uniformTypeIdentifiers = <String>['public.plain-text'];
        const group = XTypeGroup(macUTIs: uniformTypeIdentifiers);

        expect(group.macUTIs, uniformTypeIdentifiers);
      });

      test(
        'macUTIs getter returns uniformTypeIdentifiers value passed in constructor',
        () {
          const uniformTypeIdentifiers = <String>['public.plain-text'];
          const group = XTypeGroup(
            uniformTypeIdentifiers: uniformTypeIdentifiers,
          );

          expect(group.macUTIs, uniformTypeIdentifiers);
        },
      );

      test('passing both uniformTypeIdentifiers and macUTIs should throw', () {
        expect(
          () => XTypeGroup(
            macUTIs: const <String>['public.plain-text'],
            uniformTypeIdentifiers: const <String>['public.plain-images'],
          ),
          throwsA(
            predicate(
              (Object? e) =>
                  e is AssertionError &&
                  e.message ==
                      'Only one of uniformTypeIdentifiers or macUTIs can be non-null',
            ),
          ),
        );
      });

      test(
        'having uniformTypeIdentifiers and macUTIs as null should leave uniformTypeIdentifiers as null',
        () {
          const group = XTypeGroup();

          expect(group.uniformTypeIdentifiers, null);
        },
      );
    });

    test('leading dots are removed from extensions', () {
      const extensions = <String>['.txt', '.jpg'];
      const group = XTypeGroup(extensions: extensions);

      expect(group.extensions, <String>['txt', 'jpg']);
    });
  });
}
