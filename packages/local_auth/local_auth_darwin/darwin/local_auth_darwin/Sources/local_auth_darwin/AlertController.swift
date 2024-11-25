// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// Protocol for the AlertController API.
///
/// This protocol exists to allow injecting an alternate implementation for testing.
protocol AlertController {
  func showAlert(
    message: String, dismissTitle: String, openSettingsTitle: String?,
    completion: @escaping (Bool) -> Void
  )
}

/// Default implementation of AlertController for iOS and macOS.
#if os(iOS)
  import UIKit

  class DefaultAlertController: AlertController {
    func showAlert(
      message: String, dismissTitle: String, openSettingsTitle: String?,
      completion: @escaping (Bool) -> Void
    ) {
      let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
      let dismissAction = UIAlertAction(title: dismissTitle, style: .default) { _ in
        completion(false)
      }
      alert.addAction(dismissAction)

      if let openSettingsTitle = openSettingsTitle {
        let openSettingsAction = UIAlertAction(title: openSettingsTitle, style: .default) { _ in
          if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
          }
          completion(true)
        }
        alert.addAction(openSettingsAction)
      }

      UIApplication.shared.delegate?.window??.rootViewController?.present(alert, animated: true)
    }
  }

#elseif os(macOS)
  import AppKit

  class DefaultAlertController: AlertController {
    func showAlert(
      message: String, dismissTitle: String, openSettingsTitle: String?,
      completion: @escaping (Bool) -> Void
    ) {
      let alert = NSAlert()
      alert.messageText = message
      alert.addButton(withTitle: dismissTitle)

      if let openSettingsTitle = openSettingsTitle {
        alert.addButton(withTitle: openSettingsTitle)
      }

      alert.beginSheetModal(for: NSApplication.shared.keyWindow!) { response in
        if response == .alertSecondButtonReturn,
          let url = URL(
            string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Biometric"
          )
        {
          NSWorkspace.shared.open(url)
        }
        completion(response == .alertSecondButtonReturn)
      }
    }
  }
#endif
