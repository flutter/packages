// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// Common methods for interacting with a security-scoped URL.
mixin SecurityScopedResource {
  /// In an app that has adopted App Sandbox, makes the resource pointed to by a
  /// security-scoped URL available to the app.
  Future<bool> startAccessingSecurityScopedResource();

  /// In an app that adopts App Sandbox, revokes access to the resource pointed
  /// to by a security-scoped URL.
  Future<void> stopAccessingSecurityScopedResource();
}
