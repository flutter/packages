// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#if os(iOS)
import Flutter
#elseif os(macOS)
import FlutterMacOS
#endif
import LocalAuthentication

protocol AuthContextFactory: AnyObject {
    func createAuthContext() -> LAContext
}
