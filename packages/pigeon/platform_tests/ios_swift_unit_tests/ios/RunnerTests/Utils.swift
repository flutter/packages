// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation

func equals(_ x: Any?, _ y: Any?) -> Bool {
  if x == nil, y == nil {
    return true
  }
  
  guard let x = x as? AnyHashable, let y = y as? AnyHashable else {
    return false
  }
  return x == y
}

func equalsList(_ x: [Any?]?, _ y: [Any?]?) -> Bool {
  if x == nil, y == nil {
    return true
  }
  
  guard x?.count == y?.count else { return false }
  guard let x = x, let y = y else { return false }
  
  return (0..<x.count).allSatisfy { equals(x[$0], y[$0]) }
}

func equalsDictionary(_ x: [AnyHashable: Any?]?, _ y: [AnyHashable: Any?]?) -> Bool {
  if x == nil, y == nil {
    return true
  }
  
  guard x?.count == y?.count else { return false }
  guard let x = x, let y = y else { return false }
  
  return x.allSatisfy { equals($0.value, y[$0.key] as Any?) }
}
