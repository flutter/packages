// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import Testing

@testable import cross_file_darwin

class FileHandleTests {
  @Test func forReadingFromUrl() {
    let registrar = TestProxyAPIRegistrar()
    let api = registrar.apiDelegate.pigeonApiFileHandle(registrar)
    
    let assetFilePath: String = FlutterDartProject.lookupKey(forAsset: "hello.txt")
//    let a = Bundle(for: FileHandleTests.self).pat
//      forResource: (assetFilePath as NSString).deletingPathExtension,
//      withExtension: (assetFilePath as NSString).pathExtension)
    let b = Bundle(for: FileHandleTests.self)
    let a = b.path(forResource: (assetFilePath as NSString).deletingPathExtension, ofType: (assetFilePath as NSString).pathExtension)
    print((assetFilePath as NSString).deletingPathExtension)
    print((assetFilePath as NSString).pathExtension)
    
    //let a = urlForAsset()!

    let instance = try? api.pigeonDelegate.forReadingAtPath(pigeonApi: api, path: a!)
    #expect(instance != nil)
  }

  //  @Test func testReadUpToCount() {
  //    let registrar = TestProxyAPIRegistrar()
  //    let api = registrar.apiDelegate.pigeonApiFileHandle(registrar)
  //
  //    let instance = TestFileHandle()
  //    let count = 0
  //    let value = try? api.pigeonDelegate.readUpToCount(
  //      pigeonApi: api, pigeonInstance: instance, count: Int64(count))
  //
  //    XCTAssertEqual(instance.readUpToCountArgs, [count])
  //    XCTAssertEqual(value, instance.readUpToCount(count: count))
  //  }
  //
  //  @Test func testReadToEnd() {
  //    let registrar = TestProxyAPIRegistrar()
  //    let api = registrar.apiDelegate.pigeonApiFileHandle(registrar)
  //
  //    let instance = TestFileHandle()
  //    let value = try? api.pigeonDelegate.readToEnd(pigeonApi: api, pigeonInstance: instance)
  //
  //    XCTAssertTrue(instance.readToEndCalled)
  //    XCTAssertEqual(value, instance.readToEnd())
  //  }
  //
  //  @Test func testSeek() {
  //    let registrar = TestProxyAPIRegistrar()
  //    let api = registrar.apiDelegate.pigeonApiFileHandle(registrar)
  //
  //    let instance = TestFileHandle()
  //    let offset = 0
  //    let value = try? api.pigeonDelegate.seek(
  //      pigeonApi: api, pigeonInstance: instance, offset: offset)
  //
  //    XCTAssertEqual(instance.seekArgs, [offset])
  //    XCTAssertEqual(value, instance.seek(offset: offset))
  //  }
  //
  //  @Test func testClose() {
  //    let registrar = TestProxyAPIRegistrar()
  //    let api = registrar.apiDelegate.pigeonApiFileHandle(registrar)
  //
  //    let instance = TestFileHandle()
  //    try? api.pigeonDelegate.close(pigeonApi: api, pigeonInstance: instance)
  //
  //    XCTAssertTrue(instance.closeCalled)
  //  }

  func urlForAsset() -> URL? {
    let assetFilePath: String? = FlutterDartProject.lookupKey(forAsset: "assets/index.html")

    guard let assetFilePath = assetFilePath else {
      return nil
    }
    
//    print("hello")
//    print(FlutterDartProject.lookupKey(forAsset: "assets/index.html"))

    var url: URL? = TestBundle().url(
          forResource: (assetFilePath as NSString).deletingPathExtension,
          withExtension: (assetFilePath as NSString).pathExtension)
    
    print(url ?? "open")

    #if os(macOS)
      // See https://github.com/flutter/flutter/issues/135302
      // TODO(stuartmorgan): Remove this if the asset APIs are adjusted to work better for macOS.
      if url == nil {
        url = URL(string: assetFilePath, relativeTo: bundle.bundleURL)
      }
    #endif

    return url
  }
}

class TestBundle: Bundle, @unchecked Sendable {
  override func url(forResource name: String?, withExtension ext: String?) -> URL? {
    return URL(string: "assets/index.html")!
  }
}

class TestFileHandle: FileHandle, @unchecked Sendable {
  var readUpToCountArgs: [AnyHashable?]? = nil
  var readToEndCalled = false
  var seekArgs: [AnyHashable?]? = nil
  var closeCalled = false

  //  func read(upToCount count: Int) throws -> Data? {
  //    readUpToCountArgs = [count]
  //    return byteArrayOf(0xA1.toByte())
  //  }

  //  func hello(apple: TestFileHandle) throws -> Data? {
  //    readToEndCalled = true
  //  }

  override func seek(toOffset offset: UInt64) throws {
    seekArgs = [offset]
  }

  override func close() throws {
    closeCalled = true
  }
}

//extension TestFileHandle {
//  @_dynamicReplacement(for:readToEnd())
//  dynamic func a() throws -> Data? {
//
//  }
//
//  @_dynamicReplacement(for:close())
//  dynamic func b() throws {
//
//  }
//}

//extension TestFileHandle {
//    @objc override func readToEnd() throws -> Data? {
//      readToEndCalled = true
//    }
//}
