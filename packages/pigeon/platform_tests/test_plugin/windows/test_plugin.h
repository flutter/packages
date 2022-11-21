// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#ifndef FLUTTER_PLUGIN_TEST_PLUGIN_H_
#define FLUTTER_PLUGIN_TEST_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace test_plugin {

class TestPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows* registrar);

  TestPlugin();

  virtual ~TestPlugin();

  // Disallow copy and assign.
  TestPlugin(const TestPlugin&) = delete;
  TestPlugin& operator=(const TestPlugin&) = delete;
};

}  // namespace test_plugin

#endif  // FLUTTER_PLUGIN_TEST_PLUGIN_H_
