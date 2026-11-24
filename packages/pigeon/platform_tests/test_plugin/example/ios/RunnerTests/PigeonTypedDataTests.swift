// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import Foundation
import XCTest

@testable import test_plugin

class NiTestsPigeonTypedDataTests: XCTestCase {

  // Helper to create NSData from an array of numbers
  private func makeData<T>(from array: [T]) -> NSData {
    return array.withUnsafeBufferPointer { buffer in
      NSData(bytes: buffer.baseAddress, length: buffer.count * MemoryLayout<T>.stride)
    }
  }

  func testUint8Array() {
    let sourceArray: [UInt8] = [1, 2, 3, 4, 255]
    let data = makeData(from: sourceArray)
    let typedData = NiTestsPigeonTypedData(data: data, type: NiTestsMyDataType.uint8.rawValue)

    XCTAssert(typedData.toUint8Array() == sourceArray)

    let wrongType = NiTestsPigeonTypedData(data: data, type: NiTestsMyDataType.int32.rawValue)
    XCTAssert(wrongType.toUint8Array() == nil)
  }

  func testInt32Array() {
    let sourceArray: [Int32] = [-1, 0, 1, Int32.max, Int32.min]
    let data = makeData(from: sourceArray)
    let typedData = NiTestsPigeonTypedData(data: data, type: NiTestsMyDataType.int32.rawValue)

    XCTAssert(typedData.toInt32Array() == sourceArray)

    let wrongType = NiTestsPigeonTypedData(data: data, type: NiTestsMyDataType.uint8.rawValue)
    XCTAssert(wrongType.toInt32Array() == nil)

    let badData = data.subdata(with: NSRange(location: 0, length: data.length - 1))
    let invalidLength = NiTestsPigeonTypedData(
      data: badData as NSData, type: NiTestsMyDataType.int32.rawValue)
    XCTAssert(invalidLength.toInt32Array() == nil)
  }

  func testInt64Array() {
    let sourceArray: [Int64] = [-1, 0, 1, Int64.max, Int64.min]
    let data = makeData(from: sourceArray)
    let typedData = NiTestsPigeonTypedData(data: data, type: NiTestsMyDataType.int64.rawValue)

    XCTAssert(typedData.toInt64Array() == sourceArray)
  }

  func testFloat32Array() {
    let sourceArray: [Float32] = [
      -1.5, 0.0, 1.5, Float32.greatestFiniteMagnitude, -Float32.greatestFiniteMagnitude,
    ]
    let data = makeData(from: sourceArray)
    let typedData = NiTestsPigeonTypedData(data: data, type: NiTestsMyDataType.float32.rawValue)

    XCTAssert(typedData.toFloat32Array() == sourceArray)
  }

  func testFloat64Array() {
    let sourceArray: [Double] = [
      -1.5, 0.0, 1.5, Double.greatestFiniteMagnitude, -Double.greatestFiniteMagnitude,
    ]
    let data = makeData(from: sourceArray)
    let typedData = NiTestsPigeonTypedData(data: data, type: NiTestsMyDataType.float64.rawValue)

    XCTAssert(typedData.toFloat64Array() == sourceArray)
  }
}
