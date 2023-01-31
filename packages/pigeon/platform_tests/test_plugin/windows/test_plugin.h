// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#ifndef FLUTTER_PLUGIN_TEST_PLUGIN_H_
#define FLUTTER_PLUGIN_TEST_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>
#include <optional>
#include <string>

#include "pigeon/core_tests.gen.h"

namespace test_plugin {

// This plugin handles the native side of the integration tests in
// example/integration_test/
class TestPlugin : public flutter::Plugin,
                   public core_tests_pigeontest::HostIntegrationCoreApi {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows* registrar);

  TestPlugin(flutter::BinaryMessenger* binary_messenger);

  virtual ~TestPlugin();

  // Disallow copy and assign.
  TestPlugin(const TestPlugin&) = delete;
  TestPlugin& operator=(const TestPlugin&) = delete;

  // HostIntegrationCoreApi.
  std::optional<core_tests_pigeontest::FlutterError> Noop() override;
  core_tests_pigeontest::ErrorOr<core_tests_pigeontest::AllTypes> EchoAllTypes(
      const core_tests_pigeontest::AllTypes& everything) override;
  core_tests_pigeontest::ErrorOr<
      std::optional<core_tests_pigeontest::AllNullableTypes>>
  EchoAllNullableTypes(
      const core_tests_pigeontest::AllNullableTypes* everything) override;
  std::optional<core_tests_pigeontest::FlutterError> ThrowError() override;
  core_tests_pigeontest::ErrorOr<int64_t> EchoInt(int64_t an_int) override;
  core_tests_pigeontest::ErrorOr<double> EchoDouble(double a_double) override;
  core_tests_pigeontest::ErrorOr<bool> EchoBool(bool a_bool) override;
  core_tests_pigeontest::ErrorOr<std::string> EchoString(
      const std::string& a_string) override;
  core_tests_pigeontest::ErrorOr<std::vector<uint8_t>> EchoUint8List(
      const std::vector<uint8_t>& a_uint8_list) override;
  core_tests_pigeontest::ErrorOr<flutter::EncodableValue> EchoObject(
      const flutter::EncodableValue& an_object) override;
  core_tests_pigeontest::ErrorOr<std::optional<std::string>>
  ExtractNestedNullableString(
      const core_tests_pigeontest::AllNullableTypesWrapper& wrapper) override;
  core_tests_pigeontest::ErrorOr<core_tests_pigeontest::AllNullableTypesWrapper>
  CreateNestedNullableString(const std::string* nullable_string) override;
  core_tests_pigeontest::ErrorOr<core_tests_pigeontest::AllNullableTypes>
  SendMultipleNullableTypes(const bool* a_nullable_bool,
                            const int64_t* a_nullable_int,
                            const std::string* a_nullable_string) override;
  core_tests_pigeontest::ErrorOr<std::optional<int64_t>> EchoNullableInt(
      const int64_t* a_nullable_int) override;
  core_tests_pigeontest::ErrorOr<std::optional<double>> EchoNullableDouble(
      const double* a_nullable_double) override;
  core_tests_pigeontest::ErrorOr<std::optional<bool>> EchoNullableBool(
      const bool* a_nullable_bool) override;
  core_tests_pigeontest::ErrorOr<std::optional<std::string>> EchoNullableString(
      const std::string* a_nullable_string) override;
  core_tests_pigeontest::ErrorOr<std::optional<std::vector<uint8_t>>>
  EchoNullableUint8List(
      const std::vector<uint8_t>* a_nullable_uint8_list) override;
  core_tests_pigeontest::ErrorOr<std::optional<flutter::EncodableValue>>
  EchoNullableObject(const flutter::EncodableValue* a_nullable_object) override;
  void NoopAsync(std::function<
                 void(std::optional<core_tests_pigeontest::FlutterError> reply)>
                     result) override;
  void EchoAsyncString(
      const std::string& a_string,
      std::function<void(core_tests_pigeontest::ErrorOr<std::string> reply)>
          result) override;
  void ThrowAsyncError(
      std::function<void(
          core_tests_pigeontest::ErrorOr<std::optional<flutter::EncodableValue>>
              reply)>
          result) override;
  void ThrowAsyncErrorFromVoid(
      std::function<
          void(std::optional<core_tests_pigeontest::FlutterError> reply)>
          result) override;
  void CallFlutterNoop(
      std::function<
          void(std::optional<core_tests_pigeontest::FlutterError> reply)>
          result) override;
  void CallFlutterEchoAllTypes(
      const core_tests_pigeontest::AllTypes& everything,
      std::function<
          void(core_tests_pigeontest::ErrorOr<core_tests_pigeontest::AllTypes>
                   reply)>
          result) override;
  void CallFlutterSendMultipleNullableTypes(
      const bool* a_nullable_bool, const int64_t* a_nullable_int,
      const std::string* a_nullable_string,
      std::function<void(core_tests_pigeontest::ErrorOr<
                         core_tests_pigeontest::AllNullableTypes>
                             reply)>
          result) override;
  void CallFlutterEchoBool(
      bool a_bool,
      std::function<void(core_tests_pigeontest::ErrorOr<bool> reply)> result)
      override;
  void CallFlutterEchoInt(
      int64_t an_int,
      std::function<void(core_tests_pigeontest::ErrorOr<int64_t> reply)> result)
      override;
  void CallFlutterEchoDouble(
      double a_double,
      std::function<void(core_tests_pigeontest::ErrorOr<double> reply)> result)
      override;
  void CallFlutterEchoString(
      const std::string& a_string,
      std::function<void(core_tests_pigeontest::ErrorOr<std::string> reply)>
          result) override;
  void CallFlutterEchoUint8List(
      const std::vector<uint8_t>& a_list,
      std::function<
          void(core_tests_pigeontest::ErrorOr<std::vector<uint8_t>> reply)>
          result) override;
  void CallFlutterEchoList(
      const flutter::EncodableList& a_list,
      std::function<
          void(core_tests_pigeontest::ErrorOr<flutter::EncodableList> reply)>
          result) override;
  void CallFlutterEchoMap(
      const flutter::EncodableMap& a_map,
      std::function<
          void(core_tests_pigeontest::ErrorOr<flutter::EncodableMap> reply)>
          result) override;
  void CallFlutterEchoNullableBool(
      const bool* a_bool,
      std::function<
          void(core_tests_pigeontest::ErrorOr<std::optional<bool>> reply)>
          result) override;
  void CallFlutterEchoNullableInt(
      const int64_t* an_int,
      std::function<
          void(core_tests_pigeontest::ErrorOr<std::optional<int64_t>> reply)>
          result) override;
  void CallFlutterEchoNullableDouble(
      const double* a_double,
      std::function<
          void(core_tests_pigeontest::ErrorOr<std::optional<double>> reply)>
          result) override;
  void CallFlutterEchoNullableString(
      const std::string* a_string,
      std::function<void(
          core_tests_pigeontest::ErrorOr<std::optional<std::string>> reply)>
          result) override;
  void CallFlutterEchoNullableUint8List(
      const std::vector<uint8_t>* a_list,
      std::function<void(
          core_tests_pigeontest::ErrorOr<std::optional<std::vector<uint8_t>>>
              reply)>
          result) override;
  void CallFlutterEchoNullableList(
      const flutter::EncodableList* a_list,
      std::function<void(
          core_tests_pigeontest::ErrorOr<std::optional<flutter::EncodableList>>
              reply)>
          result) override;
  void CallFlutterEchoNullableMap(
      const flutter::EncodableMap* a_map,
      std::function<void(
          core_tests_pigeontest::ErrorOr<std::optional<flutter::EncodableMap>>
              reply)>
          result) override;

 private:
  std::unique_ptr<core_tests_pigeontest::FlutterIntegrationCoreApi>
      flutter_api_;
};

}  // namespace test_plugin

#endif  // FLUTTER_PLUGIN_TEST_PLUGIN_H_
