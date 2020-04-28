// Copyright 2019 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:meta/meta.dart';
import 'package:path/path.dart' as path;
import 'package:process/process.dart';

/// A wrapper for running Fuchsia images on AEMU.
@immutable
class Emulator {
  /// Creates a new wrapper for the `emu` tool.
  const Emulator({
    @required this.aemuPath,
    @required this.fuchsiaSdkPath,
    this.headless = false,
    this.processManager = const LocalProcessManager(),
    this.sshPath = '.fuchsia',
    @required this.workDirectory,
  }) : assert(processManager != null);

  /// The location of the extracted images. This directly will be used for
  /// creating FEMU compatible assets.
  final String workDirectory;

  /// The path to the AEMU executable on disk.
  final String aemuPath;

  /// The path to the Fuchsia SDK that contains the tools.
  final String fuchsiaSdkPath;

  /// The path to the directory containing authorized_keys.
  final String sshPath;

  /// Whether to run AEMU with a graphical window or not.
  /// 
  /// Infrastructure will run FEMU in headless mode whereas local debugging
  /// may use the graphical window.
  final bool headless;

  /// The QEMU kernel image to use. This is only including in Fuchsia QEMU images.
  static const String _kernelImage = 'qemu-kernel.kernel';

  /// Bootloader image in [workDirectory].
  static const String _bootloaderImage = 'zircon-a.zbi';

  /// [_bootloaderImage] that is accessible with SSH using [sshPath] keys.
  static const String _signedBootloaderImage = 'fuchsia-ssh.zbi';

  /// Fuchsia image in [workDirectory].
  static const String _fuchsiaImage = 'storage-full.blk';

  /// FVM extended version of [_fuchsiaImage] to have additional space for FEMU.
  static const String _fvmImage = 'fvm.blk';

  /// Location of `fvm` in [fuchsiaSdkPath].
  static const String _fvmToolPath = 'sdk/tools/fvm';

  /// Location of `zbi` in [fuchsiaSdkPath].
  static const String _zbiToolPath = 'sdk/tools/zbi';

  /// The [ProcessManager] to use for launching the `emu` tool.
  final ProcessManager processManager;

  /// 1. Verify [workdir] has necessary files to run a Fuchsia image on AEMU.
  ///   a. image file
  ///   b. zircon boot file
  /// 2. Verify [qemuKernelPath] exists.
  /// 3. Prepare
  /// 4. Sign [zirconA] with given ssh keys to ensure access to the the guest
  /// Fuchsia instance on the emulator.
  Future<void> prepareEnvironment() async {
    final String fuchsiaImagePath = path.join(workDirectory, _fuchsiaImage);
    final String fvmImagePath = path.join(workDirectory, _fvmImage);
    prepareFvmImage(fuchsiaImagePath, fvmImagePath);

    final String zirconBootImagePath =
        path.join(workDirectory, _bootloaderImage);
    final String signedZirconBootImagePath =
        path.join(workDirectory, _signedBootloaderImage);
    prepareZirconBootImage(zirconBootImagePath, signedZirconBootImagePath);
  }

  @visibleForTesting
  void prepareFvmImage(String fuchsiaImagePath, String fvmPath,
      {String fvmExecutable}) {
    fvmExecutable ??= path.join(fuchsiaSdkPath, _fvmToolPath);

    /// Need to make the SDK storage-full.blk writable so that the copy is writable as well, otherwise [fvmTool] extend fails.
    final ProcessResult chmodResult =
        processManager.runSync(<String>['chmod', 'u+w', fuchsiaImagePath]);
    if (chmodResult.exitCode != 0) {
      throw EmulatorException(chmodResult.stderr);
    }

    final ProcessResult cpResult =
        processManager.runSync(<String>['cp', fuchsiaImagePath, fvmPath]);
    if (cpResult.exitCode != 0) {
      throw EmulatorException(cpResult.stderr);
    }

    // Calculate new size by doubling the current size
    final File fvmFile = File(fvmPath);
    final int newSize = fvmFile.lengthSync() * 2;

    // 2. Use [fvmExecutable] extend to copy image to make compatible with AEMU.
    // Return path to this new fvm image?
    final ProcessResult fvmResult = processManager.runSync(
        <String>[fvmExecutable, fvmPath, 'extend', '--length', '$newSize']);
    if (fvmResult.exitCode != 0) {
      throw EmulatorException(
          fvmResult.stderr); // ERROR HERE: Found invalid FVM container
    }
  }

  @visibleForTesting
  void prepareZirconBootImage(
      String zirconBootImagePath, String signedZirconBootImagePath,
      {String zbiExecutable, String authorizedKeysPath}) {
    zbiExecutable ??= path.join(fuchsiaSdkPath, _zbiToolPath);
    authorizedKeysPath ??= path.join(sshPath, 'authorized_keys');

    /// The authorized keys file is not being found, but this runs locally :)
    final ProcessResult zbiResult = processManager.runSync(<String>[
      zbiExecutable,
      '--compressed=zstd',
      '-o',
      signedZirconBootImagePath,
      zirconBootImagePath,
      '--entry',
      '"data/ssh/authorized_keys=$authorizedKeysPath"'
    ]);
    if (zbiResult.exitCode != 0) {
      throw EmulatorException(zbiResult.stderr);
    }
  }

  /// Pass the given state to AEMU.
  Future<void> start() async {
    // prepareEnvironment();
    final String fvmImagePath = path.join(workDirectory, _fvmImage);

    /// Anything after -fuchsia flag will be passed to QEMU
    final List<String> _aemuArgs = <String>[
      '-feature', 'VirtioInput,RefCountPipe,KVM,GLDirectMem,Vulkan',
      '-window-size', '1280x800', // TODO(chillers): Configurable
      '-gpu', 'swiftshader_indirect',
      headless ? '-no-window' : '',
      '-fuchsia',
    ];

    final String qemuKernelPath = path.join(workDirectory, _kernelImage);
    _aemuArgs.addAll(<String>['-kernel', qemuKernelPath]);

    final String signedZirconBootImagePath =
        path.join(workDirectory, _signedBootloaderImage);
    _aemuArgs.addAll(<String>['-initrd', signedZirconBootImagePath]);

    _aemuArgs.addAll(<String>[
      '-m', '2048',
      '-serial', 'stdio',
      '-vga', 'none',
      '-device', 'virtio-keyboard-pci',
      '-device', 'virtio_input_multi_touch_pci_1',
      '-smp', '4,threads=2',
      '-machine', 'q35',
      '-device', 'isa-debug-exit,iobase=0xf4,iosize=0x04',
      '-enable-kvm', // configurable
      '-cpu', 'host,migratable=no,+invtsc',
      '-netdev', 'type=tap,ifname=qemu,script=no,downscript=no,id=net0',
      '-device', 'e1000,netdev=net0,mac=52:54:00:63:5e:7a',
      '-drive', 'file=$fvmImagePath,format=raw,if=none,id=vdisk',
      '-device', 'virtio-blk-pci,drive=vdisk',
      '-append',
      '\'TERM=xterm-256color kernel.serial=legacy kernel.entropy-mixin=660486b6b20b4ace3fb5c81b0002abf5271289185c6a5620707606c55b377562 kernel.halt-on-panic=true\'' // configure entropy
    ]);

    // Insert the AEMU executable
    _aemuArgs.insert(0, aemuPath);

    stdout.writeln(_aemuArgs.join(' '));
    final Process emuProcess = await processManager.start(_aemuArgs);
    stdout.addStream(emuProcess.stdout);
    stderr.addStream(emuProcess.stderr);

    await emuProcess.exitCode;
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
