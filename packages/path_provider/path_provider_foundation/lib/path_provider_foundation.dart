// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// path_provider_foundation is implemented using FFI; export a stub for
// platforms that don't support FFI (e.g., web) to avoid having transitive
// dependencies break web compilation.
export 'src/path_provider_foundation_stub.dart'
    if (dart.library.ffi) 'src/path_provider_foundation_real.dart';
