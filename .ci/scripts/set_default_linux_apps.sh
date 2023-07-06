#!/bin/bash
# Copyright 2013 The Flutter Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.
set -e

xdg-mime default google-chrome.desktop inode/directory
xdg-settings set default-web-browser google-chrome.desktop
