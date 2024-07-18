// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'dart:js_interop';

import 'package:web/web.dart';

/// Adds missing fields to [MediaTrackSupportedConstraints].
extension NonStandardFieldsOnMediaTrackSupportedConstraints
    on MediaTrackSupportedConstraints {
  @JS('zoom')
  external bool? get zoomNullable;

  @JS('torch')
  external bool? get torchNullable;
}

/// Adds missing fields to [MediaTrackCapabilities].

extension NonStandardFieldsOnMediaTrackCapabilities on MediaTrackCapabilities {
  @JS('zoom')
  external MediaSettingsRange? get zoomNullable;

  @JS('torch')
  external JSArray<JSBoolean>? get torchNullable;
}

/// Adds missing fields to [MediaTrackSettings]
extension NonStandardFieldsOnMediaTrackSettings on MediaTrackSettings {
  @JS('facingMode')
  external String? get facingModeNullable;
}
