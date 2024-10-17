// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include <flutter_linux/flutter_linux.h>

#include "include/file_selector_linux/file_selector_plugin.h"
#include "messages.g.h"

// Creates a GtkFileChooserNative for the given method call.
//
// TODO(stuartmorgan): Make this private/static once the tests are restructured
// as descibed in the file_selector_plugin_test.cc TODOs, and then test through
// the Pigeon API handler instead (making that non-static). This only exists to
// move as much logic as possible behind an entry point currently callable by
// unit tests.
GtkFileChooserNative* create_dialog_of_type(
    GtkWindow* window, FfsPlatformFileChooserActionType type,
    FfsPlatformFileChooserOptions* options);
