// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import Foundation
import UIKit

extension UIImage {
  static func flutterImage(withName name: String) -> UIImage? {
    let imageName = (name as NSString).lastPathComponent
    let path = (name as NSString).deletingLastPathComponent
    let screenScale = UIScreen.main.scale

    var scaledImage: UIImage?

    // Search for a scaled image in the bundle
    // The image name may be suffixed with a scale factor, e.g. @2x
    // If a scaled image is not found, search for standard image

    for scale in stride(from: Int(screenScale), through: 1, by: -1) {
      let scaledName = imageName.replacingOccurrences(of: ".", with: "@\(scale)x.")
      let scaledPath = "\(path)/\(scaledName)"
      if let image = UIImage(named: scaledPath, in: Bundle.main, compatibleWith: nil) {
        scaledImage = image
        break  // Exit the loop if a scaled image is found
      }
    }

    // If a scaled image is not found return the standard image if it exists
    return scaledImage ?? UIImage(named: imageName, in: Bundle.main, compatibleWith: nil)
  }
}
