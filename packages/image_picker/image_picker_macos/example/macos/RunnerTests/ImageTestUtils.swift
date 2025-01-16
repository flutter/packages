// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import AppKit

func createTestImage(size: NSSize) -> NSImage {
  let image = NSImage(size: size)
  image.lockFocus()
  NSColor.white.set()
  NSBezierPath(rect: NSRect(origin: .zero, size: size)).fill()
  image.unlockFocus()
  return image
}
