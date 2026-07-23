// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import FlutterMacOS
import Testing
import UniformTypeIdentifiers

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

@Suite @MainActor struct ExampleTests {

  @Test func openSimple() async throws {
    let panelController = TestPanelController()
    let plugin = FileSelectorPlugin(
      viewProvider: TestViewProvider(),
      panelController: panelController)

    let returnPath = "/foo/bar"
    panelController.openURLs = [URL(fileURLWithPath: returnPath)]

    await confirmation("completion") { called in
      let options = OpenPanelOptions(
        allowsMultipleSelection: false,
        canChooseDirectories: false,
        canChooseFiles: true,
        baseOptions: SavePanelOptions())
      plugin.displayOpenPanel(options: options) { result in
        switch result {
        case .success(let paths):
          #expect(paths == [returnPath])
        case .failure(let error):
          Issue.record("\(error)")
        }
        called()
      }
    }

    let panel = try #require(panelController.openPanel)
    #expect(panel.canChooseFiles)
    // For consistency across platforms, directory selection is disabled.
    #expect(!panel.canChooseDirectories)
  }

  @Test func openWithArguments() async throws {
    let panelController = TestPanelController()
    let plugin = FileSelectorPlugin(
      viewProvider: TestViewProvider(),
      panelController: panelController)

    let returnPath = "/foo/bar"
    panelController.openURLs = [URL(fileURLWithPath: returnPath)]

    await confirmation("completion") { called in
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
          #expect(paths == [returnPath])
        case .failure(let error):
          Issue.record("\(error)")
        }
        called()
      }
    }

    let panel = try #require(panelController.openPanel)
    #expect(panel.directoryURL?.path == "/some/dir")
    // nameFieldStringValue is not set for NSOpenPanel, only for NSSavePanel
    #expect(panel.nameFieldStringValue != "a name")
    #expect(panel.prompt == "Open it!")
  }

  @Test func openMultiple() async throws {
    let panelController = TestPanelController()
    let plugin = FileSelectorPlugin(
      viewProvider: TestViewProvider(),
      panelController: panelController)

    let returnPaths = ["/foo/bar", "/foo/baz"]
    panelController.openURLs = returnPaths.map({ path in URL(fileURLWithPath: path) })

    await confirmation("completion") { called in
      let options = OpenPanelOptions(
        allowsMultipleSelection: true,
        canChooseDirectories: false,
        canChooseFiles: true,
        baseOptions: SavePanelOptions())
      plugin.displayOpenPanel(options: options) { result in
        switch result {
        case .success(let paths):
          #expect(paths == returnPaths)
        case .failure(let error):
          Issue.record("\(error)")
        }
        called()
      }
    }

    _ = try #require(panelController.openPanel)
  }

  @Test func openWithFilter() async throws {
    let panelController = TestPanelController()
    let plugin = FileSelectorPlugin(
      viewProvider: TestViewProvider(),
      panelController: panelController)

    let returnPath = "/foo/bar"
    panelController.openURLs = [URL(fileURLWithPath: returnPath)]

    await confirmation("completion") { called in
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
          #expect(paths == [returnPath])
        case .failure(let error):
          Issue.record("\(error)")
        }
        called()
      }
    }

    let panel = try #require(panelController.openPanel)
    if #available(macOS 11.0, *) {
      #expect(panel.allowedContentTypes.contains(UTType.plainText))
      #expect(panel.allowedContentTypes.contains(UTType.json))
      #expect(panel.allowedContentTypes.contains(UTType.html))
      #expect(panel.allowedContentTypes.contains(UTType.image))
    } else {
      // MIME type is not supported for the legacy codepath, but the rest should be set.
      #expect(panel.allowedFileTypes == ["txt", "json", "public.text", "public.image"])
    }
  }

  @Test func filterUnknownFileExtension() async throws {
    let panelController = TestPanelController()
    let plugin = FileSelectorPlugin(
      viewProvider: TestViewProvider(),
      panelController: panelController)

    let unknownExtension = "somenewextension"
    let returnPath = "/foo/bar"
    panelController.openURLs = [URL(fileURLWithPath: returnPath)]

    await confirmation("completion") { called in
      let options = OpenPanelOptions(
        allowsMultipleSelection: true,
        canChooseDirectories: false,
        canChooseFiles: true,
        baseOptions: SavePanelOptions(
          allowedFileTypes: AllowedTypes(
            extensions: [unknownExtension],
            mimeTypes: [],
            utis: [])))
      plugin.displayOpenPanel(options: options) { result in
        switch result {
        case .success(let paths):
          #expect(paths == [returnPath])
        case .failure(let error):
          Issue.record("\(error)")
        }
        called()
      }
    }

    let panel = try #require(panelController.openPanel)
    if #available(macOS 11.0, *) {
      #expect(panel.allowedContentTypes.count == 1)
      #expect(panel.allowedContentTypes[0].preferredFilenameExtension == unknownExtension)
      // If this isn't true, the dynamic type created for the extension won't work as a file
      // extension filter.
      #expect(panel.allowedContentTypes[0].conforms(to: UTType.data))
    } else {
      #expect(panel.allowedFileTypes == [unknownExtension])
    }
  }

  @Test func openWithFilterLegacy() async throws {
    let panelController = TestPanelController()
    let plugin = FileSelectorPlugin(
      viewProvider: TestViewProvider(),
      panelController: panelController)
    plugin.forceLegacyTypes = true

    let returnPath = "/foo/bar"
    panelController.openURLs = [URL(fileURLWithPath: returnPath)]

    await confirmation("completion") { called in
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
          #expect(paths == [returnPath])
        case .failure(let error):
          Issue.record("\(error)")
        }
        called()
      }
    }

    let panel = try #require(panelController.openPanel)
    // On the legacy path, the allowedFileTypes should be set directly.
    #expect(panel.allowedFileTypes == ["txt", "json", "public.text", "public.image"])

    // They should also be translated to corresponding allowed content types.
    if #available(macOS 11.0, *) {
      #expect(panel.allowedContentTypes.contains(UTType.plainText))
      #expect(panel.allowedContentTypes.contains(UTType.json))
      #expect(panel.allowedContentTypes.contains(UTType.image))
      // MIME type is not supported for the legacy codepath.
      #expect(!panel.allowedContentTypes.contains(UTType.html))
    }
  }

  @Test func openCancel() async throws {
    let panelController = TestPanelController()
    let plugin = FileSelectorPlugin(
      viewProvider: TestViewProvider(),
      panelController: panelController)

    await confirmation("completion") { called in
      let options = OpenPanelOptions(
        allowsMultipleSelection: false,
        canChooseDirectories: false,
        canChooseFiles: true,
        baseOptions: SavePanelOptions())
      plugin.displayOpenPanel(options: options) { result in
        switch result {
        case .success(let paths):
          #expect(paths.count == 0)
        case .failure(let error):
          Issue.record("\(error)")
        }
        called()
      }
    }

    _ = try #require(panelController.openPanel)
  }

  @Test func saveSimple() async throws {
    let panelController = TestPanelController()
    let plugin = FileSelectorPlugin(
      viewProvider: TestViewProvider(),
      panelController: panelController)

    let returnPath = "/foo/bar"
    panelController.saveURL = URL(fileURLWithPath: returnPath)

    await confirmation("completion") { called in
      let options = SavePanelOptions()
      plugin.displaySavePanel(options: options) { result in
        switch result {
        case .success(let path):
          #expect(path == returnPath)
        case .failure(let error):
          Issue.record("\(error)")
        }
        called()
      }
    }

    let panel = try #require(panelController.savePanel)
    // By default, "New Folder" button is visible for Save dialogs
    #expect(panel.canCreateDirectories)
  }

  @Test func saveWithArguments() async throws {
    let panelController = TestPanelController()
    let plugin = FileSelectorPlugin(
      viewProvider: TestViewProvider(),
      panelController: panelController)

    let returnPath = "/foo/bar"
    panelController.saveURL = URL(fileURLWithPath: returnPath)

    await confirmation("completion") { called in
      let options = SavePanelOptions(
        directoryPath: "/some/dir",
        nameFieldStringValue: "a name",
        prompt: "Save it!")
      plugin.displaySavePanel(options: options) { result in
        switch result {
        case .success(let path):
          #expect(path == returnPath)
        case .failure(let error):
          Issue.record("\(error)")
        }
        called()
      }
    }

    let panel = try #require(panelController.savePanel)
    #expect(panel.directoryURL?.path == "/some/dir")
    #expect(panel.nameFieldStringValue == "a name")
    #expect(panel.prompt == "Save it!")
  }

  @Test func saveNewFolderHidden() async throws {
    let panelController = TestPanelController()
    let plugin = FileSelectorPlugin(
      viewProvider: TestViewProvider(),
      panelController: panelController)

    let returnPath = "/foo/bar"
    panelController.saveURL = URL(fileURLWithPath: returnPath)

    await confirmation("completion") { called in
      let options = SavePanelOptions(canCreateDirectories: false)
      plugin.displaySavePanel(options: options) { result in
        switch result {
        case .success(let path):
          #expect(path == returnPath)
        case .failure(let error):
          Issue.record("\(error)")
        }
        called()
      }
    }

    let panel = try #require(panelController.savePanel)
    #expect(!panel.canCreateDirectories)
  }

  @Test func saveCancel() async throws {
    let panelController = TestPanelController()
    let plugin = FileSelectorPlugin(
      viewProvider: TestViewProvider(),
      panelController: panelController)

    await confirmation("completion") { called in
      let options = SavePanelOptions()
      plugin.displaySavePanel(options: options) { result in
        switch result {
        case .success(let path):
          #expect(path == nil)
        case .failure(let error):
          Issue.record("\(error)")
        }
        called()
      }
    }

    _ = try #require(panelController.savePanel)
  }

  @Test func getDirectorySimple() async throws {
    let panelController = TestPanelController()
    let plugin = FileSelectorPlugin(
      viewProvider: TestViewProvider(),
      panelController: panelController)

    let returnPath = "/foo/bar"
    panelController.openURLs = [URL(fileURLWithPath: returnPath)]

    await confirmation("completion") { called in
      let options = OpenPanelOptions(
        allowsMultipleSelection: false,
        canChooseDirectories: true,
        canChooseFiles: false,
        baseOptions: SavePanelOptions())
      plugin.displayOpenPanel(options: options) { result in
        switch result {
        case .success(let paths):
          #expect(paths == [returnPath])
        case .failure(let error):
          Issue.record("\(error)")
        }
        called()
      }
    }

    let panel = try #require(panelController.openPanel)
    #expect(panel.canChooseDirectories)
    // For consistency across platforms, file selection is disabled.
    #expect(!panel.canChooseFiles)
    // The Dart API only allows a single directory to be returned, so users shouldn't be allowed
    // to select multiple.
    #expect(!panel.allowsMultipleSelection)
    // By default, "New Folder" button is hidden for Choose Directory dialogs.
    #expect(!panel.canCreateDirectories)
  }

  @Test func getDirectoryCancel() async throws {
    let panelController = TestPanelController()
    let plugin = FileSelectorPlugin(
      viewProvider: TestViewProvider(),
      panelController: panelController)

    await confirmation("completion") { called in
      let options = OpenPanelOptions(
        allowsMultipleSelection: false,
        canChooseDirectories: true,
        canChooseFiles: false,
        baseOptions: SavePanelOptions())
      plugin.displayOpenPanel(options: options) { result in
        switch result {
        case .success(let paths):
          #expect(paths.count == 0)
        case .failure(let error):
          Issue.record("\(error)")
        }
        called()
      }
    }

    _ = try #require(panelController.openPanel)
  }

  @Test func getDirectoriesMultiple() async throws {
    let panelController = TestPanelController()
    let plugin = FileSelectorPlugin(
      viewProvider: TestViewProvider(),
      panelController: panelController)

    let returnPaths = ["/foo/bar", "/foo/test"]
    panelController.openURLs = returnPaths.map({ path in URL(fileURLWithPath: path) })

    await confirmation("completion") { called in
      let options = OpenPanelOptions(
        allowsMultipleSelection: true,
        canChooseDirectories: true,
        canChooseFiles: false,
        baseOptions: SavePanelOptions())
      plugin.displayOpenPanel(options: options) { result in
        switch result {
        case .success(let paths):
          #expect(paths == returnPaths)
        case .failure(let error):
          Issue.record("\(error)")
        }
        called()
      }
    }

    let panel = try #require(panelController.openPanel)
    #expect(panel.canChooseDirectories)
    // For consistency across platforms, file selection is disabled.
    #expect(!panel.canChooseFiles)
    #expect(panel.allowsMultipleSelection)
    // By default, "New Folder" button is hidden for Choose Directory dialogs.
    #expect(!panel.canCreateDirectories)
  }

  @Test func getDirectoryMultipleCancel() async throws {
    let panelController = TestPanelController()
    let plugin = FileSelectorPlugin(
      viewProvider: TestViewProvider(),
      panelController: panelController)

    await confirmation("completion") { called in
      let options = OpenPanelOptions(
        allowsMultipleSelection: true,
        canChooseDirectories: true,
        canChooseFiles: false,
        baseOptions: SavePanelOptions())
      plugin.displayOpenPanel(options: options) { result in
        switch result {
        case .success(let paths):
          #expect(paths.count == 0)
        case .failure(let error):
          Issue.record("\(error)")
        }
        called()
      }
    }

    _ = try #require(panelController.openPanel)
  }

  @Test func getDirectoryNewFolderVisible() async throws {
    let panelController = TestPanelController()
    let plugin = FileSelectorPlugin(
      viewProvider: TestViewProvider(),
      panelController: panelController)

    let returnPath = "/foo/bar"
    panelController.openURLs = [URL(fileURLWithPath: returnPath)]

    await confirmation("completion") { called in
      let options = OpenPanelOptions(
        allowsMultipleSelection: false,
        canChooseDirectories: true,
        canChooseFiles: false,
        baseOptions: SavePanelOptions(canCreateDirectories: true))

      plugin.displayOpenPanel(options: options) { result in
        switch result {
        case .success(let paths):
          #expect(paths == [returnPath])
        case .failure(let error):
          Issue.record("\(error)")
        }
        called()
      }
    }

    let panel = try #require(panelController.openPanel)
    #expect(panel.canCreateDirectories)
  }
}
