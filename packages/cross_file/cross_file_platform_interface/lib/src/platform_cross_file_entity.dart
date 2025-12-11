// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.



abstract interface class PlatformCrossFileEntity {
  /// Whether the resource represented by this reference exists.
  Future<bool> exists();
}
