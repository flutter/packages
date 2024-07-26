// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include <flutter_linux/flutter_linux.h>

#include "include/file_selector_linux/file_selector_plugin.h"
#include "messages.g.h"

// Shows a GTK file chooser with the given type and options.
//
// This is the implementation of the showFileChooser Pigeon API method.
FfsFileSelectorApiShowFileChooserResponse* handle_show_file_chooser(
    FfsPlatformFileChooserActionType type,
    FfsPlatformFileChooserOptions* options, gpointer user_data);
