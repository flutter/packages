// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Testing

@testable import cross_file_darwin

#if os(iOS)
  import Flutter
#elseif os(macOS)
  import FlutterMacOS
#else
  #error("Unsupported platform.")
#endif

struct AssetResourceReaderTests {
  func createTempTestFile() throws -> URL {
    let fileManager = FileManager.default
    let tempDirectory = fileManager.temporaryDirectory
    let fileName = UUID().uuidString + ".txt"
    let fileURL = tempDirectory.appendingPathComponent(fileName)

    try "Hello, World!".write(to: fileURL, atomically: true, encoding: .utf8)

    return fileURL
  }

  @Test func pigeonDefaultConstructor() throws {
    let registrar = TestProxyApiRegistrar()
    let api = registrar.apiDelegate.pigeonApiAssetResourceReader(registrar)

    let instance = try? api.pigeonDelegate.pigeonDefaultConstructor(pigeonApi: api)
    #expect(instance != nil)
  }
}
