// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
#ifndef FLUTTER_PLUGIN_WINDOWS_UNIT_TESTS_PLUGIN_H_
#define FLUTTER_PLUGIN_WINDOWS_UNIT_TESTS_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace windows_unit_tests {

class WindowsUnitTestsPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  WindowsUnitTestsPlugin();

  virtual ~WindowsUnitTestsPlugin();

  // Disallow copy and assign.
  WindowsUnitTestsPlugin(const WindowsUnitTestsPlugin &) = delete;
  WindowsUnitTestsPlugin &operator=(const WindowsUnitTestsPlugin &) = delete;

  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace windows_unit_tests

#endif  // FLUTTER_PLUGIN_WINDOWS_UNIT_TESTS_PLUGIN_H_
