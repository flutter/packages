// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// The maximum number of nested reference expansions allowed in an SVG to prevent DoS exploits.
const int kMaxReferenceExpansions = 1000;

/// The error message thrown when the nested reference expansions limit is exceeded.
const String kMaxReferenceExpansionsErrorMessage =
    'SVG contains too many nested reference expansions (possible Denial of Service exploit).';
