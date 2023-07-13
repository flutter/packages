#!/bin/bash
# Copyright 2013 The Flutter Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.
set -e

# Set up a .desktop file pointing to the CIPD-installed Chrome.
LOCAL_DESKTOP_FILE_DIR=~/.local/share/applications
mkdir -p "$LOCAL_DESKTOP_FILE_DIR"
CIPD_CHROME_DESKTOP_FILE=${LOCAL_DESKTOP_FILE_DIR}/cipd-chrome.desktop
cat << EOF > "$CIPD_CHROME_DESKTOP_FILE"
[Desktop Entry]
Version=1.0
Name=Google Chrome
GenericName=Web Browser
Comment=Access the Internet
Exec=$CHROME_EXECUTABLE %U
StartupNotify=true
Terminal=false
Icon=google-chrome
Type=Application
Categories=Network;WebBrowser;
MimeType=application/pdf;application/rdf+xml;application/rss+xml;application/xhtml+xml;application/xhtml_xml;application/xml;image/gif;image/jpeg;image/png;image/webp;text/html;text/xml;x-scheme-handler/http;x-scheme-handler/https;x-scheme-handler/file;
EOF

# Enable xdg-* commands to work correctly.
export DESKTOP_SESSION=gnome

# Set Chrome as the default handler for http, https, and file, for url_launcher
# tests that expect handlers for those schemes.
xdg-mime default google-chrome.desktop inode/directory
xdg-settings set default-web-browser google-chrome.desktop
