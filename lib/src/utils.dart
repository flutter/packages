// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:meta/meta.dart';

/// Recursively merges [attributes] [into] another map of attributes.
///
/// [attributes] take precedence over the target map. Recursion takes place
/// along [Map] values only. All other types are overwritten entirely.
void mergeAttributes(Map<String, dynamic> attributes,
    {@required Map<String, dynamic> into}) {
  assert(attributes != null && into != null);
  attributes.forEach((String name, dynamic value) {
    dynamic targetValue = into[name];
    if (value is Map && targetValue is Map) {
      mergeAttributes(value, into: targetValue);
    } else {
      into[name] = value;
    }
  });
}
