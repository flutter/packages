// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import FlutterMacOS
import UniformTypeIdentifiers
import XCTest

@testable import file_selector_macos

class TestPanelController: NSObject, PanelController {
  // The last panels that the relevant display methods were called on.
  public var savePanel: NSSavePanel?
  public var openPanel: NSOpenPanel?

  // Mock return values for the display methods.
  public var saveURL: URL?
  public var openURLs: [URL]?

  func display(
    _ panel: NSSavePanel, for window: NSWindow?, completionHandler handler: @escaping (URL?) -> Void
  ) {
    savePanel = panel
    handler(saveURL)
  }

  func display(
    _ panel: NSOpenPanel, for window: NSWindow?,
    completionHandler handler: @escaping ([URL]?) -> Void
  ) {
    openPanel = panel
    handler(openURLs)
  }
}

class TestViewProvider: NSObject, ViewProvider {
  var view: NSView? {
    window?.contentView
  }
  var window: NSWindow? = NSWindow()
}

class exampleTests: XCTestCase {

  func testOpenSimple() throws {
    let panelController = TestPanelController()
    let plugin = FileSelectorPlugin(
      viewProvider: TestViewProvider(),
      panelController: panelController)

    let returnPath = "/foo/bar"
    panelController.openURLs = [URL(fileURLWithPath: returnPath)]

    let called = XCTestExpectation()
    let options = OpenPanelOptions(
      allowsMultipleSelection: false,
      canChooseDirectories: false,
      canChooseFiles: true,
      baseOptions: SavePanelOptions())
    plugin.displayOpenPanel(options: options) { result in
      switch result {
      case .success(let paths):
        XCTAssertEqual(paths[0], returnPath)
      case .failure(let error):
        XCTFail("\(error)")
      }
      called.fulfill()
    }

    wait(for: [called], timeout: 0.5)
    XCTAssertNotNil(panelController.openPanel)
    if let panel = panelController.openPanel {
      XCTAssertTrue(panel.canChooseFiles)
      // For consistency across platforms, directory selection is disabled.
      XCTAssertFalse(panel.canChooseDirectories)
    }
  }

  func testOpenWithArguments() throws {
    let panelController = TestPanelController()
    let plugin = FileSelectorPlugin(
      viewProvider: TestViewProvider(),
      panelController: panelController)

    let returnPath = "/foo/bar"
    panelController.openURLs = [URL(fileURLWithPath: returnPath)]

    let called = XCTestExpectation()
    let options = OpenPanelOptions(
      allowsMultipleSelection: false,
      canChooseDirectories: false,
      canChooseFiles: true,
      baseOptions: SavePanelOptions(
        directoryPath: "/some/dir",
        nameFieldStringValue: "a name",
        prompt: "Open it!"))
    plugin.displayOpenPanel(options: options) { result in
      switch result {
      case .success(let paths):
        XCTAssertEqual(paths[0], returnPath)
      case .failure(let error):
        XCTFail("\(error)")
      }
      called.fulfill()
    }

    wait(for: [called], timeout: 0.5)
    XCTAssertNotNil(panelController.openPanel)
    if let panel = panelController.openPanel {
      XCTAssertEqual(panel.directoryURL?.path, "/some/dir")
      XCTAssertEqual(panel.nameFieldStringValue, "a name")
      XCTAssertEqual(panel.prompt, "Open it!")
    }
  }

  func testOpenMultiple() throws {
    let panelController = TestPanelController()
    let plugin = FileSelectorPlugin(
      viewProvider: TestViewProvider(),
      panelController: panelController)

    let returnPaths = ["/foo/bar", "/foo/baz"]
    panelController.openURLs = returnPaths.map({ path in URL(fileURLWithPath: path) })

    let called = XCTestExpectation()
    let options = OpenPanelOptions(
      allowsMultipleSelection: true,
      canChooseDirectories: false,
      canChooseFiles: true,
      baseOptions: SavePanelOptions())
    plugin.displayOpenPanel(options: options) { result in
      switch result {
      case .success(let paths):
        XCTAssertEqual(paths.count, returnPaths.count)
        XCTAssertEqual(paths[0], returnPaths[0])
        XCTAssertEqual(paths[1], returnPaths[1])
      case .failure(let error):
        XCTFail("\(error)")
      }
      called.fulfill()
    }

    wait(for: [called], timeout: 0.5)
    XCTAssertNotNil(panelController.openPanel)
  }

  func testOpenWithFilter() throws {
    let panelController = TestPanelController()
    let plugin = FileSelectorPlugin(
      viewProvider: TestViewProvider(),
      panelController: panelController)

    let returnPath = "/foo/bar"
    panelController.openURLs = [URL(fileURLWithPath: returnPath)]

    let called = XCTestExpectation()
    let options = OpenPanelOptions(
      allowsMultipleSelection: true,
      canChooseDirectories: false,
      canChooseFiles: true,
      baseOptions: SavePanelOptions(
        allowedFileTypes: AllowedTypes(
          extensions: ["txt", "json"],
          mimeTypes: ["text/html"],
          utis: ["public.text", "public.image"])))
    plugin.displayOpenPanel(options: options) { result in
      switch result {
      case .success(let paths):
        XCTAssertEqual(paths[0], returnPath)
      case .failure(let error):
        XCTFail("\(error)")
      }
      called.fulfill()
    }

    wait(for: [called], timeout: 0.5)
    XCTAssertNotNil(panelController.openPanel)
    if let panel = panelController.openPanel {
      if #available(macOS 11.0, *) {
        XCTAssertTrue(panel.allowedContentTypes.contains(UTType.plainText))
        XCTAssertTrue(panel.allowedContentTypes.contains(UTType.json))
        XCTAssertTrue(panel.allowedContentTypes.contains(UTType.html))
        XCTAssertTrue(panel.allowedContentTypes.contains(UTType.image))
      } else {
        // MIME type is not supported for the legacy codepath, but the rest should be set.
        XCTAssertEqual(panel.allowedFileTypes, ["txt", "json", "public.text", "public.image"])
      }
    }
  }

  func testOpenWithFilterLegacy() throws {
    let panelController = TestPanelController()
    let plugin = FileSelectorPlugin(
      viewProvider: TestViewProvider(),
      panelController: panelController)
    plugin.forceLegacyTypes = true

    let returnPath = "/foo/bar"
    panelController.openURLs = [URL(fileURLWithPath: returnPath)]

    let called = XCTestExpectation()
    let options = OpenPanelOptions(
      allowsMultipleSelection: true,
      canChooseDirectories: false,
      canChooseFiles: true,
      baseOptions: SavePanelOptions(
        allowedFileTypes: AllowedTypes(
          extensions: ["txt", "json"],
          mimeTypes: ["text/html"],
          utis: ["public.text", "public.image"])))
    plugin.displayOpenPanel(options: options) { result in
      switch result {
      case .success(let paths):
        XCTAssertEqual(paths[0], returnPath)
      case .failure(let error):
        XCTFail("\(error)")
      }
      called.fulfill()
    }

    wait(for: [called], timeout: 0.5)
    XCTAssertNotNil(panelController.openPanel)
    if let panel = panelController.openPanel {
      // On the legacy path, the allowedFileTypes should be set directly.
      XCTAssertEqual(panel.allowedFileTypes, ["txt", "json", "public.text", "public.image"])

      // They should also be translated to corresponding allowed content types.
      if #available(macOS 11.0, *) {
        XCTAssertTrue(panel.allowedContentTypes.contains(UTType.plainText))
        XCTAssertTrue(panel.allowedContentTypes.contains(UTType.json))
        XCTAssertTrue(panel.allowedContentTypes.contains(UTType.image))
        // MIME type is not supported for the legacy codepath.
        XCTAssertFalse(panel.allowedContentTypes.contains(UTType.html))
      }
    }
  }

  func testOpenCancel() throws {
    let panelController = TestPanelController()
    let plugin = FileSelectorPlugin(
      viewProvider: TestViewProvider(),
      panelController: panelController)

    let called = XCTestExpectation()
    let options = OpenPanelOptions(
      allowsMultipleSelection: false,
      canChooseDirectories: false,
      canChooseFiles: true,
      baseOptions: SavePanelOptions())
    plugin.displayOpenPanel(options: options) { result in
      switch result {
      case .success(let paths):
        XCTAssertEqual(paths.count, 0)
      case .failure(let error):
        XCTFail("\(error)")
      }
      called.fulfill()
    }

    wait(for: [called], timeout: 0.5)
    XCTAssertNotNil(panelController.openPanel)
  }

  func testSaveSimple() throws {
    let panelController = TestPanelController()
    let plugin = FileSelectorPlugin(
      viewProvider: TestViewProvider(),
      panelController: panelController)

    let returnPath = "/foo/bar"
    panelController.saveURL = URL(fileURLWithPath: returnPath)

    let called = XCTestExpectation()
    let options = SavePanelOptions()
    plugin.displaySavePanel(options: options) { result in
      switch result {
      case .success(let path):
        XCTAssertEqual(path, returnPath)
      case .failure(let error):
        XCTFail("\(error)")
      }
      called.fulfill()
    }

    wait(for: [called], timeout: 0.5)
    XCTAssertNotNil(panelController.savePanel)
  }

  func testSaveWithArguments() throws {
    let panelController = TestPanelController()
    let plugin = FileSelectorPlugin(
      viewProvider: TestViewProvider(),
      panelController: panelController)

    let returnPath = "/foo/bar"
    panelController.saveURL = URL(fileURLWithPath: returnPath)

    let called = XCTestExpectation()
    let options = SavePanelOptions(
      directoryPath: "/some/dir",
      prompt: "Save it!")
    plugin.displaySavePanel(options: options) { result in
      switch result {
      case .success(let path):
        XCTAssertEqual(path, returnPath)
      case .failure(let error):
        XCTFail("\(error)")
      }
      called.fulfill()
    }

    wait(for: [called], timeout: 0.5)
    XCTAssertNotNil(panelController.savePanel)
    if let panel = panelController.savePanel {
      XCTAssertEqual(panel.directoryURL?.path, "/some/dir")
      XCTAssertEqual(panel.prompt, "Save it!")
    }
  }

  func testSaveCancel() throws {
    let panelController = TestPanelController()
    let plugin = FileSelectorPlugin(
      viewProvider: TestViewProvider(),
      panelController: panelController)

    let called = XCTestExpectation()
    let options = SavePanelOptions()
    plugin.displaySavePanel(options: options) { result in
      switch result {
      case .success(let path):
        XCTAssertNil(path)
      case .failure(let error):
        XCTFail("\(error)")
      }
      called.fulfill()
    }

    wait(for: [called], timeout: 0.5)
    XCTAssertNotNil(panelController.savePanel)
  }

  func testGetDirectorySimple() throws {
    let panelController = TestPanelController()
    let plugin = FileSelectorPlugin(
      viewProvider: TestViewProvider(),
      panelController: panelController)

    let returnPath = "/foo/bar"
    panelController.openURLs = [URL(fileURLWithPath: returnPath)]

    let called = XCTestExpectation()
    let options = OpenPanelOptions(
      allowsMultipleSelection: false,
      canChooseDirectories: true,
      canChooseFiles: false,
      baseOptions: SavePanelOptions())
    plugin.displayOpenPanel(options: options) { result in
      switch result {
      case .success(let paths):
        XCTAssertEqual(paths[0], returnPath)
      case .failure(let error):
        XCTFail("\(error)")
      }
      called.fulfill()
    }

    wait(for: [called], timeout: 0.5)
    XCTAssertNotNil(panelController.openPanel)
    if let panel = panelController.openPanel {
      XCTAssertTrue(panel.canChooseDirectories)
      // For consistency across platforms, file selection is disabled.
      XCTAssertFalse(panel.canChooseFiles)
      // The Dart API only allows a single directory to be returned, so users shouldn't be allowed
      // to select multiple.
      XCTAssertFalse(panel.allowsMultipleSelection)
    }
  }

  func testGetDirectoryCancel() throws {
    let panelController = TestPanelController()
    let plugin = FileSelectorPlugin(
      viewProvider: TestViewProvider(),
      panelController: panelController)

    let called = XCTestExpectation()
    let options = OpenPanelOptions(
      allowsMultipleSelection: false,
      canChooseDirectories: true,
      canChooseFiles: false,
      baseOptions: SavePanelOptions())
    plugin.displayOpenPanel(options: options) { result in
      switch result {
      case .success(let paths):
        XCTAssertEqual(paths.count, 0)
      case .failure(let error):
        XCTFail("\(error)")
      }
      called.fulfill()
    }

    wait(for: [called], timeout: 0.5)
    XCTAssertNotNil(panelController.openPanel)
  }

  func testGetDirectoriesMultiple() throws {
    let panelController = TestPanelController()
    let plugin = FileSelectorPlugin(
      viewProvider: TestViewProvider(),
      panelController: panelController)

    let returnPaths = ["/foo/bar", "/foo/test"];
    panelController.openURLs = returnPaths.map({ path in URL(fileURLWithPath: path) })

    let called = XCTestExpectation()
    let options = OpenPanelOptions(
      allowsMultipleSelection: true,
      canChooseDirectories: true,
      canChooseFiles: false,
      baseOptions: SavePanelOptions())
    plugin.displayOpenPanel(options: options) { result in
      switch result {
      case .success(let paths):
        XCTAssertEqual(paths, returnPaths)
      case .failure(let error):
        XCTFail("\(error)")
      }
      called.fulfill()
    }

    wait(for: [called], timeout: 0.5)
    XCTAssertNotNil(panelController.openPanel)
    if let panel = panelController.openPanel {
      XCTAssertTrue(panel.canChooseDirectories)
      // For consistency across platforms, file selection is disabled.
      XCTAssertFalse(panel.canChooseFiles)
      XCTAssertTrue(panel.allowsMultipleSelection)
    }
  }

  func testGetDirectoryMultipleCancel() throws {
    let panelController = TestPanelController()
    let plugin = FileSelectorPlugin(
      viewProvider: TestViewProvider(),
      panelController: panelController)

    let called = XCTestExpectation()
    let options = OpenPanelOptions(
      allowsMultipleSelection: true,
      canChooseDirectories: true,
      canChooseFiles: false,
      baseOptions: SavePanelOptions())
    plugin.displayOpenPanel(options: options) { result in
      switch result {
      case .success(let paths):
        XCTAssertEqual(paths.count, 0)
      case .failure(let error):
        XCTFail("\(error)")
      }
      called.fulfill()
    }

    wait(for: [called], timeout: 0.5)
    XCTAssertNotNil(panelController.openPanel)
  }
}
