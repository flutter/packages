// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: avoid_print

import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:mustache_template/mustache.dart';

import 'fonts.pb.dart';

const String _generatedAllPartsFilePath =
    'lib/src/google_fonts_all_parts.g.dart';
String _generatedPartFilePath(String part) =>
    'lib/src/google_fonts_parts/part_$part.g.dart';
const String _familiesSupportedPath = 'generator/families_supported';
const String _familiesDiffPath = 'generator/families_diff';

Future<void> main() async {
  print('Getting latest font directory...');
  final Uri protoUrl = await _getProtoUrl();
  print('Success! Using $protoUrl');

  final Directory fontDirectory = await _readFontsProtoData(protoUrl);
  print('\nValidating font URLs and file contents...');
  await _verifyUrls(fontDirectory);
  print(_success);

  print('\nDetermining font families delta...');
  final familiesDelta = _FamiliesDelta(fontDirectory);
  print(_success);

  print('\nGenerating $_familiesSupportedPath & $_familiesDiffPath ...');
  File(
    _familiesSupportedPath,
  ).writeAsStringSync(familiesDelta.printableSupported());
  File(_familiesDiffPath).writeAsStringSync(familiesDelta.markdownDiff());
  print(_success);

  print('\nGenerating $_generatedAllPartsFilePath and part files...');
  _generateDartCode(fontDirectory);
  print(_success);

  print('\nFormatting $_generatedAllPartsFilePath and part files...');
  await Process.run('dart', <String>['format', 'lib']);
  print(_success);
}

const String _success = 'Success!';

/// Gets the latest font directory.
///
/// Versioned directories are hosted on the Google Fonts server. We try to fetch
/// each directory one by one until we hit the last one. We know we reached the
/// end if requesting the next version results in a 404 response.
/// Other types of failure should not occur. For example, if the internet
/// connection gets lost while downloading the directories, we just crash. But
/// that's okay for now, because the generator is only executed in trusted
/// environments by individual developers.
Future<Uri> _getProtoUrl({int initialVersion = 7}) async {
  var directoryVersion = initialVersion;

  Uri url(int directoryVersion) {
    final String paddedVersion = directoryVersion.toString().padLeft(3, '0');
    return Uri.parse(
      'https://fonts.gstatic.com/s/f/directory$paddedVersion.pb',
    );
  }

  var didReachLatestUrl = false;
  final httpClient = http.Client();
  while (!didReachLatestUrl) {
    final http.Response response = await httpClient.get(url(directoryVersion));
    if (response.statusCode == 200) {
      directoryVersion += 1;
    } else if (response.statusCode == 404) {
      didReachLatestUrl = true;
      directoryVersion -= 1;
    } else {
      throw Exception('Request failed: $response');
    }
  }
  httpClient.close();

  return url(directoryVersion);
}

Future<void> _verifyUrls(Directory fontDirectory) async {
  final int totalFonts = fontDirectory.family
      .map((FontFamily f) => f.fonts.length)
      .reduce((int a, int b) => a + b);

  final client = http.Client();
  var i = 1;
  for (final FontFamily family in fontDirectory.family) {
    for (final Font font in family.fonts) {
      final urlString =
          'https://fonts.gstatic.com/s/a/${_hashToString(font.file.hash)}.ttf';
      final Uri url = Uri.parse(urlString);
      await _tryUrl(client, url, font);
      print('Verified URL ($i/$totalFonts): $urlString');
      i += 1;
    }
  }
  client.close();
}

Future<void> _tryUrl(http.Client client, Uri url, Font font) async {
  try {
    final http.Response fileContents = await client.get(url);
    final int actualFileLength = fileContents.bodyBytes.length;
    final actualFileHash = sha256.convert(fileContents.bodyBytes).toString();
    if (font.file.fileSize != actualFileLength ||
        _hashToString(font.file.hash) != actualFileHash) {
      throw Exception('Font from $url did not match length of or checksum.');
    }
  } catch (e) {
    print('Failed to load font from url: $url');
    rethrow;
  }
}

String _hashToString(List<int> bytes) {
  var fileName = '';
  for (final byte in bytes) {
    final String convertedByte = byte.toRadixString(16).padLeft(2, '0');
    fileName += convertedByte;
  }
  return fileName;
}

// Utility class to track font family deltas.
//
// [fontDirectory] represents a possibly updated directory.
class _FamiliesDelta {
  _FamiliesDelta(Directory fontDirectory) {
    _init(fontDirectory);
  }

  late final Set<String> added;
  late final Set<String> removed;
  late final Set<String> all;

  void _init(Directory fontDirectory) {
    // Currently supported families.
    final familiesSupported = Set<String>.from(
      File(_familiesSupportedPath).readAsLinesSync(),
    );

    // Newly supported families.
    all = Set<String>.from(
      fontDirectory.family.map<String>((FontFamily item) => item.name),
    );

    added = all.difference(familiesSupported);
    removed = familiesSupported.difference(all);
  }

  // Printable list of supported font families.
  String printableSupported() => all.join('\n');

  // Diff of font families, suitable for markdown
  // (e.g. CHANGELOG, PR description).
  String markdownDiff() {
    final Iterable<String> addedPrintable = added.map(
      (String family) => '  - Added `$family`',
    );
    final Iterable<String> removedPrintable = removed.map(
      (String family) => '  - Removed `$family`',
    );

    var diff = '';
    if (removedPrintable.isNotEmpty) {
      diff += removedPrintable.join('\n');
      diff += '\n';
    }
    if (addedPrintable.isNotEmpty) {
      diff += addedPrintable.join('\n');
      diff += '\n';
    }

    return diff;
  }
}

void _generateDartCode(Directory fontDirectory) {
  final methods = <Map<String, dynamic>>[];

  for (final FontFamily item in fontDirectory.family) {
    final String family = item.name;
    final String familyNoSpaces = family.replaceAll(' ', '');
    final String familyWithPlusSigns = family.replaceAll(' ', '+');
    final String methodName = _familyToMethodName(family);

    const themeParams = <String>[
      'displayLarge',
      'displayMedium',
      'displaySmall',
      'headlineLarge',
      'headlineMedium',
      'headlineSmall',
      'titleLarge',
      'titleMedium',
      'titleSmall',
      'bodyLarge',
      'bodyMedium',
      'bodySmall',
      'labelLarge',
      'labelMedium',
      'labelSmall',
    ];

    methods.add(<String, dynamic>{
      'methodName': methodName,
      'part': methodName[0].toUpperCase(),
      'fontFamily': familyNoSpaces,
      'fontFamilyDisplay': family,
      'docsUrl': 'https://fonts.google.com/specimen/$familyWithPlusSigns',
      'fontUrls': <Map<String, Object>>[
        for (final Font variant in item.fonts)
          <String, Object>{
            'variantWeight': variant.weight.start,
            'variantStyle': variant.italic.start.round() == 1
                ? 'italic'
                : 'normal',
            'hash': _hashToString(variant.file.hash),
            'length': variant.file.fileSize,
          },
      ],
      'themeParams': <Map<String, String>>[
        for (final String themeParam in themeParams)
          <String, String>{'value': themeParam},
      ],
    });
  }

  // Part font methods by first letter.
  final methodsByLetter = <String, List<Map<String, dynamic>>>{};
  final allParts = <Map<String, dynamic>>[];

  for (final map in methods) {
    final methodName = map['methodName'] as String;
    final String firstLetter = methodName[0];
    if (!methodsByLetter.containsKey(firstLetter)) {
      allParts.add(<String, dynamic>{
        'partFilePath': _generatedPartFilePath(
          firstLetter,
        ).replaceFirst('lib/src/', ''),
      });
      methodsByLetter[firstLetter] = <Map<String, dynamic>>[map];
    } else {
      methodsByLetter[firstLetter]!.add(map);
    }
  }

  // Generate part files.
  final partTemplate = Template(
    File('generator/google_fonts_part.tmpl').readAsStringSync(),
    htmlEscapeValues: false,
  );
  methodsByLetter.forEach((
    String letter,
    List<Map<String, dynamic>> methods,
  ) async {
    final String renderedTemplate = partTemplate.renderString(<String, Object>{
      'part': letter.toUpperCase(),
      'method': methods,
    });
    _writeDartFile(_generatedPartFilePath(letter), renderedTemplate);
  });

  // Generate main file.
  final template = Template(
    File('generator/google_fonts.tmpl').readAsStringSync(),
    htmlEscapeValues: false,
  );
  final String renderedTemplate = template.renderString(
    <String, List<Map<String, dynamic>>>{
      'allParts': allParts,
      'method': methods,
    },
  );
  _writeDartFile(_generatedAllPartsFilePath, renderedTemplate);
}

void _writeDartFile(String path, String content) {
  File(path).writeAsStringSync(content);
}

String _familyToMethodName(String family) {
  final List<String> words = family.split(' ');
  for (var i = 0; i < words.length; i++) {
    final String word = words[i];
    final isFirst = i == 0;
    final isUpperCase = word == word.toUpperCase();
    words[i] =
        (isFirst ? word[0].toLowerCase() : word[0].toUpperCase()) +
        (isUpperCase ? word.substring(1).toLowerCase() : word.substring(1));
  }
  return words.join();
}

Future<Directory> _readFontsProtoData(Uri protoUrl) async {
  final http.Response fontsProtoFile = await http.get(protoUrl);
  return Directory.fromBuffer(fontsProtoFile.bodyBytes);
}
