// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// This file is hand-formatted.

// This file must not import `dart:ui`, directly or indirectly, as it is
// intended to function even in pure Dart server or CLI environments.
import 'dart:convert';
import 'dart:typed_data';

import 'model.dart';

/// The first four bytes of a Remote Flutter Widgets binary data blob.
///
/// This signature is automatically added by [encodeDataBlob] and is checked in
/// [decodeDataBlob].
///
/// See also:
///
///  * [libraryBlobSignature], which is the signature for binary library blobs.
const List<int> dataBlobSignature = <int>[0xFE, 0x52, 0x57, 0x44];

/// The first four bytes of a Remote Flutter Widgets binary library blob.
///
/// This signature is automatically added by [encodeLibraryBlob] and is checked
/// in [decodeLibraryBlob].
///
/// See also:
///
///  * [dataBlobSignature], which is the signature for binary data blobs.
const List<int> libraryBlobSignature = <int>[0xFE, 0x52, 0x46, 0x57];

/// Encode data as a Remote Flutter Widgets binary data blob.
///
/// See also:
///
///  * [decodeDataBlob], which decodes this format.
///  * [encodeLibraryBlob], which uses a superset of this format to encode
///    Remote Flutter Widgets binary library blobs.
Uint8List encodeDataBlob(Object value) {
  final _BlobEncoder encoder = _BlobEncoder();
  encoder.writeSignature(dataBlobSignature);
  encoder.writeValue(value);
  return encoder.bytes.toBytes();
}

/// Decode a Remote Flutter Widgets binary data blob.
///
/// This data is usually used in conjunction with [DynamicContent].
///
/// This method supports a subset of the format supported by
/// [decodeLibraryBlob]; specifically, it reads a _value_ from that format
/// (rather than a _library_), and disallows values other than maps, lists,
/// ints, doubles, booleans, and strings. See [decodeLibraryBlob] for a
/// description of the format.
///
/// The first four bytes of the file (in hex) are FE 52 57 44; see
/// [dataBlobSignature].
///
/// See also:
///
///  * [encodeDataBlob], which encodes this format.
///  * [decodeLibraryBlob], which uses a superset of this format to decode
///    Remote Flutter Widgets binary library blobs.
///  * [parseDataFile], which parses the text variant of this format.
Object decodeDataBlob(Uint8List bytes) {
  final _BlobDecoder decoder = _BlobDecoder(bytes.buffer.asByteData(bytes.offsetInBytes, bytes.lengthInBytes));
  decoder.expectSignature(dataBlobSignature);
  final Object result = decoder.readValue();
  if (!decoder.finished) {
    throw const FormatException('Unexpected trailing bytes after value.');
  }
  return result;
}

/// Encode data as a Remote Flutter Widgets binary library blob.
///
/// See also:
///
///  * [decodeLibraryBlob], which decodes this format.
///  * [encodeDataBlob], which uses a subset of this format to decode
///    Remote Flutter Widgets binary data blobs.
///  * [parseLibraryFile], which parses the text variant of this format.
Uint8List encodeLibraryBlob(RemoteWidgetLibrary value) {
  final _BlobEncoder encoder = _BlobEncoder();
  encoder.writeSignature(libraryBlobSignature);
  encoder.writeLibrary(value);
  return encoder.bytes.toBytes();
}

/// Decode a Remote Flutter Widgets binary library blob.
///
/// Remote widget libraries are usually used in conjunction with a [Runtime].
///
/// ## Format
///
/// This format is a depth-first serialization of the in-memory data structures,
/// using a one-byte tag to identify types when necessary, and using 64 bit
/// integers to encode lengths when necessary.
///
/// The first four bytes of the file (in hex) are FE 52 46 57; see
/// [libraryBlobSignature].
///
/// Primitives in this format are as follows:
///
/// * Integers are encoded as little-endian two's complement 64 bit integers.
///   For example, the number 513 (0x0000000000000201) is encoded as a 0x01
///   byte, a 0x02 byte, and six 0x00 bytes, in that order.
///
/// * Doubles are encoded as little-endian IEEE binary64 numbers.
///
/// * Strings are encoded as an integer length followed by that many UTF-8
///   encoded bytes.
///
///   For example, the string "Hello" would be encoded as:
///
///       05 00 00 00 00 00 00 00  48 65 6C 6C 6F
///
/// * Lists are encoded as an integer length, followed by that many values
///   back to back. When lists are of specific types (e.g. lists of imports),
///   each value in the list is encoded directly (untagged lists); when the list
///   can have multiple types, each value is prefixed by a tag giving the type,
///   followed by the value (tagged lists). For example, a list of integers with
///   the values 1 and 2 in that order would be encoded as:
///
///       02 00 00 00 00 00 00 00  01 00 00 00 00 00 00 00
///       02 00 00 00 00 00 00 00
///
///   A list of arbitrary values that happens to contain one string "Hello"
///   would be encoded as follows; 0x04 is the tag for "String" (the full list
///   of tags is described below):
///
///       01 00 00 00 00 00 00 00  04 05 00 00 00 00 00 00
///       00 48 65 6C 6C 6F
///
///   A list of length zero is eight zero bytes with no additional payload.
///
/// * Maps are encoded as an integer length, followed by key/value pairs. For
///   maps where all the keys are strings (e.g. when encoding a [DynamicMap]),
///   the keys are given without tags (an untagged map). For maps where the keys
///   are of arbitrary values, the keys are prefixed by a tag byte (a tagged
///   map; this is only used when encoding [Switch]es). The _values_ are always
///   prefixed by a tag byte (all maps are over values of arbitrary types).
///
///   For example, the map `{ a: 15 }` (when the keys are known to always be
///   strings, so they are untagged) is encoded as follows (0x02 is the tag for
///   integers):
///
///       01 00 00 00 00 00 00 00  01 00 00 00 00 00 00 00
///       61 02 0F 00 00 00 00 00  00 00
///
/// Objects are encoded as follows:
///
/// * [RemoteWidgetLibrary] objects are encoded as an untagged list of
///   imports and an untagged list of widget declarations.
///
/// * Imports are encoded as an untagged list of strings, each of which is
///   one of the subparts of the imported library name. For example, `import
///   a.b` is encoded as:
///
///       02 00 00 00 00 00 00 00  01 00 00 00 00 00 00 00
///       61 01 00 00 00 00 00 00  00 62
///
/// * Widget declarations are encoded as a string giving the declaration name,
///   an untagged map for the initial state, and finally the value that
///   represents the root of the widget declaration ([WidgetDeclaration.root],
///   which is always either a [Switch] or a [ConstructorCall]).
///
///   When the widget's initial state is null, it is encoded as an empty map. By
///   extension, this means no distinction is made between a "stateless" remote
///   widget and a "stateful" remote widget whose initial state is empty. (This
///   is reasonable since if the initial state is empty, no state can ever be
///   changed, so the widget is in fact _de facto_ stateless.)
///
/// Values are encoded as a tag byte followed by their data, as follows:
///
/// * Booleans are encoded as just a tag, with the tag being 0x00 for false and
///   0x01 for true.
///
/// * Integers have the tag 0x02, and are encoded as described above (two's
///   complement, little-endian, 64 bit).
///
/// * Doubles have the tag 0x03, and are encoded as described above
///   (little-endian binary64).
///
/// * Strings have the tag 0x04, and are encoded as described above (length
///   followed by UTF-8 bytes).
///
/// * Lists ([DynamicList]) have the tag 0x05, are encoded as described above
///   (length followed by tagged values). (Lists of untagged values are never
///   found in a "value" context.)
///
/// * Maps ([DynamicMap]) have the tag 0x07, are encoded as described above
///   (length followed by pairs of strings and tagged values). (Tagged maps,
///   i.e. those with tagged keys, are never found in a "value" context.)
///
/// * Loops ([Loop]) have the tag 0x08. They are encoded as two tagged values,
///   the [Loop.input] and the [Loop.output].
///
/// * Constructor calls ([ConstructorCall]) have the tag 0x09. They are encoded
///   as a string for the [ConstructorCall.name] followed by an untagged map
///   describing the [ConstructorCall.arguments].
///
/// * Argument, data, and state references ([ArgsReference], [DataReference],
///   and [StateReference] respectively) have tags 0x0A, 0x0B, and 0x0D
///   respectively, and are encoded as tagged lists of strings or integers
///   giving the [Reference.parts] of the reference.
///
/// * Loop references ([LoopReference]) have the tag 0x0C, and are encoded as an
///   integer giving the number of [Loop] objects between the reference and the
///   loop being referenced (this is similar to a De Bruijn index), followed by
///   a tagged list of strings or integers giving the [Reference.parts] of the
///   reference.
///
/// * Switches ([Switch]) have the tag 0x0F. They are encoded as a tagged value
///   describing the control value ([Switch.input]), followed by a tagged map
///   for the various case values ([Switch.outputs]). The default case is
///   represented by a value with tag 0x10 (and no data).
///
///   For example, this switch:
///
///   ```
///   switch (args.a) {
///    0: 'z',
///    1: 'o',
///    default: 'd',
///   }
///   ```
///
///   ...is encoded as follows (including the tag for the switch itself):
///
///       0F 0A 01 00 00 00 00 00  00 00 61 03 00 00 00 00
///       00 00 00 02 00 00 00 00  00 00 00 00 04 01 00 00
///       00 00 00 00 00 7A 02 01  00 00 00 00 00 00 00 04
///       01 00 00 00 00 00 00 00  6F 10 04 01 00 00 00 00
///       00 00 00 64
///
/// * Event handlers have the tag 0x0E, and are encoded as a string
///   ([EventHandler.eventName]) and an untagged map
///   ([EventHandler.eventArguments]).
///
/// * State-setting handlers have the tag 0x11, and are encoded as a tagged list
///   of strings or integers giving the [Reference.parts] of the state reference
///   ([SetStateHandler.stateReference]), followed by the tagged value to which
///   to set that state entry ([SetStateHandler.value]).
///
/// See also:
///
///  * [encodeLibraryBlob], which encodes this format.
///  * [decodeDataBlob], which uses a subset of this format to decode
///    Remote Flutter Widgets binary data blobs.
///  * [parseDataFile], which parses the text variant of this format.
RemoteWidgetLibrary decodeLibraryBlob(Uint8List bytes) {
  final _BlobDecoder decoder = _BlobDecoder(bytes.buffer.asByteData(bytes.offsetInBytes, bytes.lengthInBytes));
  decoder.expectSignature(libraryBlobSignature);
  final RemoteWidgetLibrary result = decoder.readLibrary();
  if (!decoder.finished) {
    throw const FormatException('Unexpected trailing bytes after constructors.');
  }
  return result;
}

// endianess used by this format
const Endian _blobEndian = Endian.little;

// magic signatures
const int _msFalse = 0x00;
const int _msTrue = 0x01;
const int _msInt64 = 0x02;
const int _msBinary64 = 0x03;
const int _msString = 0x04;
const int _msList = 0x05;
const int _msMap = 0x07;
const int _msLoop = 0x08;
const int _msWidget = 0x09;
const int _msArgsReference = 0x0A;
const int _msDataReference = 0x0B;
const int _msLoopReference = 0x0C;
const int _msStateReference = 0x0D;
const int _msEvent = 0x0E;
const int _msSwitch = 0x0F;
const int _msDefault = 0x10;
const int _msSetState = 0x11;

/// API for decoding Remote Flutter Widgets binary blobs.
///
/// Binary data blobs can be decoded by using [readValue].
///
/// Binary library blobs can be decoded by using [readLibrary].
///
/// In either case, if [finished] returns false after parsing the root token,
/// then there is unexpected further data in the file.
class _BlobDecoder {
  _BlobDecoder(this.bytes);

  final ByteData bytes;

  int _cursor = 0;

  bool get finished => _cursor >= bytes.lengthInBytes;

  void _advance(String context, int length) {
    if (_cursor + length > bytes.lengthInBytes) {
      throw FormatException('Could not read $context at offset $_cursor: unexpected end of file.');
    }
    _cursor += length;
  }

  int _readByte() {
    final int byteOffset = _cursor;
    _advance('byte', 1);
    return bytes.getUint8(byteOffset);
  }

  int _readInt64() {
    final int byteOffset = _cursor;
    _advance('int64', 8);
    return bytes.getInt64(byteOffset, _blobEndian);
  }

  double _readBinary64() {
    final int byteOffset = _cursor;
    _advance('binary64', 8);
    return bytes.getFloat64(byteOffset, _blobEndian);
  }

  String _readString() {
    final int length = _readInt64();
    final int byteOffset = _cursor;
    _advance('string', length);
    return utf8.decode(bytes.buffer.asUint8List(bytes.offsetInBytes + byteOffset, length));
  }

  List<Object> _readPartList() {
    return List<Object>.generate(_readInt64(), (int index) {
      final int type = _readByte();
      switch (type) {
        case _msString:
          return _readString();
        case _msInt64:
          return _readInt64();
        default:
          throw FormatException('Invalid reference type 0x${type.toRadixString(16).toUpperCase().padLeft(2, "0")} while decoding blob.');
      }
    });
  }

  Map<String, Object?>? _readMap(Object Function() readNode, { bool nullIfEmpty = false }) {
    final int count = _readInt64();
    if (count == 0 && nullIfEmpty) {
      return null;
    }
    return DynamicMap.fromEntries(
      Iterable<MapEntry<String, Object>>.generate(
        count,
        (int index) => MapEntry<String, Object>(
          _readString(),
          readNode(),
        ),
      ),
    );
  }

  Object? _readSwitchKey() {
    final int type = _readByte();
    if (type == _msDefault) {
      return null;
    }
    return _parseArgument(type);
  }

  Switch _readSwitch() {
    final Object value = _readArgument();
    final int count = _readInt64();
    final Map<Object?, Object> cases = Map<Object?, Object>.fromEntries(
      Iterable<MapEntry<Object?, Object>>.generate(
        count,
        (int index) => MapEntry<Object?, Object>(
          _readSwitchKey(),
          _readArgument(),
        ),
      ),
    );
    return Switch(value, cases);
  }

  Object _parseValue(int type, Object Function() readNode) {
    switch (type) {
      case _msFalse:
        return false;
      case _msTrue:
        return true;
      case _msInt64:
        return _readInt64();
      case _msBinary64:
        return _readBinary64();
      case _msString:
        return _readString();
      case _msList:
        return DynamicList.generate(_readInt64(), (int index) => readNode());
      case _msMap:
        return _readMap(readNode)!;
      default: throw FormatException('Unrecognized data type 0x${type.toRadixString(16).toUpperCase().padLeft(2, "0")} while decoding blob.');
    }
  }

  Object readValue() {
    final int type = _readByte();
    return _parseValue(type, readValue);
  }

  Object _parseArgument(int type) {
    switch (type) {
      case _msLoop:
        return Loop(_readArgument(), _readArgument());
      case _msWidget:
        return _readWidget();
      case _msArgsReference:
        return ArgsReference(_readPartList());
      case _msDataReference:
        return DataReference(_readPartList());
      case _msLoopReference:
        return LoopReference(_readInt64(), _readPartList());
      case _msStateReference:
        return StateReference(_readPartList());
      case _msEvent:
        return EventHandler(_readString(), _readMap(_readArgument)!);
      case _msSwitch:
        return _readSwitch();
      case _msSetState:
        return SetStateHandler(StateReference(_readPartList()), _readArgument());
      default:
        return _parseValue(type, _readArgument);
    }
  }

  Object _readArgument() {
    final int type = _readByte();
    return _parseArgument(type);
  }

  ConstructorCall _readWidget() {
    final String name = _readString();
    return ConstructorCall(name, _readMap(_readArgument)!);
  }

  WidgetDeclaration _readDeclaration() {
    final String name = _readString();
    final DynamicMap? initialState = _readMap(readValue, nullIfEmpty: true);
    final int type = _readByte();
    final BlobNode root;
    switch (type) {
      case _msSwitch:
        root = _readSwitch();
        break;
      case _msWidget:
        root = _readWidget();
        break;
      default:
        throw FormatException('Unrecognized data type 0x${type.toRadixString(16).toUpperCase().padLeft(2, "0")} while decoding widget declaration root.');
    }
    return WidgetDeclaration(name, initialState, root);
  }

  List<WidgetDeclaration> _readDeclarationList() {
    return List<WidgetDeclaration>.generate(_readInt64(), (int index) => _readDeclaration());
  }

  Import _readImport() {
    return Import(LibraryName(List<String>.generate(_readInt64(), (int index) => _readString())));
  }

  List<Import> _readImportList() {
    return List<Import>.generate(_readInt64(), (int index) => _readImport());
  }

  RemoteWidgetLibrary readLibrary() {
    return RemoteWidgetLibrary(_readImportList(), _readDeclarationList());
  }

  void expectSignature(List<int> signature) {
    assert(signature.length == 4);
    final List<int> bytes = <int>[];
    bool match = true;
    for (final int byte in signature) {
      final int read = _readByte();
      bytes.add(read);
      if (read != byte) {
        match = false;
      }
    }
    if (!match) {
      throw FormatException(
        'File signature mismatch. '
        'Expected ${signature.map<String>((int byte) => byte.toRadixString(16).toUpperCase().padLeft(2, "0")).join(" ")} '
        'but found ${bytes.map<String>((int byte) => byte.toRadixString(16).toUpperCase().padLeft(2, "0")).join(" ")}.'
      );
    }
  }
}

/// API for encoding Remote Flutter Widgets binary blobs.
///
/// Binary data blobs can be serialized using [writeValue].
///
/// Binary library blobs can be serialized using [writeLibrary].
///
/// The output is in [bytes], and can be cleared manually to reuse the [_BlobEncoder].
class _BlobEncoder {
  _BlobEncoder();

  static final Uint8List _scratchOut = Uint8List(8);
  static final ByteData _scratchIn = _scratchOut.buffer.asByteData(_scratchOut.offsetInBytes, _scratchOut.lengthInBytes);

  final BytesBuilder bytes = BytesBuilder(); // copying builder -- we repeatedly add _scratchOut after changing it

  void _writeInt64(int value) {
    _scratchIn.setInt64(0, value, _blobEndian);
    bytes.add(_scratchOut);
  }

  void _writeString(String value) {
    final Uint8List buffer = const Utf8Encoder().convert(value);
    _writeInt64(buffer.length);
    bytes.add(buffer);
  }

  void _writeMap(DynamicMap value, void Function(Object? value) recurse) {
    _writeInt64(value.length);
    value.forEach((String key, Object? value) {
      _writeString(key);
      recurse(value);
    });
  }

  void _writePart(Object? value) {
    if (value is int) {
      bytes.addByte(_msInt64);
      _writeInt64(value);
    } else if (value is String) {
      bytes.addByte(_msString);
      _writeString(value);
    } else {
      throw StateError('Unexpected type ${value.runtimeType} while encoding blob.');
    }
  }

  void _writeValue(Object? value, void Function(Object? value) recurse) {
    if (value == false) {
      bytes.addByte(_msFalse);
    } else if (value == true) {
      bytes.addByte(_msTrue);
    } else if (value is double) {
      bytes.addByte(_msBinary64);
      _scratchIn.setFloat64(0, value, _blobEndian);
      bytes.add(_scratchOut);
    } else if (value is DynamicList) {
      bytes.addByte(_msList);
      _writeInt64(value.length);
      value.forEach(recurse);
    } else if (value is DynamicMap) {
      bytes.addByte(_msMap);
      _writeMap(value, recurse);
    } else {
      _writePart(value);
    }
  }

  void writeValue(Object? value) {
    _writeValue(value, writeValue);
  }

  void _writeArgument(Object? value) {
    if (value is Loop) {
      bytes.addByte(_msLoop);
      _writeArgument(value.input);
      _writeArgument(value.output);
    } else if (value is ConstructorCall) {
      bytes.addByte(_msWidget);
      _writeString(value.name);
      _writeMap(value.arguments, _writeArgument);
    } else if (value is ArgsReference) {
      bytes.addByte(_msArgsReference);
      _writeInt64(value.parts.length);
      value.parts.forEach(_writePart);
    } else if (value is DataReference) {
      bytes.addByte(_msDataReference);
      _writeInt64(value.parts.length);
      value.parts.forEach(_writePart);
    } else if (value is LoopReference) {
      bytes.addByte(_msLoopReference);
      _writeInt64(value.loop);
      _writeInt64(value.parts.length);
      value.parts.forEach(_writePart);
    } else if (value is StateReference) {
      bytes.addByte(_msStateReference);
      _writeInt64(value.parts.length);
      value.parts.forEach(_writePart);
    } else if (value is EventHandler) {
      bytes.addByte(_msEvent);
      _writeString(value.eventName);
      _writeMap(value.eventArguments, _writeArgument);
    } else if (value is Switch) {
      bytes.addByte(_msSwitch);
      _writeArgument(value.input);
      _writeInt64(value.outputs.length);
      value.outputs.forEach((Object? key, Object value) {
        if (key == null) {
          bytes.addByte(_msDefault);
        } else {
          _writeArgument(key);
        }
        _writeArgument(value);
      });
    } else if (value is SetStateHandler) {
      bytes.addByte(_msSetState);
      final StateReference reference = value.stateReference as StateReference;
      _writeInt64(reference.parts.length);
      reference.parts.forEach(_writePart);
      _writeArgument(value.value);
    } else {
      assert(value is! BlobNode);
      _writeValue(value, _writeArgument);
    }
  }

  void _writeDeclarationList(List<WidgetDeclaration> value) {
    _writeInt64(value.length);
    for (final WidgetDeclaration declaration in value) {
      _writeString(declaration.name);
      if (declaration.initialState != null) {
        _writeMap(declaration.initialState!, _writeArgument);
      } else {
        _writeInt64(0);
      }
      _writeArgument(declaration.root);
    }
  }

  void _writeImportList(List<Import> value) {
    _writeInt64(value.length);
    for (final Import import in value) {
      _writeInt64(import.name.parts.length);
      import.name.parts.forEach(_writeString);
    }
  }

  void writeLibrary(RemoteWidgetLibrary library) {
    _writeImportList(library.imports);
    _writeDeclarationList(library.widgets);
  }

  void writeSignature(List<int> signature) {
    assert(signature.length == 4);
    bytes.add(signature);
  }
}
