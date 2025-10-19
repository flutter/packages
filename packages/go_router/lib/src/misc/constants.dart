// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:meta/meta.dart';

/// Symbol used as a Zone key to track the current GoRouter during redirects.
@internal
const Symbol currentRouterKey = #goRouterRedirectContext;
