// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
#include "include/windows_unit_tests/windows_unit_tests_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "windows_unit_tests_plugin.h"

void WindowsUnitTestsPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  windows_unit_tests::WindowsUnitTestsPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
