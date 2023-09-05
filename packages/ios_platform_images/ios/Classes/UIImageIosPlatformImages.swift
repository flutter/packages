// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import Foundation
import UIKit

extension UIImage {
  static func flutterImage(withName name: String) -> UIImage? {
    let components = name.components(separatedBy: "/")
    guard let filename = components.last else {
      return nil
    }
    let path = components.dropLast().joined(separator: "/")

    for screenScale in stride(from: UIScreen.main.scale, to: 1, by: -1) {
      let key = FlutterDartProject.lookupKey(forAsset: "\(path)/\(screenScale)0x/\(filename)")
      if let image = UIImage(named: key, in: Bundle.main, compatibleWith: nil) {
        return image
      }
    }

    let key = FlutterDartProject.lookupKey(forAsset: name)
    return UIImage(named: key, in: Bundle.main, compatibleWith: nil)
  }
}
