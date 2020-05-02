// Copyright 2019 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:file/memory.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'package:fuchsia_ctl/fuchsia_ctl.dart';

import 'fakes.dart';

void main() {
  const String aemuPath = '/emulator';
  const String fuchsiaImagePath = '/fuchsia.blk';
  const String fuchsiaSdkPath = '/fuchsia-sdk';
  const String qemuKernelPath = '/qemu-kernel.kernel';
  const String zbiPath = '/zircon-a.zbi';

  Emulator emulator;
  MockCommandLine mockCli;
  MemoryFileSystem fs;

  group('Emulator', () {
    setUp(() {
      mockCli = MockCommandLine();
      fs = MemoryFileSystem(style: FileSystemStyle.posix);
      fs.file(aemuPath).createSync();
      fs.file(fuchsiaImagePath)
        ..createSync()
        ..writeAsString('fuchsia image content');
      fs.file(fuchsiaSdkPath).createSync();
      fs.file(qemuKernelPath).createSync();
      fs.file(zbiPath).createSync();
      emulator = Emulator(
        aemuPath: aemuPath,
        fs: fs,
        fuchsiaImagePath: fuchsiaImagePath,
        fuchsiaSdkPath: fuchsiaSdkPath,
        cli: mockCli,
        qemuKernelPath: qemuKernelPath,
        sshKeyManager: MockSshKeyManager(),
        zbiPath: zbiPath,
      );
    });

    test('prepare environment runs as expected', () async {
      when(mockCli.run(
              argThat(contains('$fuchsiaSdkPath/${emulator.zbiToolPath}'))))
          .thenAnswer((_) async {
        fs.file(emulator.signedZbiPath).createSync();
      });

      await emulator.prepareEnvironment();

      expect(fs.isFileSync(emulator.fvmImagePath), isTrue);
      expect(fs.isFileSync(emulator.signedZbiPath), isTrue);
    });

    test('prepare environment throws on file not existing', () async {
      fs.file(fuchsiaImagePath).deleteSync();

      expect(emulator.prepareEnvironment(), throwsA(isA<AssertionError>()));
    });

    test('start throws when prepare enviornment was not called', () async {
      expect(emulator.start(), throwsA(isA<AssertionError>()));

      verifyNever(mockCli.start(any));
    });

    test('start uses default window size', () async {
      emulator.fvmImagePath = '/fvm.blk';
      emulator.signedZbiPath = '/fuchsia-ssh.zbi';
      fs.file(emulator.fvmImagePath).createSync();
      fs.file(emulator.signedZbiPath).createSync();

      when(mockCli.start(any))
          .thenAnswer((_) async => FakeProcess(0, <String>[], <String>[]));

      await emulator.start();
      verify(mockCli
              .start(argThat(contains(emulator.defaultWindowSize))))
          .called(1);
    });

    test('start configures window size', () async {
      emulator.fvmImagePath = '/fvm.blk';
      emulator.signedZbiPath = '/fuchsia-ssh.zbi';
      fs.file(emulator.fvmImagePath).createSync();
      fs.file(emulator.signedZbiPath).createSync();

      when(mockCli.start(any))
          .thenAnswer((_) async => FakeProcess(0, <String>[], <String>[]));

      const String customWindowSize = '50x200';
      await emulator.start(windowSize: customWindowSize);
      verify(mockCli.start(argThat(contains(customWindowSize))))
          .called(1);
    });

    test('start configures headless', () async {
      emulator.fvmImagePath = '/fvm.blk';
      emulator.signedZbiPath = '/fuchsia-ssh.zbi';
      fs.file(emulator.fvmImagePath).createSync();
      fs.file(emulator.signedZbiPath).createSync();

      when(mockCli.start(any))
          .thenAnswer((_) async => FakeProcess(0, <String>[], <String>[]));

      await emulator.start(headless: true);
      verify(mockCli
              .start(argThat(contains(emulator.aemuHeadlessFlag))))
          .called(1);
    });
  });
}
