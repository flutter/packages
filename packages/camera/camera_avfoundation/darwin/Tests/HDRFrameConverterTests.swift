// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import CoreVideo
import XCTest

@testable import camera_avfoundation

final class HDRFrameConverterTests: XCTestCase {
  /// A 10-bit video range frame of one luma value and neutral chroma.
  private func makeGrayFrame(width: Int, height: Int, luma10: UInt16) -> CVPixelBuffer {
    var buffer: CVPixelBuffer?
    CVPixelBufferCreate(
      nil, width, height, kCVPixelFormatType_420YpCbCr10BiPlanarVideoRange, nil, &buffer)
    let pixelBuffer = buffer!
    CVPixelBufferLockBaseAddress(pixelBuffer, [])
    for (plane, value) in [(0, luma10), (1, UInt16(512))] {
      let base = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, plane)!
      let rowBytes = CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, plane)
      for row in 0..<CVPixelBufferGetHeightOfPlane(pixelBuffer, plane) {
        let samples = base.advanced(by: row * rowBytes).assumingMemoryBound(to: UInt16.self)
        for i in 0..<(rowBytes / 2) {
          samples[i] = value << 6
        }
      }
    }
    CVPixelBufferUnlockBaseAddress(pixelBuffer, [])
    return pixelBuffer
  }

  private func convert(_ frame: CVPixelBuffer, to format: FourCharCode) -> [HDRFrameConverter
    .Plane]?
  {
    CVPixelBufferLockBaseAddress(frame, .readOnly)
    defer { CVPixelBufferUnlockBaseAddress(frame, .readOnly) }
    return HDRFrameConverter().convert(frame, to: format)
  }

  func testConvertsToEightBitYUVWithTheSameLayout() throws {
    let planes = try XCTUnwrap(
      convert(
        makeGrayFrame(width: 64, height: 32, luma10: 700),
        to: kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange))

    XCTAssertEqual(planes.count, 2)
    XCTAssertEqual([planes[0].width, planes[0].height, planes[0].bytesPerRow], [64, 32, 64])
    XCTAssertEqual([planes[1].width, planes[1].height, planes[1].bytesPerRow], [32, 16, 64])
    XCTAssertEqual(Int(planes[0].bytes[0]), 175, accuracy: 1)  // 700 / 4
    XCTAssertEqual(Int(planes[1].bytes[0]), 128, accuracy: 1)
  }

  func testConvertsToBGRAWithNeutralGray() throws {
    let planes = try XCTUnwrap(
      convert(makeGrayFrame(width: 64, height: 32, luma10: 700), to: kCVPixelFormatType_32BGRA))

    XCTAssertEqual(planes.count, 1)
    XCTAssertEqual([planes[0].width, planes[0].height, planes[0].bytesPerRow], [64, 32, 256])
    // Video range 175 is (175 - 16) * 255 / 219 in full range.
    let pixel = Array(planes[0].bytes.prefix(4)).map(Int.init)
    for channel in pixel.prefix(3) {
      XCTAssertEqual(channel, 185, accuracy: 2)
    }
    XCTAssertEqual(pixel[3], 255)
  }

  func testReturnsNilForEightBitFrames() {
    var buffer: CVPixelBuffer?
    CVPixelBufferCreate(nil, 16, 16, kCVPixelFormatType_32BGRA, nil, &buffer)
    XCTAssertNil(convert(buffer!, to: kCVPixelFormatType_32BGRA))
  }
}
