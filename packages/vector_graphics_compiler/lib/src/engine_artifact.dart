// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ffi' show Abi;

/// Returns the engine-artifact subpath (`<platform-dir>/<file>`) for [abi],
/// or `null` if the host is unsupported.
String? engineArtifactSubpath({
  required String windowsFile,
  required String macOSFile,
  required String linuxFile,
  required Abi abi,
}) {
  return switch (abi) {
    Abi.windowsX64 || Abi.windowsArm64 => 'windows-x64/$windowsFile',
    Abi.macosX64 || Abi.macosArm64 => 'darwin-x64/$macOSFile',
    Abi.linuxX64 => 'linux-x64/$linuxFile',
    Abi.linuxArm64 => 'linux-arm64/$linuxFile',
    _ => null,
  };
}
