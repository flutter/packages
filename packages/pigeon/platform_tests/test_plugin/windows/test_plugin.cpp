// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "test_plugin.h"

// This must be included before many other Windows headers.
#include <flutter/plugin_registrar_windows.h>
#include <windows.h>

#include <memory>

#include "pigeon/core_tests.gen.h"

namespace test_plugin {

using core_tests::AllTypes;
using core_tests::ErrorOr;
using core_tests::FlutterError;
using core_tests::HostIntegrationCoreApi;

// static
void TestPlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows* registrar) {
  auto plugin = std::make_unique<TestPlugin>();

  HostIntegrationCoreApi::SetUp(registrar->messenger(), plugin.get());

  registrar->AddPlugin(std::move(plugin));
}

TestPlugin::TestPlugin() {}

TestPlugin::~TestPlugin() {}

std::optional<FlutterError> TestPlugin::Noop() {}

ErrorOr<AllTypes> TestPlugin::EchoAllTypes(const AllTypes& everything) {
  return everything;
}

}  // namespace test_plugin
