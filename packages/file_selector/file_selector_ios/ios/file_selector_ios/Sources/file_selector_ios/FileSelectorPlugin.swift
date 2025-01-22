// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import ObjectiveC
import UIKit

/// Bridge between a UIDocumentPickerViewController and its Pigeon callback.
class PickerCompletionBridge: NSObject, UIDocumentPickerDelegate {
  let completion: (Result<[String], Error>) -> Void
  /// The plugin instance that owns this object, to ensure that it lives as long as the picker it
  /// serves as a delegate for. Instances are responsible for removing themselves from their owner
  /// on completion.
  let owner: FileSelectorPlugin

  init(completion: @escaping (Result<[String], Error>) -> Void, owner: FileSelectorPlugin) {
    self.completion = completion
    self.owner = owner
  }

  func documentPicker(
    _ controller: UIDocumentPickerViewController,
    didPickDocumentsAt urls: [URL]
  ) {
    sendResult(urls.map({ $0.path }))
  }

  func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
    sendResult([])
  }

  private func sendResult(_ result: [String]) {
    completion(.success(result))
    owner.pendingCompletions.remove(self)
  }
}

public class FileSelectorPlugin: NSObject, FlutterPlugin, FileSelectorApi {
  /// Owning references to pending completion callbacks.
  ///
  /// This is necessary since the objects need to live until a UIDocumentPickerDelegate method is
  /// called on the delegate, but the delegate is weak. Objects in this set are responsible for
  /// removing themselves from it.
  var pendingCompletions: Set<PickerCompletionBridge> = []
  /// Overridden document picker, for testing.
  var documentPickerViewControllerOverride: UIDocumentPickerViewController?
  /// Overridden view presenter, for testing.
  var viewPresenterOverride: ViewPresenter?

  public static func register(with registrar: FlutterPluginRegistrar) {
    let instance = FileSelectorPlugin()
    FileSelectorApiSetup.setUp(binaryMessenger: registrar.messenger(), api: instance)
  }

  func openFile(config: FileSelectorConfig, completion: @escaping (Result<[String], Error>) -> Void)
  {
    let completionBridge = PickerCompletionBridge(completion: completion, owner: self)
    let documentPicker =
      documentPickerViewControllerOverride
      ?? UIDocumentPickerViewController(
        documentTypes: config.utis,
        in: .import)
    documentPicker.allowsMultipleSelection = config.allowMultiSelection
    documentPicker.delegate = completionBridge

    let presenter =
      self.viewPresenterOverride ?? UIApplication.shared.delegate?.window??.rootViewController
    if let presenter = presenter {
      pendingCompletions.insert(completionBridge)
      presenter.present(documentPicker, animated: true, completion: nil)
    } else {
      completion(
        .failure(PigeonError(code: "error", message: "Missing root view controller.", details: nil))
      )
    }
  }

}
