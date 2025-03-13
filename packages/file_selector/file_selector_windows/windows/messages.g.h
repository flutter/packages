// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
// Autogenerated from Pigeon (v22.4.1), do not edit directly.
// See also: https://pub.dev/packages/pigeon

#ifndef PIGEON_MESSAGES_G_H_
#define PIGEON_MESSAGES_G_H_
#include <flutter/basic_message_channel.h>
#include <flutter/binary_messenger.h>
#include <flutter/encodable_value.h>
#include <flutter/standard_message_codec.h>

#include <map>
#include <optional>
#include <string>

namespace file_selector_windows {

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
  ErrorOr(const T& rhs) : v_(rhs) {}
  ErrorOr(const T&& rhs) : v_(std::move(rhs)) {}
  ErrorOr(const FlutterError& rhs) : v_(rhs) {}
  ErrorOr(const FlutterError&& rhs) : v_(std::move(rhs)) {}

  bool has_error() const { return std::holds_alternative<FlutterError>(v_); }
  const T& value() const { return std::get<T>(v_); };
  const FlutterError& error() const { return std::get<FlutterError>(v_); };

 private:
  friend class FileSelectorApi;
  ErrorOr() = default;
  T TakeValue() && { return std::get<T>(std::move(v_)); }

  std::variant<T, FlutterError> v_;
};

// Generated class from Pigeon that represents data sent in messages.
class TypeGroup {
 public:
  // Constructs an object setting all fields.
  explicit TypeGroup(const std::string& label,
                     const flutter::EncodableList& extensions);

  const std::string& label() const;
  void set_label(std::string_view value_arg);

  const flutter::EncodableList& extensions() const;
  void set_extensions(const flutter::EncodableList& value_arg);

 private:
  static TypeGroup FromEncodableList(const flutter::EncodableList& list);
  flutter::EncodableList ToEncodableList() const;
  friend class FileSelectorApi;
  friend class PigeonInternalCodecSerializer;
  std::string label_;
  flutter::EncodableList extensions_;
};

// Generated class from Pigeon that represents data sent in messages.
class SelectionOptions {
 public:
  // Constructs an object setting all fields.
  explicit SelectionOptions(bool allow_multiple, bool select_folders,
                            const flutter::EncodableList& allowed_types);

  bool allow_multiple() const;
  void set_allow_multiple(bool value_arg);

  bool select_folders() const;
  void set_select_folders(bool value_arg);

  const flutter::EncodableList& allowed_types() const;
  void set_allowed_types(const flutter::EncodableList& value_arg);

 private:
  static SelectionOptions FromEncodableList(const flutter::EncodableList& list);
  flutter::EncodableList ToEncodableList() const;
  friend class FileSelectorApi;
  friend class PigeonInternalCodecSerializer;
  bool allow_multiple_;
  bool select_folders_;
  flutter::EncodableList allowed_types_;
};

// The result from an open or save dialog.
//
// Generated class from Pigeon that represents data sent in messages.
class FileDialogResult {
 public:
  // Constructs an object setting all non-nullable fields.
  explicit FileDialogResult(const flutter::EncodableList& paths);

  // Constructs an object setting all fields.
  explicit FileDialogResult(const flutter::EncodableList& paths,
                            const int64_t* type_group_index);

  // The selected paths.
  //
  // Empty if the dialog was canceled.
  const flutter::EncodableList& paths() const;
  void set_paths(const flutter::EncodableList& value_arg);

  // The type group index (into the list provided in [SelectionOptions]) of
  // the group that was selected when the dialog was confirmed.
  //
  // Null if no type groups were provided, or the dialog was canceled.
  const int64_t* type_group_index() const;
  void set_type_group_index(const int64_t* value_arg);
  void set_type_group_index(int64_t value_arg);

 private:
  static FileDialogResult FromEncodableList(const flutter::EncodableList& list);
  flutter::EncodableList ToEncodableList() const;
  friend class FileSelectorApi;
  friend class PigeonInternalCodecSerializer;
  flutter::EncodableList paths_;
  std::optional<int64_t> type_group_index_;
};

class PigeonInternalCodecSerializer : public flutter::StandardCodecSerializer {
 public:
  PigeonInternalCodecSerializer();
  inline static PigeonInternalCodecSerializer& GetInstance() {
    static PigeonInternalCodecSerializer sInstance;
    return sInstance;
  }

  void WriteValue(const flutter::EncodableValue& value,
                  flutter::ByteStreamWriter* stream) const override;

 protected:
  flutter::EncodableValue ReadValueOfType(
      uint8_t type, flutter::ByteStreamReader* stream) const override;
};

// Generated interface from Pigeon that represents a handler of messages from
// Flutter.
class FileSelectorApi {
 public:
  FileSelectorApi(const FileSelectorApi&) = delete;
  FileSelectorApi& operator=(const FileSelectorApi&) = delete;
  virtual ~FileSelectorApi() {}
  virtual ErrorOr<FileDialogResult> ShowOpenDialog(
      const SelectionOptions& options, const std::string* initial_directory,
      const std::string* confirm_button_text) = 0;
  virtual ErrorOr<FileDialogResult> ShowSaveDialog(
      const SelectionOptions& options, const std::string* initial_directory,
      const std::string* suggested_name,
      const std::string* confirm_button_text) = 0;

  // The codec used by FileSelectorApi.
  static const flutter::StandardMessageCodec& GetCodec();
  // Sets up an instance of `FileSelectorApi` to handle messages through the
  // `binary_messenger`.
  static void SetUp(flutter::BinaryMessenger* binary_messenger,
                    FileSelectorApi* api);
  static void SetUp(flutter::BinaryMessenger* binary_messenger,
                    FileSelectorApi* api,
                    const std::string& message_channel_suffix);
  static flutter::EncodableValue WrapError(std::string_view error_message);
  static flutter::EncodableValue WrapError(const FlutterError& error);

 protected:
  FileSelectorApi() = default;
};
}  // namespace file_selector_windows
#endif  // PIGEON_MESSAGES_G_H_
