// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#if os(macOS)
protocol Alert {
    func addButton(withTitle title: String) -> NSButton
    func beginSheetModal(for sheetWindow: NSWindow, completionHandler: @escaping (NSApplication.ModalResponse) -> Void)
}
#elseif os(iOS)
protocol AlertController {
    func addAction(_ action: UIAlertAction)
    func present(_ presentingViewController: UIViewController, animated: Bool, completion: (() -> Void)?)
}
#endif


#if os(macOS)
extension NSAlert: Alert {}
#elseif os(iOS)
extension UIAlertController: AlertController {}
#endif


protocol AlertFactory {
    #if os(macOS)
        func createAlert() -> Alert
    #elseif os(iOS)
        func createAlertController(
            title: String?, message: String?, preferredStyle: UIAlertController.Style
        ) -> AlertController
    #endif

}

#if os(macOS)
class DefaultAlertFactory: NSObject, AlertFactory {
    func createAlert() -> Alert {
        return NSAlert()
    }
}
#elseif os(iOS)
class DefaultAlertFactory: NSObject, AlertFactory {
    func createAlertController(
        title: String?, message: String?, preferredStyle: UIAlertController.Style
    ) -> AlertController {
        return UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
    }
}
#endif
