// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#if os(iOS)
  import Flutter
#elseif os(macOS)
  import FlutterMacOS
#else
  #error("Unsupported platform.")
#endif

import Testing
import cross_file_darwin
import UIKit

@testable import cross_file_darwin

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
    let canAccess = try api.startAccessingSecurityScopedResource(url: testFileURL.path)
    
    #expect(canAccess)
  }
  
  @Test func tryCreateBookmarkedUrl() throws {
    let testFileURL = try createTempTestFile()
    
    let api = CrossFileDarwinApiImpl()
    let bookmarkedURLString = try! api.tryCreateBookmarkedUrl(url: testFileURL.path)!
    
    #expect(URL(fileURLWithPath: bookmarkedURLString) == testFileURL)
  }
}
