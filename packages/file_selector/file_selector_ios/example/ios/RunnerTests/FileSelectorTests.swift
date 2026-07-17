// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import Testing

@testable import file_selector_ios

final class TestViewPresenter: ViewPresenter {
  public var presentedController: UIViewController?

  func present(
    _ viewControllerToPresent: UIViewController, animated: Bool, completion: (() -> Void)? = nil
  ) {
    presentedController = viewControllerToPresent
  }
}

final class StubViewPresenterProvider: ViewPresenterProvider {
  var viewPresenter: ViewPresenter?

  init(viewPresenter: ViewPresenter?) {
    self.viewPresenter = viewPresenter
  }
}

@Suite @MainActor struct FileSelectorTests {
  @Test func pickerPresents() throws {
    let presenter = TestViewPresenter()
    let plugin = FileSelectorPlugin(
      viewPresenterProvider: StubViewPresenterProvider(viewPresenter: presenter))
    let picker = UIDocumentPickerViewController(documentTypes: [], in: UIDocumentPickerMode.import)
    plugin.documentPickerViewControllerOverride = picker

    plugin.openFile(
      config: FileSelectorConfig(utis: [], allowMultiSelection: false)
    ) { _ in }

    #expect(plugin.pendingCompletions.count == 1)
    #expect(picker.delegate === plugin.pendingCompletions.first)
    #expect(presenter.presentedController === picker)
  }

  @Test func returnsPickedFiles() async throws {
    let plugin = FileSelectorPlugin(
      viewPresenterProvider: StubViewPresenterProvider(viewPresenter: TestViewPresenter()))
    let picker = UIDocumentPickerViewController(documentTypes: [], in: UIDocumentPickerMode.import)
    plugin.documentPickerViewControllerOverride = picker

    await confirmation("completion") { completionWasCalled in
      plugin.openFile(
        config: FileSelectorConfig(utis: [], allowMultiSelection: false)
      ) { result in
        switch result {
        case .success(let paths):
          #expect(paths == ["/file1.txt", "/file2.txt"])
        case .failure(let error):
          Issue.record("\(error)")
        }
        completionWasCalled()
      }
      plugin.pendingCompletions.first!.documentPicker(
        picker,
        didPickDocumentsAt: [URL(string: "file:///file1.txt")!, URL(string: "file:///file2.txt")!])
    }
    #expect(plugin.pendingCompletions.isEmpty)
  }

  @Test func cancellingPickerReturnsEmptyList() async throws {
    let plugin = FileSelectorPlugin(
      viewPresenterProvider: StubViewPresenterProvider(viewPresenter: TestViewPresenter()))
    let picker = UIDocumentPickerViewController(documentTypes: [], in: UIDocumentPickerMode.import)
    plugin.documentPickerViewControllerOverride = picker

    await confirmation("completion") { completionWasCalled in
      plugin.openFile(
        config: FileSelectorConfig(utis: [], allowMultiSelection: false)
      ) { result in
        switch result {
        case .success(let paths):
          #expect(paths.count == 0)
        case .failure(let error):
          Issue.record("\(error)")
        }
        completionWasCalled()
      }
      plugin.pendingCompletions.first!.documentPickerWasCancelled(picker)
    }
    #expect(plugin.pendingCompletions.isEmpty)
  }
}
