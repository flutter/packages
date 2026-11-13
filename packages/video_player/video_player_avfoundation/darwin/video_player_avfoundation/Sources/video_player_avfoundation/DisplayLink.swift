// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation

// A display link abstraction that supports both Core Animation-based
// display links (for iOS and recent macOS versions) and Core Video-based
// display links (for older macOS versions).
protocol DisplayLink: AnyObject {

  /// Whether the display link is currently running (i.e., firing events).
  ///
  /// Defaults to false.
  var running: Bool { get set }

  /// The time interval between screen refresh updates.
  var duration: CFTimeInterval { get }

}
