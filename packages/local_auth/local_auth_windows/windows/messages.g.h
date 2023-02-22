// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
// Autogenerated from Pigeon (v5.0.1), do not edit directly.
// See also: https://pub.dev/packages/pigeon

#ifndef PIGEON_LOCAL_AUTH_WINDOWS_H_
#define PIGEON_LOCAL_AUTH_WINDOWS_H_
#include <flutter/basic_message_channel.h>
#include <flutter/binary_messenger.h>
#include <flutter/encodable_value.h>
#include <flutter/standard_message_codec.h>

#include <map>
#include <optional>
#include <string>

namespace local_auth_windows {

// Generated class from Pigeon.

class FlutterError {
 public:
  explicit FlutterError(const std::string& code) : code_(code) {}
  explicit FlutterError(const std::string& code, const std::string& message)
      : code_(code), message_(message) {}
  explicit FlutterError(const std::string& code, const std::string& message,
                        const flutter::EncodableValue& details)
      : code_(code), message_(message), details_(details) {}

  const std::string& code() const { return code_; }
  const std::string& message() const { return message_; }
  const flutter::EncodableValue& details() const { return details_; }

 private:
  std::string code_;
  std::string message_;
  flutter::EncodableValue details_;
};

template <class T>
class ErrorOr {
 public:
  ErrorOr(const T& rhs) { new (&v_) T(rhs); }
  ErrorOr(const T&& rhs) { v_ = std::move(rhs); }
  ErrorOr(const FlutterError& rhs) { new (&v_) FlutterError(rhs); }
  ErrorOr(const FlutterError&& rhs) { v_ = std::move(rhs); }

  bool has_error() const { return std::holds_alternative<FlutterError>(v_); }
  const T& value() const { return std::get<T>(v_); };
  const FlutterError& error() const { return std::get<FlutterError>(v_); };

 private:
  friend class LocalAuthApi;
  ErrorOr() = default;
  T TakeValue() && { return std::get<T>(std::move(v_)); }

  std::variant<T, FlutterError> v_;
};

// Generated interface from Pigeon that represents a handler of messages from
// Flutter.
class LocalAuthApi {
 public:
  LocalAuthApi(const LocalAuthApi&) = delete;
  LocalAuthApi& operator=(const LocalAuthApi&) = delete;
  virtual ~LocalAuthApi(){};
  // Returns true if this device supports authentication.
  virtual void IsDeviceSupported(
      std::function<void(ErrorOr<bool> reply)> result) = 0;
  // Attempts to authenticate the user with the provided [localizedReason] as
  // the user-facing explanation for the authorization request.
  //
  // Returns true if authorization succeeds, false if it is attempted but is
  // not successful, and an error if authorization could not be attempted.
  virtual void Authenticate(
      const std::string& localized_reason,
      std::function<void(ErrorOr<bool> reply)> result) = 0;

  // The codec used by LocalAuthApi.
  static const flutter::StandardMessageCodec& GetCodec();
  // Sets up an instance of `LocalAuthApi` to handle messages through the
  // `binary_messenger`.
  static void SetUp(flutter::BinaryMessenger* binary_messenger,
                    LocalAuthApi* api);
  static flutter::EncodableValue WrapError(std::string_view error_message);
  static flutter::EncodableValue WrapError(const FlutterError& error);

 protected:
  LocalAuthApi() = default;
};
}  // namespace local_auth_windows
#endif  // PIGEON_LOCAL_AUTH_WINDOWS_H_
