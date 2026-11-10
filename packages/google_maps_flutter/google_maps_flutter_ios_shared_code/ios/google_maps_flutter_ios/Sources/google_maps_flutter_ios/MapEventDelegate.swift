// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#if canImport(google_maps_flutter_ios_objc)
  import google_maps_flutter_ios_objc
#endif

/// Delegate for map callbacks that need Dart handling.
///
/// This exists to add AnyObject to the requirements, so that references to it can be weak.
protocol MapEventDelegate: AnyObject, MapsCallbackApiProtocol {}
