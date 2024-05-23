// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import XCTest

@testable import file_selector_ios

final class TestViewPresenter: ViewPresenter {
  public var presentedController: UIViewController?

  func present(
    _ viewControllerToPresent: UIViewController, animated: Bool, completion: (() -> Void)? = nil
  ) {
    presentedController = viewControllerToPresent
  }
}

class FileSelectorTests: XCTestCase {
  func testPickerPresents() throws {
    let plugin = FileSelectorPlugin()
    let picker = UIDocumentPickerViewController(documentTypes: [], in: UIDocumentPickerMode.import)
    let presenter = TestViewPresenter()
    plugin.documentPickerViewControllerOverride = picker
    plugin.viewPresenterOverride = presenter

    plugin.openFile(
      config: FileSelectorConfig(utis: [], allowMultiSelection: false)
    ) { _ in }

    XCTAssertEqual(plugin.pendingCompletions.count, 1)
    XCTAssertTrue(picker.delegate === plugin.pendingCompletions.first)
    XCTAssertTrue(presenter.presentedController === picker)
  }

  func testReturnsPickedFiles() throws {
    let plugin = FileSelectorPlugin()
    let picker = UIDocumentPickerViewController(documentTypes: [], in: UIDocumentPickerMode.import)
    plugin.documentPickerViewControllerOverride = picker
    plugin.viewPresenterOverride = TestViewPresenter()
    let completionWasCalled = expectation(description: "completion")

    plugin.openFile(
      config: FileSelectorConfig(utis: [], allowMultiSelection: false)
    ) { result in
      switch result {
      case .success(let paths):
        XCTAssertEqual(paths, ["/file1.txt", "/file2.txt"])
      case .failure(let error):
        XCTFail("\(error)")
      }
      completionWasCalled.fulfill()
    }
    plugin.pendingCompletions.first!.documentPicker(
      picker,
      didPickDocumentsAt: [URL(string: "file:///file1.txt")!, URL(string: "file:///file2.txt")!])

    waitForExpectations(timeout: 30.0)
    XCTAssertTrue(plugin.pendingCompletions.isEmpty)
  }

  func testCancellingPickerReturnsEmptyList() throws {
    let plugin = FileSelectorPlugin()
    let picker = UIDocumentPickerViewController(documentTypes: [], in: UIDocumentPickerMode.import)
    plugin.documentPickerViewControllerOverride = picker
    plugin.viewPresenterOverride = TestViewPresenter()
    let completionWasCalled = expectation(description: "completion")

    plugin.openFile(
      config: FileSelectorConfig(utis: [], allowMultiSelection: false)
    ) { result in
      switch result {
      case .success(let paths):
        XCTAssertEqual(paths.count, 0)
      case .failure(let error):
        XCTFail("\(error)")
      }
      completionWasCalled.fulfill()
    }
    plugin.pendingCompletions.first!.documentPickerWasCancelled(picker)

    waitForExpectations(timeout: 30.0)
    XCTAssertTrue(plugin.pendingCompletions.isEmpty)
  }
}
