// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// Metadata shared by the preview route and application navigation logic.
const Map<String, Object?> previewMetadata = <String, Object?>{
  'requiresAuth': false,
  'title': 'Preview',
  'codes': <int>[],
  'options': <String, bool>{},
  'nullableLists': <List<int>?>[
    null,
    <int>[1],
  ],
};
