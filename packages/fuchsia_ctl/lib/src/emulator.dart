// Copyright 2019 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as path;
import 'package:process/process.dart';

import 'operation_result.dart';

/// A wrapper for running Fuchsia images on AEMU.
class Emulator {
  /// Creates a new wrapper for the `emu` tool.
  Emulator({
    @required this.aemuPath,
    @required this.fuchsiaImagePath,
    @required this.fuchsiaSdkPath,
    this.fs = const LocalFileSystem(),
    this.processManager = const LocalProcessManager(),
    @required this.qemuKernelPath,
    this.sshPath = '.fuchsia',
    @required this.zbiPath,
  }) : assert(processManager != null);

  /// The path to the AEMU executable on disk.
  final String aemuPath;

  /// Fuchsia image to load into the emulator.
  final String fuchsiaImagePath;

  /// The path to the Fuchsia SDK that contains the tools.
  final String fuchsiaSdkPath;

  /// The QEMU kernel image to use. This is only bundled in Fuchsia QEMU images.
  final String qemuKernelPath;

  /// The path to the directory containing authorized_keys.
  final String sshPath;

  /// Bootloader image.
  final String zbiPath;

  /// Location of `fvm` in [fuchsiaSdkPath].
  @visibleForTesting
  final String fvmToolPath = 'sdk/tools/fvm';

  /// Location of `zbi` in [fuchsiaSdkPath].
  @visibleForTesting
  final String zbiToolPath = 'sdk/tools/zbi';

  /// Default AEMU window size to be launched.
  @visibleForTesting
  final String defaultWindowSize = '1280x800';

  /// Flag to pass to AEMU to run in headless mode.
  @visibleForTesting
  final String aemuHeadlessFlag = '-no-window';

  /// The [FileSystem] to use when running the `emu` tool.
  final FileSystem fs;

  /// The [ProcessManager] to use for running the `emu` tool.
  final ProcessManager processManager;

  /// FVM extended version of [fuchsiaImagePath] for running on FEMU.
  @visibleForTesting
  String fvmImagePath;

  /// [zbiPath] that is accessible with SSH using [sshPath] keys.
  @visibleForTesting
  String signedZbiPath;

  /// Update given Fuchsia assets to make them compatible with FEMU.
  ///
  /// 1. Ensure required assets exist.
  /// 2. Create FVM image for running with FEMU.
  /// 3. Sign boot image for host access to the guest FEMU instance.
  Future<void> prepareEnvironment() async {
    assert(fs.isFileSync(fuchsiaImagePath));
    assert(fs.isFileSync(zbiPath));
    assert(fs.isFileSync(qemuKernelPath));

    final String tmpPath = fs.systemTempDirectory.createTempSync().path;
    fvmImagePath = '$tmpPath/fvm.blk';
    signedZbiPath = '$tmpPath/fuchsia-ssh.zbi';

    await _prepareFvmImage(fuchsiaImagePath, fvmImagePath);
    await _signBootImage(zbiPath, signedZbiPath);
  }

  /// Double the size of [fuchsiaImagePath] to make space for the emulator
  /// to write back to it.
  Future<void> _prepareFvmImage(String fuchsiaImagePath, String fvmPath,
      {String fvmExecutable}) async {
    fvmExecutable ??= path.join(fuchsiaSdkPath, fvmToolPath);

    await _run(<String>['cp', fuchsiaImagePath, fvmPath]);

    /// [fvmTool] and FEMU need write access to [fvmPath].
    await _run(<String>['chmod', 'u+w', fvmPath]);

    // Calculate new size by doubling the current size
    final File fvmFile = fs.file(fvmPath)..createSync();
    final int newSize = fvmFile.lengthSync() * 2;

    await _run(
        <String>[fvmExecutable, fvmPath, 'extend', '--length', '$newSize']);
  }

  /// Signed [zbiPath] using [zbiExecutable] with [authorizedKeysPath] to
  /// create a bootloader image that is accessible from the host.
  Future<void> _signBootImage(String zbiPath, String signedZbiPath,
      {String zbiExecutable, String authorizedKeysPath}) async {
    zbiExecutable ??= path.join(fuchsiaSdkPath, zbiToolPath);
    authorizedKeysPath ??= path.join(sshPath, 'authorized_keys');

    final File authorizedKeysAbsolute = fs.file(authorizedKeysPath).absolute;

    final List<String> zbiCommand = <String>[
      zbiExecutable,
      '--compressed=zstd',
      '-o',
      signedZbiPath,
      zbiPath,
      '-e',
      'data/ssh/authorized_keys=${authorizedKeysAbsolute.path}'
    ];
    await _run(zbiCommand);
  }

  /// Run FEMU given the current environment.
  ///
  /// [prepareEnvironment] must have been called before starting the emulator.
  ///
  /// If [headless], will run AEMU without a graphical window. Infras will run
  /// FEMU in headless mode whereas local debugging may use a graphical window.
  Future<OperationResult> start(
      {bool headless = false, String windowSize}) async {
    assert(fvmImagePath != null && fs.isFileSync(fvmImagePath));
    assert(signedZbiPath != null && fs.isFileSync(signedZbiPath));

    final List<String> aemuCommand = <String>[
      aemuPath,
      '-feature',
      'VirtioInput,RefCountPipe,KVM,GLDirectMem,Vulkan',
      '-window-size',
      windowSize ?? defaultWindowSize,
      '-gpu',
      'swiftshader_indirect',
    ];

    if (headless) {
      aemuCommand.add(aemuHeadlessFlag);
    }

    /// Anything after -fuchsia flag will be passed to QEMU
    aemuCommand.addAll(<String>[
      '-fuchsia',
      '-kernel', qemuKernelPath,
      '-initrd', signedZbiPath,
      '-m', '2048',
      '-serial', 'stdio',
      '-vga', 'none',
      '-device', 'virtio-keyboard-pci',
      '-device', 'virtio_input_multi_touch_pci_1',
      '-smp', '4,threads=2',
      '-machine', 'q35',
      '-device', 'isa-debug-exit,iobase=0xf4,iosize=0x04',
      // TODO(chillers): Add hardware acceleration option to configure this.
      '-enable-kvm',
      '-cpu', 'host,migratable=no,+invtsc',
      '-netdev', 'type=tap,ifname=qemu,script=no,downscript=no,id=net0',
      '-device', 'e1000,netdev=net0,mac=52:54:00:63:5e:7a',
      '-drive', 'file=$fvmImagePath,format=raw,if=none,id=vdisk',
      '-device', 'virtio-blk-pci,drive=vdisk',
      '-append',
       // TODO(chillers): Generate entropy mixin.
      '\'TERM=xterm-256color kernel.serial=legacy kernel.entropy-mixin=660486b6b20b4ace3fb5c81b0002abf5271289185c6a5620707606c55b377562 kernel.halt-on-panic=true\'',
    ]);

    await _start(aemuCommand);

    return OperationResult.success();
  }

  /// Helper function for running [command] and manging its stdio and errors.
  Future<void> _run(List<String> command) async {
    stdout.writeln(command.join(' '));
    final ProcessResult process = await processManager.run(
      command,
    );
    stdout.writeln(process.stdout);
    stderr.writeln(process.stderr);

    if (process.exitCode != 0) {
      throw EmulatorException('${command.first} did not return exit code 0');
    }
  }

  Future<Process> _start(List<String> command) async {
    stdout.writeln(command.join(' '));
    final Process process = await processManager.start(
      command,
    );
    stdout.addStream(process.stdout);
    stderr.addStream(process.stderr);

    if (await process.exitCode != 0) {
      throw EmulatorException('${command.first} did not return exit code 0');
    }

    return process;
  }
}

/// Wraps exceptions thrown by [Emulator].
class EmulatorException implements Exception {
  /// Creates a new [EmulatorException].
  const EmulatorException(this.message);

  /// The user-facing message to display.
  final String message;

  @override
  String toString() => message;
}
