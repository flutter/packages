// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:io' as io;
import 'dart:typed_data';

import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider_windows/path_provider_windows.dart';
import 'package:shared_preferences_platform_interface/types.dart';
import 'package:shared_preferences_windows/shared_preferences_windows.dart';

import 'fake_path_provider_windows.dart';

/// [SharedPreferencesWindows] and [SharedPreferencesAsyncWindows] store their
/// data in the same `shared_preferences.json`, and each write replaces the
/// whole file with that store's map. Neither may write a map it read before
/// the other store's writes, or those keys are silently lost.
void main() {
  late MemoryFileSystem fs;
  late PathProviderWindows pathProvider;

  const legacyKey = 'flutter.legacyString';
  const asyncKey = 'asyncString';
  const options = SharedPreferencesWindowsOptions();

  setUp(() {
    fs = MemoryFileSystem.test();
    pathProvider = FakePathProviderWindows();
  });

  SharedPreferencesWindows getLegacyPreferences({
    FileSystem? fs_,
    PathProviderWindows? pathProvider_,
  }) {
    final preferences = SharedPreferencesWindows();
    preferences.fs = fs_ ?? fs;
    preferences.pathProvider = pathProvider_ ?? pathProvider;
    return preferences;
  }

  SharedPreferencesAsyncWindows getAsyncPreferences({
    FileSystem? fs_,
    PathProviderWindows? pathProvider_,
  }) {
    final preferences = SharedPreferencesAsyncWindows();
    preferences.fs = fs_ ?? fs;
    preferences.pathProvider = pathProvider_ ?? pathProvider;
    return preferences;
  }

  Future<File> preferencesFile() async {
    final String? directory = await pathProvider.getApplicationSupportPath();
    return fs.file(path.join(directory!, 'shared_preferences.json'));
  }

  Future<Map<String, Object?>> readFile() async {
    final File file = await preferencesFile();
    return json.decode(file.readAsStringSync()) as Map<String, Object?>;
  }

  Future<void> writeFile(String contents) async {
    final File file = await preferencesFile();
    file
      ..createSync(recursive: true)
      ..writeAsStringSync(contents);
  }

  Future<Map<String, Object>> getAllLegacy(SharedPreferencesWindows legacy) {
    return legacy.getAllWithParameters(
      GetAllParameters(filter: PreferencesFilter(prefix: 'flutter.')),
    );
  }

  group('a damaged file', () {
    // What two processes writing at once can leave: one complete write followed
    // by the tail of an older, longer one.
    const damagedFile = '{"$asyncKey":"kept","$legacyKey":"also kept"}7}';

    test('keeps its complete leading write', () async {
      await writeFile(damagedFile);

      expect(await getAsyncPreferences().getString(asyncKey, options), 'kept');
      expect(await getAllLegacy(getLegacyPreferences()), <String, Object>{legacyKey: 'also kept'});
    });

    test('is repaired by a write', () async {
      await writeFile(damagedFile);

      await getAsyncPreferences().setString('another', 'value', options);

      expect(await readFile(), <String, Object?>{
        asyncKey: 'kept',
        legacyKey: 'also kept',
        'another': 'value',
      });
    });

    test('can end part-way through a character', () async {
      final File file = await preferencesFile();
      file
        ..createSync(recursive: true)
        ..writeAsBytesSync(<int>[
          ...utf8.encode('{"$asyncKey":"café"}'),
          // The second byte of a two-byte character, left over from a longer write.
          0xA9,
          ...utf8.encode('"}'),
        ]);

      expect(await getAsyncPreferences().getString(asyncKey, options), 'café');
    });

    for (final (String description, String contents) in <(String, String)>[
      ('is cut off', '{"$asyncKey":"cut off'),
      // The text before the error is not a complete write either.
      ('has no complete leading write', '{"$asyncKey":"value",]'),
      ('is not a JSON object', '["$asyncKey"]'),
    ]) {
      test('that $description reads as empty and is replaced by a write', () async {
        await writeFile(contents);

        expect(await getAsyncPreferences().getString(asyncKey, options), isNull);
        expect(await getLegacyPreferences().setValue('String', legacyKey, 'saved'), isTrue);

        expect(await readFile(), <String, Object?>{legacyKey: 'saved'});
      });
    }
  });

  group('a file another process is writing', () {
    const complete = '{"$asyncKey":"kept","$legacyKey":"also kept"}';

    for (final (String description, Uint8List Function(Uint8List) firstRead)
        in <(String, Uint8List Function(Uint8List))>[
          ('empty', (Uint8List bytes) => Uint8List(0)),
          ('cut off', (Uint8List bytes) => Uint8List.sublistView(bytes, 0, bytes.length ~/ 2)),
          ('locked', (Uint8List bytes) => throw const FileSystemException('The file is in use.')),
        ]) {
      test('is read again by a write when it is $description', () async {
        await writeFile(complete);
        final SharedPreferencesAsyncWindows preferences = getAsyncPreferences(
          fs_: _FirstReadsFileSystem(fs, firstRead),
        );

        await preferences.setString('another', 'value', options);

        expect(await readFile(), <String, Object?>{
          asyncKey: 'kept',
          legacyKey: 'also kept',
          'another': 'value',
        });
        expect(await preferences.getString(asyncKey, options), 'kept');
      });

      test('is read again by a first read when it is $description', () async {
        await writeFile(complete);
        final SharedPreferencesWindows legacy = getLegacyPreferences(
          fs_: _FirstReadsFileSystem(fs, firstRead),
        );

        expect(await getAllLegacy(legacy), <String, Object>{legacyKey: 'also kept'});
      });
    }

    test('is left alone by a write when it stays locked', () async {
      await writeFile(complete);
      final lockedFs = _FirstReadsFileSystem(
        fs,
        (Uint8List bytes) => throw const FileSystemException('The file is in use.'),
        count: 1000,
      );

      expect(
        await getLegacyPreferences(fs_: lockedFs).setValue('String', 'flutter.another', 'value'),
        isFalse,
      );
      // The async store has no way to report the failure, but must not throw.
      await getAsyncPreferences(fs_: lockedFs).setString('another', 'value', options);

      expect((await preferencesFile()).readAsStringSync(), complete);
    });
  });

  group('a write that fails', () {
    test('because there is no support directory changes nothing', () async {
      final noDirectory = _SupportPathProvider(() => null);
      final SharedPreferencesWindows legacy = getLegacyPreferences(pathProvider_: noDirectory);
      final SharedPreferencesAsyncWindows async = getAsyncPreferences(pathProvider_: noDirectory);

      expect(await legacy.setValue('String', legacyKey, 'legacy value'), isFalse);
      expect(await legacy.remove(legacyKey), isFalse);
      expect(await legacy.clear(), isFalse);
      await async.setString(asyncKey, 'async value', options);

      expect(await getAllLegacy(legacy), isEmpty);
      expect(await async.getString(asyncKey, options), isNull);
      expect((await preferencesFile()).existsSync(), isFalse);
    });

    test('because the support directory lookup throws returns false', () async {
      final throwing = _SupportPathProvider(() => throw StateError('No support directory.'));

      expect(
        await getLegacyPreferences(
          pathProvider_: throwing,
        ).setValue('String', legacyKey, 'legacy value'),
        isFalse,
      );
      await getAsyncPreferences(
        pathProvider_: throwing,
      ).setString(asyncKey, 'async value', options);
    });

    test('because the file cannot be written is not cached', () async {
      await writeFile('{"$asyncKey":"stored","$legacyKey":"also stored"}');
      final readOnlyFs = _FailingWriteFileSystem(fs);
      final SharedPreferencesWindows legacy = getLegacyPreferences(fs_: readOnlyFs);
      final SharedPreferencesAsyncWindows async = getAsyncPreferences(fs_: readOnlyFs);

      expect(await legacy.setValue('String', legacyKey, 'changed'), isFalse);
      await async.setString(asyncKey, 'changed', options);

      expect(await getAllLegacy(legacy), <String, Object>{legacyKey: 'also stored'});
      expect(await async.getString(asyncKey, options), 'stored');
    });

    test('does not hold up the writes queued behind it', () async {
      final SharedPreferencesWindows failing = getLegacyPreferences(
        fs_: _FailingWriteFileSystem(fs),
      );
      final SharedPreferencesWindows legacy = getLegacyPreferences();

      final List<bool> results = await Future.wait(<Future<bool>>[
        failing.setValue('String', 'flutter.lost', 'value'),
        legacy.setValue('String', legacyKey, 'legacy value'),
      ]);

      expect(results, <bool>[false, true]);
      expect(await readFile(), <String, Object?>{legacyKey: 'legacy value'});
    });
  });

  test('a legacy write keeps keys the async store wrote after it loaded', () async {
    final SharedPreferencesWindows legacy = getLegacyPreferences();
    final SharedPreferencesAsyncWindows async = getAsyncPreferences();

    // Both stores load while the file is empty, as they do at app startup.
    await getAllLegacy(legacy);
    await async.getString(asyncKey, options);

    await async.setString(asyncKey, 'async value', options);
    await legacy.setValue('String', legacyKey, 'legacy value');

    expect(await readFile(), <String, Object?>{asyncKey: 'async value', legacyKey: 'legacy value'});
    // Each store reads its own write back from its cache.
    expect(await getAllLegacy(legacy), <String, Object>{legacyKey: 'legacy value'});
    expect(await async.getString(asyncKey, options), 'async value');
  });

  test('an async write keeps keys the legacy store wrote after it loaded', () async {
    final SharedPreferencesWindows legacy = getLegacyPreferences();
    final SharedPreferencesAsyncWindows async = getAsyncPreferences();

    await getAllLegacy(legacy);
    await async.getString(asyncKey, options);

    await legacy.setValue('String', legacyKey, 'legacy value');
    await async.setString(asyncKey, 'async value', options);

    expect(await readFile(), <String, Object?>{legacyKey: 'legacy value', asyncKey: 'async value'});
    expect(await getAllLegacy(legacy), <String, Object>{legacyKey: 'legacy value'});
    expect(await async.getString(asyncKey, options), 'async value');
  });

  test('repeated interleaved writes keep both stores intact', () async {
    final SharedPreferencesWindows legacy = getLegacyPreferences();
    final SharedPreferencesAsyncWindows async = getAsyncPreferences();

    for (var i = 0; i < 5; i++) {
      await async.setInt('$asyncKey$i', i, options);
      await legacy.setValue('int', '$legacyKey$i', i);
    }

    final Map<String, Object?> file = await readFile();
    final Map<String, Object> legacyValues = await getAllLegacy(legacy);
    for (var i = 0; i < 5; i++) {
      expect(file['$asyncKey$i'], i);
      expect(file['$legacyKey$i'], i);
      expect(await async.getInt('$asyncKey$i', options), i);
      expect(legacyValues['$legacyKey$i'], i);
    }
  });

  test('concurrent writes to both stores all land', () async {
    final SharedPreferencesWindows legacy = getLegacyPreferences();
    final SharedPreferencesAsyncWindows async = getAsyncPreferences();

    // Nothing here awaits the previous write, which is what a fire-and-forget
    // caller does: each read-modify-write has to be atomic against the others.
    await Future.wait(<Future<void>>[
      async.setInt('${asyncKey}1', 1, options),
      legacy.setValue('int', '${legacyKey}1', 1),
      async.setInt('${asyncKey}2', 2, options),
      legacy.setValue('int', '${legacyKey}2', 2),
    ]);

    expect(await readFile(), <String, Object?>{
      '${asyncKey}1': 1,
      '${legacyKey}1': 1,
      '${asyncKey}2': 2,
      '${legacyKey}2': 2,
    });
    expect(await getAllLegacy(legacy), <String, Object>{'${legacyKey}1': 1, '${legacyKey}2': 2});
    expect(await async.getInt('${asyncKey}1', options), 1);
    expect(await async.getInt('${asyncKey}2', options), 2);
  });

  test('concurrent writes all land while the file has to be read again', () async {
    await writeFile('{"$asyncKey":"kept"}');
    // The first write's read yields to the event loop to retry, which is where
    // the second write would get in if the two were not queued.
    final retryingFs = _FirstReadsFileSystem(fs, (Uint8List bytes) => Uint8List(0));
    final SharedPreferencesWindows legacy = getLegacyPreferences(fs_: retryingFs);
    final SharedPreferencesAsyncWindows async = getAsyncPreferences();

    await Future.wait(<Future<void>>[
      legacy.setValue('String', legacyKey, 'legacy value'),
      async.setString('another', 'value', options),
    ]);

    expect(await readFile(), <String, Object?>{
      asyncKey: 'kept',
      legacyKey: 'legacy value',
      'another': 'value',
    });
  });

  test('a legacy remove leaves the async store alone', () async {
    final SharedPreferencesWindows legacy = getLegacyPreferences();
    final SharedPreferencesAsyncWindows async = getAsyncPreferences();

    await legacy.setValue('String', legacyKey, 'legacy value');
    await async.setString(asyncKey, 'async value', options);
    await legacy.remove(legacyKey);

    expect(await readFile(), <String, Object?>{asyncKey: 'async value'});
    expect(await getAllLegacy(legacy), isEmpty);
  });

  test('a legacy clear leaves the async store alone', () async {
    final SharedPreferencesWindows legacy = getLegacyPreferences();
    final SharedPreferencesAsyncWindows async = getAsyncPreferences();

    // The legacy store's cache is filled before the async key exists.
    await legacy.setValue('String', legacyKey, 'legacy value');
    await async.setString(asyncKey, 'async value', options);
    await legacy.clear();

    expect(await readFile(), <String, Object?>{asyncKey: 'async value'});
    expect(await getAllLegacy(legacy), isEmpty);
  });

  test('an async clear leaves the legacy store alone', () async {
    final SharedPreferencesWindows legacy = getLegacyPreferences();
    final SharedPreferencesAsyncWindows async = getAsyncPreferences();

    // The async store's cache is filled before the legacy key exists.
    await async.setString(asyncKey, 'async value', options);
    await legacy.setValue('String', legacyKey, 'legacy value');
    await async.clear(
      const ClearPreferencesParameters(filter: PreferencesFilters(allowList: <String>{asyncKey})),
      options,
    );

    expect(await readFile(), <String, Object?>{legacyKey: 'legacy value'});
    expect(await async.getString(asyncKey, options), isNull);
  });

  test('an async clear of everything removes keys the legacy store wrote', () async {
    final SharedPreferencesWindows legacy = getLegacyPreferences();
    final SharedPreferencesAsyncWindows async = getAsyncPreferences();

    await async.setString(asyncKey, 'async value', options);
    await legacy.setValue('String', legacyKey, 'legacy value');
    await async.clear(const ClearPreferencesParameters(filter: PreferencesFilters()), options);

    expect(await readFile(), isEmpty);
    expect(
      await async.getKeys(const GetPreferencesParameters(filter: PreferencesFilters()), options),
      isEmpty,
    );
  });
}

/// A path provider with a replaceable application support path lookup.
class _SupportPathProvider extends FakePathProviderWindows {
  _SupportPathProvider(this._supportPath);

  final String? Function() _supportPath;

  @override
  Future<String?> getApplicationSupportPath() async => _supportPath();
}

/// A file system whose first [count] reads of a file's bytes go through
/// [firstRead], as if another process were part-way through writing the file.
class _FirstReadsFileSystem extends ForwardingFileSystem {
  _FirstReadsFileSystem(super.delegate, this.firstRead, {this.count = 1});

  final Uint8List Function(Uint8List bytes) firstRead;
  final int count;
  int _reads = 0;

  @override
  File file(dynamic path) => _TestFile(delegate.file(path), onRead: _onRead);

  Uint8List _onRead(Uint8List bytes) => _reads++ < count ? firstRead(bytes) : bytes;
}

/// A file system whose files cannot be written.
class _FailingWriteFileSystem extends ForwardingFileSystem {
  _FailingWriteFileSystem(super.delegate);

  @override
  File file(dynamic path) => _TestFile(
    delegate.file(path),
    onWrite: () => throw const FileSystemException('The disk is full.'),
  );
}

class _TestFile extends ForwardingFileSystemEntity<File, io.File> with ForwardingFile {
  _TestFile(this.delegate, {this.onRead, this.onWrite});

  @override
  final File delegate;

  final Uint8List Function(Uint8List bytes)? onRead;
  final void Function()? onWrite;

  @override
  FileSystem get fileSystem => delegate.fileSystem;

  @override
  Uint8List readAsBytesSync() {
    final Uint8List bytes = delegate.readAsBytesSync();
    return onRead?.call(bytes) ?? bytes;
  }

  @override
  String readAsStringSync({Encoding encoding = utf8}) => encoding.decode(readAsBytesSync());

  @override
  void writeAsStringSync(
    String contents, {
    FileMode mode = FileMode.write,
    Encoding encoding = utf8,
    bool flush = false,
  }) {
    onWrite?.call();
    delegate.writeAsStringSync(contents, mode: mode, encoding: encoding, flush: flush);
  }

  @override
  File wrapFile(io.File delegate) => _TestFile(delegate as File, onRead: onRead, onWrite: onWrite);

  @override
  Directory wrapDirectory(io.Directory delegate) => delegate as Directory;

  @override
  Link wrapLink(io.Link delegate) => delegate as Link;
}
