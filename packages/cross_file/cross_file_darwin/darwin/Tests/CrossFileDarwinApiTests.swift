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

struct CrossFileDarwinApiTests {
  func createTempTestFile() throws -> URL {
    let fileManager = FileManager.default
    let tempDirectory = fileManager.temporaryDirectory
    let fileName = UUID().uuidString + ".txt"
    let fileURL = tempDirectory.appendingPathComponent(fileName)

    try "Hello, World!".write(to: fileURL, atomically: true, encoding: .utf8)

    return fileURL
  }

  @Test func startAccessingSecurityScopedResource() throws {
    let testFileURL = try createTempTestFile()

    let api = CrossFileDarwinApiImpl()
    let canAccess = try api.startAccessingSecurityScopedResource(url: testFileURL.absoluteString)

    // Only returns true on iOS.
    #if os(iOS)
      #expect(canAccess)
    #endif

    #expect(try String(contentsOf: testFileURL, encoding: .utf8) == "Hello, World!")
  }

  @Test func tryCreateBookmarkedUrl() throws {
    let testFileURL = try createTempTestFile()

    let api = CrossFileDarwinApiImpl()
    let bookmarkedURLString = try! api.tryCreateBookmarkedUrl(url: testFileURL.absoluteString)!

    #expect(URL(fileURLWithPath: bookmarkedURLString) == testFileURL)
  }
}
