// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// shared_preferences_android is implemented using JNI, which requires FFI;
// export a stub for platforms that don't support FFI (e.g., web) so that
// multi-platform apps importing this library for its options still compile.
export 'src/shared_preferences_android_stub.dart'
    if (dart.library.ffi) 'src/shared_preferences_android_real.dart';
