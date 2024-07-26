// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
// Autogenerated from Pigeon (v21.0.0), do not edit directly.
// See also: https://pub.dev/packages/pigeon
// ignore_for_file: public_member_api_docs, non_constant_identifier_names, avoid_as, unused_import, unnecessary_parenthesis, prefer_null_aware_operators, omit_local_variable_types, unused_shown_name, unnecessary_import, no_leading_underscores_for_local_identifiers

import 'dart:async';
import 'dart:typed_data' show Float64List, Int32List, Int64List, Uint8List;

import 'package:flutter/foundation.dart' show ReadBuffer, WriteBuffer;
import 'package:flutter/services.dart';

PlatformException _createConnectionError(String channelName) {
  return PlatformException(
    code: 'channel-error',
    message: 'Unable to establish connection on channel: "$channelName".',
  );
}

List<Object?> wrapResponse(
    {Object? result, PlatformException? error, bool empty = false}) {
  if (empty) {
    return <Object?>[];
  }
  if (error == null) {
    return <Object?>[result];
  }
  return <Object?>[error.code, error.message, error.details];
}

class TypeGroup {
  TypeGroup({
    required this.label,
    required this.extensions,
  });

  String label;

  List<String?> extensions;

  Object encode() {
    return <Object?>[
      label,
      extensions,
    ];
  }

  static TypeGroup decode(Object result) {
    result as List<Object?>;
    return TypeGroup(
      label: result[0]! as String,
      extensions: (result[1] as List<Object?>?)!.cast<String?>(),
    );
  }
}

class SelectionOptions {
  SelectionOptions({
    this.allowMultiple = false,
    this.selectFolders = false,
    this.allowedTypes = const <TypeGroup?>[],
  });

  bool allowMultiple;

  bool selectFolders;

  List<TypeGroup?> allowedTypes;

  Object encode() {
    return <Object?>[
      allowMultiple,
      selectFolders,
      allowedTypes,
    ];
  }

  static SelectionOptions decode(Object result) {
    result as List<Object?>;
    return SelectionOptions(
      allowMultiple: result[0]! as bool,
      selectFolders: result[1]! as bool,
      allowedTypes: (result[2] as List<Object?>?)!.cast<TypeGroup?>(),
    );
  }
}

/// The result from an open or save dialog.
class FileDialogResult {
  FileDialogResult({
    required this.paths,
    this.typeGroupIndex,
  });

  /// The selected paths.
  ///
  /// Empty if the dialog was canceled.
  List<String?> paths;

  /// The type group index (into the list provided in [SelectionOptions]) of
  /// the group that was selected when the dialog was confirmed.
  ///
  /// Null if no type groups were provided, or the dialog was canceled.
  int? typeGroupIndex;

  Object encode() {
    return <Object?>[
      paths,
      typeGroupIndex,
    ];
  }

  static FileDialogResult decode(Object result) {
    result as List<Object?>;
    return FileDialogResult(
      paths: (result[0] as List<Object?>?)!.cast<String?>(),
      typeGroupIndex: result[1] as int?,
    );
  }
}

class _PigeonCodec extends StandardMessageCodec {
  const _PigeonCodec();
  @override
  void writeValue(WriteBuffer buffer, Object? value) {
    if (value is TypeGroup) {
      buffer.putUint8(129);
      writeValue(buffer, value.encode());
    } else if (value is SelectionOptions) {
      buffer.putUint8(130);
      writeValue(buffer, value.encode());
    } else if (value is FileDialogResult) {
      buffer.putUint8(131);
      writeValue(buffer, value.encode());
    } else {
      super.writeValue(buffer, value);
    }
  }

  @override
  Object? readValueOfType(int type, ReadBuffer buffer) {
    switch (type) {
      case 129:
        return TypeGroup.decode(readValue(buffer)!);
      case 130:
        return SelectionOptions.decode(readValue(buffer)!);
      case 131:
        return FileDialogResult.decode(readValue(buffer)!);
      default:
        return super.readValueOfType(type, buffer);
    }
  }
}

class FileSelectorApi {
  /// Constructor for [FileSelectorApi].  The [binaryMessenger] named argument is
  /// available for dependency injection.  If it is left null, the default
  /// BinaryMessenger will be used which routes to the host platform.
  FileSelectorApi(
      {BinaryMessenger? binaryMessenger, String messageChannelSuffix = ''})
      : __pigeon_binaryMessenger = binaryMessenger,
        __pigeon_messageChannelSuffix =
            messageChannelSuffix.isNotEmpty ? '.$messageChannelSuffix' : '';
  final BinaryMessenger? __pigeon_binaryMessenger;

  static const MessageCodec<Object?> pigeonChannelCodec = _PigeonCodec();

  final String __pigeon_messageChannelSuffix;

  Future<FileDialogResult> showOpenDialog(SelectionOptions options,
      String? initialDirectory, String? confirmButtonText) async {
    final String __pigeon_channelName =
        'dev.flutter.pigeon.file_selector_windows.FileSelectorApi.showOpenDialog$__pigeon_messageChannelSuffix';
    final BasicMessageChannel<Object?> __pigeon_channel =
        BasicMessageChannel<Object?>(
      __pigeon_channelName,
      pigeonChannelCodec,
      binaryMessenger: __pigeon_binaryMessenger,
    );
    final List<Object?>? __pigeon_replyList = await __pigeon_channel
            .send(<Object?>[options, initialDirectory, confirmButtonText])
        as List<Object?>?;
    if (__pigeon_replyList == null) {
      throw _createConnectionError(__pigeon_channelName);
    } else if (__pigeon_replyList.length > 1) {
      throw PlatformException(
        code: __pigeon_replyList[0]! as String,
        message: __pigeon_replyList[1] as String?,
        details: __pigeon_replyList[2],
      );
    } else if (__pigeon_replyList[0] == null) {
      throw PlatformException(
        code: 'null-error',
        message: 'Host platform returned null value for non-null return value.',
      );
    } else {
      return (__pigeon_replyList[0] as FileDialogResult?)!;
    }
  }

  Future<FileDialogResult> showSaveDialog(
      SelectionOptions options,
      String? initialDirectory,
      String? suggestedName,
      String? confirmButtonText) async {
    final String __pigeon_channelName =
        'dev.flutter.pigeon.file_selector_windows.FileSelectorApi.showSaveDialog$__pigeon_messageChannelSuffix';
    final BasicMessageChannel<Object?> __pigeon_channel =
        BasicMessageChannel<Object?>(
      __pigeon_channelName,
      pigeonChannelCodec,
      binaryMessenger: __pigeon_binaryMessenger,
    );
    final List<Object?>? __pigeon_replyList = await __pigeon_channel
        .send(<Object?>[
      options,
      initialDirectory,
      suggestedName,
      confirmButtonText
    ]) as List<Object?>?;
    if (__pigeon_replyList == null) {
      throw _createConnectionError(__pigeon_channelName);
    } else if (__pigeon_replyList.length > 1) {
      throw PlatformException(
        code: __pigeon_replyList[0]! as String,
        message: __pigeon_replyList[1] as String?,
        details: __pigeon_replyList[2],
      );
    } else if (__pigeon_replyList[0] == null) {
      throw PlatformException(
        code: 'null-error',
        message: 'Host platform returned null value for non-null return value.',
      );
    } else {
      return (__pigeon_replyList[0] as FileDialogResult?)!;
    }
  }
}
