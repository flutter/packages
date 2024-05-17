// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import XCTest
import file_selector_ios
import file_selector_ios.Test

class TestViewPresenter: NSObject, FFSViewPresenter {
  public var presentedController: UIViewController?

  func present(
    _ viewControllerToPresent: UIViewController, animated: Bool, completion: (() -> Void)? = nil
  ) {
    presentedController = viewControllerToPresent
  }
}

class FileSelectorTests: XCTestCase {
  func testPickerPresents() throws {
    let plugin = FFSFileSelectorPlugin()
    let picker = UIDocumentPickerViewController(documentTypes: [], in: UIDocumentPickerMode.import)
    let presenter = TestViewPresenter()
    plugin.documentPickerViewControllerOverride = picker
    plugin.viewPresenterOverride = presenter

    plugin.openFileSelector(
      with: FFSFileSelectorConfig.make(withUtis: [], allowMultiSelection: false)
    ) { _, _ in }

    XCTAssertTrue(picker.delegate === plugin)
    XCTAssertTrue(presenter.presentedController === picker)
  }

  func testReturnsPickedFiles() throws {
    let plugin = FFSFileSelectorPlugin()
    let picker = UIDocumentPickerViewController(documentTypes: [], in: UIDocumentPickerMode.import)
    plugin.documentPickerViewControllerOverride = picker
    let completionWasCalled = expectation(description: "completion")

    plugin.openFileSelector(
      with: FFSFileSelectorConfig.make(withUtis: [], allowMultiSelection: false)
    ) { paths, error in
      let expectedPaths = ["/file1.txt", "/file2.txt"]
      XCTAssertEqual(paths, expectedPaths)
      completionWasCalled.fulfill()
    }
    plugin.documentPicker(
      picker,
      didPickDocumentsAt: [URL(string: "file:///file1.txt")!, URL(string: "file:///file2.txt")!])

    waitForExpectations(timeout: 30.0)
  }

  func testCancellingPickerReturnsEmptyList() throws {
    let plugin = FFSFileSelectorPlugin()
    let picker = UIDocumentPickerViewController(documentTypes: [], in: UIDocumentPickerMode.import)
    plugin.documentPickerViewControllerOverride = picker
    let completionWasCalled = expectation(description: "completion")

    plugin.openFileSelector(
      with: FFSFileSelectorConfig.make(withUtis: [], allowMultiSelection: false)
    ) { paths, error in
      XCTAssertEqual(paths!.count, 0)
      completionWasCalled.fulfill()
    }
    plugin.documentPickerWasCancelled(picker)

    waitForExpectations(timeout: 30.0)
  }
}
