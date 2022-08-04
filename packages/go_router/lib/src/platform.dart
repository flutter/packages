// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// TODO(johnpryan): Remove this API
export 'platform/path_strategy_nonweb.dart'
    if (dart.library.html) 'platform/path_strategy_web.dart';
export 'platform/url_path_strategy.dart';
