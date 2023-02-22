// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
// Autogenerated from Pigeon (v4.2.14), do not edit directly.
// See also: https://pub.dev/packages/pigeon
// ignore_for_file: public_member_api_docs, non_constant_identifier_names, avoid_as, unused_import, unnecessary_parenthesis, prefer_null_aware_operators, omit_local_variable_types, unused_shown_name, unnecessary_import
import 'dart:async';
import 'dart:typed_data' show Float64List, Int32List, Int64List, Uint8List;

import 'package:flutter/foundation.dart' show ReadBuffer, WriteBuffer;
import 'package:flutter/services.dart';

/// A Pigeon representation of the macOS portion of an `XTypeGroup`.
class AllowedTypes {
  AllowedTypes({
    required this.extensions,
    required this.mimeTypes,
    required this.utis,
  });

  List<String?> extensions;

  List<String?> mimeTypes;

  List<String?> utis;

  Object encode() {
    return <Object?>[
      extensions,
      mimeTypes,
      utis,
    ];
  }

  static AllowedTypes decode(Object result) {
    result as List<Object?>;
    return AllowedTypes(
      extensions: (result[0] as List<Object?>?)!.cast<String?>(),
      mimeTypes: (result[1] as List<Object?>?)!.cast<String?>(),
      utis: (result[2] as List<Object?>?)!.cast<String?>(),
    );
  }
}

/// Options for save panels.
///
/// These correspond to NSSavePanel properties (which are, by extension
/// NSOpenPanel properties as well).
class SavePanelOptions {
  SavePanelOptions({
    this.allowedFileTypes,
    this.directoryPath,
    this.nameFieldStringValue,
    this.prompt,
  });

  AllowedTypes? allowedFileTypes;

  String? directoryPath;

  String? nameFieldStringValue;

  String? prompt;

  Object encode() {
    return <Object?>[
      allowedFileTypes?.encode(),
      directoryPath,
      nameFieldStringValue,
      prompt,
    ];
  }

  static SavePanelOptions decode(Object result) {
    result as List<Object?>;
    return SavePanelOptions(
      allowedFileTypes: result[0] != null
          ? AllowedTypes.decode(result[0]! as List<Object?>)
          : null,
      directoryPath: result[1] as String?,
      nameFieldStringValue: result[2] as String?,
      prompt: result[3] as String?,
    );
  }
}

/// Options for open panels.
///
/// These correspond to NSOpenPanel properties.
class OpenPanelOptions {
  OpenPanelOptions({
    required this.allowsMultipleSelection,
    required this.canChooseDirectories,
    required this.canChooseFiles,
    required this.baseOptions,
  });

  bool allowsMultipleSelection;

  bool canChooseDirectories;

  bool canChooseFiles;

  SavePanelOptions baseOptions;

  Object encode() {
    return <Object?>[
      allowsMultipleSelection,
      canChooseDirectories,
      canChooseFiles,
      baseOptions.encode(),
    ];
  }

  static OpenPanelOptions decode(Object result) {
    result as List<Object?>;
    return OpenPanelOptions(
      allowsMultipleSelection: result[0]! as bool,
      canChooseDirectories: result[1]! as bool,
      canChooseFiles: result[2]! as bool,
      baseOptions: SavePanelOptions.decode(result[3]! as List<Object?>),
    );
  }
}

class _FileSelectorApiCodec extends StandardMessageCodec {
  const _FileSelectorApiCodec();
  @override
  void writeValue(WriteBuffer buffer, Object? value) {
    if (value is AllowedTypes) {
      buffer.putUint8(128);
      writeValue(buffer, value.encode());
    } else if (value is OpenPanelOptions) {
      buffer.putUint8(129);
      writeValue(buffer, value.encode());
    } else if (value is SavePanelOptions) {
      buffer.putUint8(130);
      writeValue(buffer, value.encode());
    } else {
      super.writeValue(buffer, value);
    }
  }

  @override
  Object? readValueOfType(int type, ReadBuffer buffer) {
    switch (type) {
      case 128:
        return AllowedTypes.decode(readValue(buffer)!);

      case 129:
        return OpenPanelOptions.decode(readValue(buffer)!);

      case 130:
        return SavePanelOptions.decode(readValue(buffer)!);

      default:
        return super.readValueOfType(type, buffer);
    }
  }
}

class FileSelectorApi {
  /// Constructor for [FileSelectorApi].  The [binaryMessenger] named argument is
  /// available for dependency injection.  If it is left null, the default
  /// BinaryMessenger will be used which routes to the host platform.
  FileSelectorApi({BinaryMessenger? binaryMessenger})
      : _binaryMessenger = binaryMessenger;
  final BinaryMessenger? _binaryMessenger;

  static const MessageCodec<Object?> codec = _FileSelectorApiCodec();

  /// Shows an open panel with the given [options], returning the list of
  /// selected paths.
  ///
  /// An empty list corresponds to a cancelled selection.
  Future<List<String?>> displayOpenPanel(OpenPanelOptions arg_options) async {
    final BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
        'dev.flutter.pigeon.FileSelectorApi.displayOpenPanel', codec,
        binaryMessenger: _binaryMessenger);
    final List<Object?>? replyList =
        await channel.send(<Object?>[arg_options]) as List<Object?>?;
    if (replyList == null) {
      throw PlatformException(
        code: 'channel-error',
        message: 'Unable to establish connection on channel.',
      );
    } else if (replyList.length > 1) {
      throw PlatformException(
        code: replyList[0]! as String,
        message: replyList[1] as String?,
        details: replyList[2],
      );
    } else if (replyList[0] == null) {
      throw PlatformException(
        code: 'null-error',
        message: 'Host platform returned null value for non-null return value.',
      );
    } else {
      return (replyList[0] as List<Object?>?)!.cast<String?>();
    }
  }

  /// Shows a save panel with the given [options], returning the selected path.
  ///
  /// A null return corresponds to a cancelled save.
  Future<String?> displaySavePanel(SavePanelOptions arg_options) async {
    final BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
        'dev.flutter.pigeon.FileSelectorApi.displaySavePanel', codec,
        binaryMessenger: _binaryMessenger);
    final List<Object?>? replyList =
        await channel.send(<Object?>[arg_options]) as List<Object?>?;
    if (replyList == null) {
      throw PlatformException(
        code: 'channel-error',
        message: 'Unable to establish connection on channel.',
      );
    } else if (replyList.length > 1) {
      throw PlatformException(
        code: replyList[0]! as String,
        message: replyList[1] as String?,
        details: replyList[2],
      );
    } else {
      return (replyList[0] as String?);
    }
  }
}
