#!/bin/bash
# Copyright 2013 The Flutter Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.
set -e

LOCAL_DESKTOP_FILE_DIR=~/.local/share/applications
mkdir -p "$LOCAL_DESKTOP_FILE_DIR"
CIPD_CHROME_DESKTOP_FILE=${LOCAL_DESKTOP_FILE_DIR}/cipd-chrome.desktop

#MimeType=application/pdf;application/rdf+xml;application/rss+xml;application/xhtml+xml;application/xhtml_xml;application/xml;image/gif;image/jpeg;image/png;image/webp;text/html;text/xml;x-scheme-handler/http;x-scheme-handler/https;
cat << EOF > "$CIPD_CHROME_DESKTOP_FILE"
[Desktop Entry]
Version=1.0
Name=Google Chrome
# Only KDE 4 seems to use GenericName, so we reuse the KDE strings.
# From Ubuntu's language-pack-kde-XX-base packages, version 9.04-20090413.
GenericName=Web Browser
# Not translated in KDE, from Epiphany 2.26.1-0ubuntu1.
# Gnome and KDE 3 uses Comment.
Comment=Access the Internet
Exec=$CHROME_EXECUTABLE %U
StartupNotify=true
Terminal=false
Icon=google-chrome
Type=Application
Categories=Network;WebBrowser;
MimeType=application/pdf;application/rdf+xml;application/rss+xml;application/xhtml+xml;application/xhtml_xml;application/xml;image/gif;image/jpeg;image/png;image/webp;text/html;text/xml;x-scheme-handler/http;x-scheme-handler/https;x-scheme-handler/file;
Actions=new-window;new-private-window;

[Desktop Action new-window]
Name=New Window
Exec=$CHROME_EXECUTABLE

[Desktop Action new-private-window]
Name=New Incognito Window
Exec=$CHROME_EXECUTABLE --incognito
EOF

export DESKTOP_SESSION=gnome
xdg-mime default cipd-chrome.desktop inode/directory
xdg-settings set default-web-browser cipd-chrome.desktop
