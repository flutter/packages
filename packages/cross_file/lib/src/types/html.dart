// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:html';
import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../web_helpers/web_helpers.dart';
import './base.dart';

/// A CrossFile that works on web.
///
/// It wraps the bytes of a selected file.
class XFile extends XFileBase {
  /// Construct a CrossFile object from its ObjectUrl.
  ///
  /// Optionally, this can be initialized with `bytes` and `length`
  /// so no http requests are performed to retrieve files later.
  ///
  /// `name` needs to be passed from the outside, since we only have
  /// access to it while we create the ObjectUrl.
  XFile(
    this.path, {
    this.mimeType,
    String? name,
    int? length,
    Uint8List? bytes,
    DateTime? lastModified,
    @visibleForTesting CrossFileTestOverrides? overrides,
  })  : _data = bytes,
        _length = length,
        _overrides = overrides,
        _lastModified = lastModified ?? DateTime.fromMillisecondsSinceEpoch(0),
        name = name ?? '',
        super(path);

  /// Construct an CrossFile from its data
  XFile.fromData(
    Uint8List bytes, {
    this.mimeType,
    String? name,
    int? length,
    DateTime? lastModified,
    String? path,
    @visibleForTesting CrossFileTestOverrides? overrides,
  })  : _data = bytes,
        _length = length,
        _overrides = overrides,
        _lastModified = lastModified ?? DateTime.fromMillisecondsSinceEpoch(0),
        name = name ?? '',
        super(path) {
    if (path == null) {
      final Blob blob = (mimeType == null)
          ? Blob(<dynamic>[bytes])
          : Blob(<dynamic>[bytes], mimeType);
      this.path = Url.createObjectUrl(blob);
    } else {
      this.path = path;
    }
  }

  @override
  final String? mimeType;
  @override
  final String name;
  @override
  late String path;

  final Uint8List? _data;
  final int? _length;
  final DateTime? _lastModified;

  late Element _target;

  final CrossFileTestOverrides? _overrides;

  bool get _hasTestOverrides => _overrides != null;

  @override
  Future<DateTime> lastModified() async =>
      Future<DateTime>.value(_lastModified);

  Future<Uint8List> get _bytes async {
    if (_data != null) {
      return Future<Uint8List>.value(UnmodifiableUint8ListView(_data!));
    }

    // We can force 'response' to be a byte buffer by passing responseType:
    final ByteBuffer? response =
        (await HttpRequest.request(path, responseType: 'arraybuffer')).response;

    return response?.asUint8List() ?? Uint8List(0);
  }

  @override
  Future<int> length() async => _length ?? (await _bytes).length;

  @override
  Future<String> readAsString({Encoding encoding = utf8}) async {
    return encoding.decode(await _bytes);
  }

  @override
  Future<Uint8List> readAsBytes() async =>
      Future<Uint8List>.value(await _bytes);

  @override
  Stream<Uint8List> openRead([int? start, int? end]) async* {
    final Uint8List bytes = await _bytes;
    yield bytes.sublist(start ?? 0, end ?? bytes.length);
  }

  /// Saves the data of this CrossFile at the location indicated by path.
  /// For the web implementation, the path variable is ignored.
  @override
  Future<void> saveTo(String path) async {
    // Create a DOM container where we can host the anchor.
    _target = ensureInitialized('__x_file_dom_element');

    // Create an <a> tag with the appropriate download attributes and click it
    // May be overridden with CrossFileTestOverrides
    final AnchorElement element = _hasTestOverrides
        ? _overrides!.createAnchorElement(this.path, name) as AnchorElement
        : createAnchorElement(this.path, name);

    // Clear the children in our container so we can add an element to click
    _target.children.clear();
    addElementToContainerAndClick(_target, element);
  }
}

/// Overrides some functions to allow testing
@visibleForTesting
class CrossFileTestOverrides {
  /// Default constructor for overrides
  CrossFileTestOverrides({required this.createAnchorElement});

  /// For overriding the creation of the file input element.
  Element Function(String href, String suggestedName) createAnchorElement;
}
