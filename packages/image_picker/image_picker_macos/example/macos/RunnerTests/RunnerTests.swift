// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import XCTest

@testable import image_picker_macos

final class RunnerTests: XCTestCase {

  func testSupportsPHPicker() {
    let imagePicker = ImagePickerImpl()
    if #available(macOS 13.0, *) {
      XCTAssertTrue(
        imagePicker.supportsPHPicker(),
        "PHPicker is expected to be supported on macOS 13.0 and newer versions.")
    } else {
      XCTAssertFalse(
        imagePicker.supportsPHPicker(),
        "PHPicker is expected to be unsupported on macOS versions older than 13.0.")
    }
  }

  func testImageFileType() {
    XCTAssertEqual(
      imageFileType(quality: 100), NSBitmapImageRep.FileType.png,
      "Quality 100 should return PNG file type.")
    XCTAssertEqual(
      imageFileType(quality: 99), NSBitmapImageRep.FileType.jpeg,
      "Quality below 100 should return JPEG file type.")
    XCTAssertEqual(
      imageFileType(quality: nil), NSBitmapImageRep.FileType.png,
      "Quality nil should return PNG file type.")
  }

  func testImageFileExt() {
    XCTAssertEqual(
      imageFileExt(fileType: NSBitmapImageRep.FileType.png), "png",
      "File extension for PNG should be 'png'.")
    XCTAssertEqual(
      imageFileExt(fileType: NSBitmapImageRep.FileType.jpeg), "jpeg",
      "File extension for JPEG should be 'jpeg'.")
  }

  func testGenerateUniqueImageFileName() {
    let fileType = NSBitmapImageRep.FileType.jpeg
    let generatedFileName = generateUniqueImageFileName(imageFileType: fileType)
    let expectedExtension = imageFileExt(fileType: fileType)

    // Extract the UUID part of the generated file name
    let uuidStringFromFile = generatedFileName.replacingOccurrences(
      of: ".\(expectedExtension)", with: "")

    let fileUUID = UUID(uuidString: uuidStringFromFile)

    XCTAssertNotNil(fileUUID, "Generated file name should start with a valid UUID.")
    XCTAssertTrue(
      generatedFileName.hasSuffix(".\(expectedExtension)"),
      "Generated file name should have a '\(expectedExtension)' extension.")
  }

  func testGenerateTempImageFilePath() {
    let fileType: NSBitmapImageRep.FileType = NSBitmapImageRep.FileType.png
    let filePath = generateTempImageFilePath(imageFileType: fileType)
    let fileExists = FileManager.default.fileExists(atPath: filePath.path)

    XCTAssertFalse(fileExists, "The file at path \(filePath) should not exist.")
    XCTAssertEqual(filePath.pathExtension, "png", "The file path should have a .png extension.")
    XCTAssertTrue(
      filePath.absoluteString.hasPrefix(FileManager.default.temporaryDirectory.absoluteString),
      "The file path should be in the temporary directory.")

    XCTAssertTrue(filePath.isFileURL, "The generated path should be a file URL.")

    let anotherFilePath = generateTempImageFilePath(imageFileType: fileType)
    XCTAssertNotEqual(filePath, anotherFilePath, "The generated file paths should be unique.")
  }

  func testPathString() {
    let tempDirectory = FileManager.default.temporaryDirectory
    let fileURL = tempDirectory.appendingPathComponent("flutter.dart")

    XCTAssertEqual(
      fileURL.path, fileURL.pathString(),
      "Expected pathString() to match `URL.path` for the current URL.")

    if #available(macOS 13.0, *) {
      XCTAssertEqual(
        fileURL.path(), fileURL.pathString(),
        "Expected pathString() to match `URL.path()` for macOS 13.0 and later.")
    }
  }

}
