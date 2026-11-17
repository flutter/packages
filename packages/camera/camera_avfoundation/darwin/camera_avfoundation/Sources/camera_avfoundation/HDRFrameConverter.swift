// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Accelerate
import CoreVideo

/// Converts the 10-bit frames of an HDR session into the 8-bit formats that image streaming
/// delivers, so streaming does not need to reconfigure the running session.
final class HDRFrameConverter {
  /// One converted plane, laid out like the plane of a native 8-bit pixel buffer.
  struct Plane {
    let bytes: Data
    let bytesPerRow: Int
    let width: Int
    let height: Int
  }

  private var yuvToARGB = vImage_YpCbCrToARGB()
  private var isYUVToARGBReady = false

  /// Converts a locked `kCVPixelFormatType_420YpCbCr10BiPlanarVideoRange` buffer into `format`,
  /// which is `kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange` or `kCVPixelFormatType_32BGRA`.
  /// Returns nil for any other combination.
  func convert(_ pixelBuffer: CVPixelBuffer, to format: FourCharCode) -> [Plane]? {
    guard CVPixelBufferGetPixelFormatType(pixelBuffer) == FormatUtils.hlgPixelFormat,
      CVPixelBufferGetPlaneCount(pixelBuffer) == 2
    else {
      return nil
    }
    guard let luma = narrow(pixelBuffer, plane: 0, samplesPerPixel: 1),
      let chroma = narrow(pixelBuffer, plane: 1, samplesPerPixel: 2)
    else {
      return nil
    }
    switch format {
    case kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange:
      return [luma, chroma]
    case kCVPixelFormatType_32BGRA:
      return toBGRA(luma: luma, chroma: chroma).map { [$0] }
    default:
      return nil
    }
  }

  /// Scales the 16-bit samples, which hold 10-bit values in their high bits, to 8 bits. This maps
  /// 10-bit video range onto 8-bit video range to within one code value.
  private func narrow(_ pixelBuffer: CVPixelBuffer, plane: Int, samplesPerPixel: Int) -> Plane? {
    guard let base = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, plane) else { return nil }
    let width = CVPixelBufferGetWidthOfPlane(pixelBuffer, plane)
    let height = CVPixelBufferGetHeightOfPlane(pixelBuffer, plane)
    let samples = width * samplesPerPixel
    var output = Data(count: samples * height)
    var source = vImage_Buffer(
      data: base, height: vImagePixelCount(height), width: vImagePixelCount(samples),
      rowBytes: CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, plane))
    let error = output.withUnsafeMutableBytes { raw -> vImage_Error in
      var destination = vImage_Buffer(
        data: raw.baseAddress, height: vImagePixelCount(height),
        width: vImagePixelCount(samples), rowBytes: samples)
      return vImageConvert_16UToPlanar8(&source, &destination, vImage_Flags(kvImageNoFlags))
    }
    guard error == kvImageNoError else { return nil }
    return Plane(bytes: output, bytesPerRow: samples, width: width, height: height)
  }

  private func toBGRA(luma: Plane, chroma: Plane) -> Plane? {
    if !isYUVToARGBReady {
      // BT.2020 non-constant luminance, which HLG frames use.
      var matrix = vImage_YpCbCrToARGBMatrix(
        Yp: 1, Cr_R: 1.4746, Cr_G: -0.571_35, Cb_G: -0.164_55, Cb_B: 1.8814)
      var range = vImage_YpCbCrPixelRange(
        Yp_bias: 16, CbCr_bias: 128, YpRangeMax: 235, CbCrRangeMax: 240, YpMax: 235, YpMin: 16,
        CbCrMax: 240, CbCrMin: 16)
      guard
        vImageConvert_YpCbCrToARGB_GenerateConversion(
          &matrix, &range, &yuvToARGB, kvImage420Yp8_CbCr8, kvImageARGB8888,
          vImage_Flags(kvImageNoFlags)) == kvImageNoError
      else {
        return nil
      }
      isYUVToARGBReady = true
    }
    let width = luma.width
    let height = luma.height
    var output = Data(count: width * 4 * height)
    var lumaBytes = luma.bytes
    var chromaBytes = chroma.bytes
    let error = lumaBytes.withUnsafeMutableBytes { lumaRaw in
      chromaBytes.withUnsafeMutableBytes { chromaRaw in
        output.withUnsafeMutableBytes { outRaw -> vImage_Error in
          var y = vImage_Buffer(
            data: lumaRaw.baseAddress, height: vImagePixelCount(height),
            width: vImagePixelCount(width), rowBytes: luma.bytesPerRow)
          var cbcr = vImage_Buffer(
            data: chromaRaw.baseAddress, height: vImagePixelCount(chroma.height),
            width: vImagePixelCount(chroma.width), rowBytes: chroma.bytesPerRow)
          var bgra = vImage_Buffer(
            data: outRaw.baseAddress, height: vImagePixelCount(height),
            width: vImagePixelCount(width), rowBytes: width * 4)
          // ARGB to BGRA.
          let permute: [UInt8] = [3, 2, 1, 0]
          return vImageConvert_420Yp8_CbCr8ToARGB8888(
            &y, &cbcr, &bgra, &yuvToARGB, permute, 255, vImage_Flags(kvImageNoFlags))
        }
      }
    }
    guard error == kvImageNoError else { return nil }
    return Plane(bytes: output, bytesPerRow: width * 4, width: width, height: height)
  }
}
