// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "test_plugin.h"

// This must be included before many other Windows headers.
#include <flutter/plugin_registrar_windows.h>
#include <windows.h>

#include <memory>
#include <optional>
#include <string>

#include "pigeon/core_tests.gen.h"

namespace test_plugin {

using core_tests_pigeontest::AllNullableTypes;
using core_tests_pigeontest::AllNullableTypesWrapper;
using core_tests_pigeontest::AllTypes;
using core_tests_pigeontest::ErrorOr;
using core_tests_pigeontest::FlutterError;
using core_tests_pigeontest::FlutterIntegrationCoreApi;
using core_tests_pigeontest::HostIntegrationCoreApi;

// static
void TestPlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows* registrar) {
  auto plugin = std::make_unique<TestPlugin>(registrar->messenger());

  HostIntegrationCoreApi::SetUp(registrar->messenger(), plugin.get());

  registrar->AddPlugin(std::move(plugin));
}

TestPlugin::TestPlugin(flutter::BinaryMessenger* binary_messenger)
    : flutter_api_(
          std::make_unique<FlutterIntegrationCoreApi>(binary_messenger)) {}

TestPlugin::~TestPlugin() {}

std::optional<FlutterError> TestPlugin::Noop() { return std::nullopt; }

ErrorOr<AllTypes> TestPlugin::EchoAllTypes(const AllTypes& everything) {
  return everything;
}

ErrorOr<std::optional<AllNullableTypes>> TestPlugin::EchoAllNullableTypes(
    const AllNullableTypes* everything) {
  if (!everything) {
    return std::nullopt;
  }
  return *everything;
}

std::optional<FlutterError> TestPlugin::ThrowError() {
  return FlutterError("An error");
}

ErrorOr<int64_t> TestPlugin::EchoInt(int64_t an_int) { return an_int; }

ErrorOr<double> TestPlugin::EchoDouble(double a_double) { return a_double; }

ErrorOr<bool> TestPlugin::EchoBool(bool a_bool) { return a_bool; }

ErrorOr<std::string> TestPlugin::EchoString(const std::string& a_string) {
  return a_string;
}

ErrorOr<std::vector<uint8_t>> TestPlugin::EchoUint8List(
    const std::vector<uint8_t>& a_uint8_list) {
  return a_uint8_list;
}

ErrorOr<std::optional<std::string>> TestPlugin::ExtractNestedNullableString(
    const AllNullableTypesWrapper& wrapper) {
  const std::string* inner_string = wrapper.values().a_nullable_string();
  return inner_string ? std::optional<std::string>(*inner_string)
                      : std::nullopt;
}

ErrorOr<AllNullableTypesWrapper> TestPlugin::CreateNestedNullableString(
    const std::string* nullable_string) {
  AllNullableTypes inner_object;
  // The string pointer can't be passed through directly since the setter for
  // a string takes a std::string_view rather than std::string so the pointer
  // types don't match.
  if (nullable_string) {
    inner_object.set_a_nullable_string(*nullable_string);
  } else {
    inner_object.set_a_nullable_string(nullptr);
  }
  AllNullableTypesWrapper wrapper;
  wrapper.set_values(inner_object);
  return wrapper;
}

ErrorOr<AllNullableTypes> TestPlugin::SendMultipleNullableTypes(
    const bool* a_nullable_bool, const int64_t* a_nullable_int,
    const std::string* a_nullable_string) {
  AllNullableTypes someTypes;
  someTypes.set_a_nullable_bool(a_nullable_bool);
  someTypes.set_a_nullable_int(a_nullable_int);
  // The string pointer can't be passed through directly since the setter for
  // a string takes a std::string_view rather than std::string so the pointer
  // types don't match.
  if (a_nullable_string) {
    someTypes.set_a_nullable_string(*a_nullable_string);
  } else {
    someTypes.set_a_nullable_string(nullptr);
  }
  return someTypes;
};

ErrorOr<std::optional<int64_t>> TestPlugin::EchoNullableInt(
    const int64_t* a_nullable_int) {
  if (!a_nullable_int) {
    return std::nullopt;
  }
  return *a_nullable_int;
};

ErrorOr<std::optional<double>> TestPlugin::EchoNullableDouble(
    const double* a_nullable_double) {
  if (!a_nullable_double) {
    return std::nullopt;
  }
  return *a_nullable_double;
};

ErrorOr<std::optional<bool>> TestPlugin::EchoNullableBool(
    const bool* a_nullable_bool) {
  if (!a_nullable_bool) {
    return std::nullopt;
  }
  return *a_nullable_bool;
};

ErrorOr<std::optional<std::string>> TestPlugin::EchoNullableString(
    const std::string* a_nullable_string) {
  if (!a_nullable_string) {
    return std::nullopt;
  }
  return *a_nullable_string;
};

ErrorOr<std::optional<std::vector<uint8_t>>> TestPlugin::EchoNullableUint8List(
    const std::vector<uint8_t>* a_nullable_uint8_list) {
  if (!a_nullable_uint8_list) {
    return std::nullopt;
  }
  return *a_nullable_uint8_list;
};

void TestPlugin::NoopAsync(
    std::function<void(std::optional<FlutterError> reply)> result) {
  result(std::nullopt);
}

void TestPlugin::EchoAsyncString(
    const std::string& a_string,
    std::function<void(ErrorOr<std::string> reply)> result) {
  result(a_string);
}

void TestPlugin::CallFlutterNoop(
    std::function<void(std::optional<FlutterError> reply)> result) {
  flutter_api_->noop([result]() { result(std::nullopt); });
}

void TestPlugin::CallFlutterEchoString(
    const std::string& a_string,
    std::function<void(ErrorOr<std::string> reply)> result) {
  flutter_api_->echoString(
      a_string,
      [result](const std::string& flutter_string) { result(flutter_string); });
}

}  // namespace test_plugin
