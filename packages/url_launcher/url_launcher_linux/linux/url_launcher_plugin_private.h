// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include <flutter_linux/flutter_linux.h>

#include "include/url_launcher_linux/url_launcher_plugin.h"
#include "messages.g.h"

// Called to check if a URL can be launched.
FulUrlLauncherApiCanLaunchUrlResponse* handle_can_launch_url(
    const gchar* url, gpointer user_data);
