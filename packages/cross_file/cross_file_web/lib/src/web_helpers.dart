// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:js_interop';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:web/web.dart';

/// Create anchor element with download attribute
HTMLAnchorElement createAnchorElement(String href, String? suggestedName) =>
    (document.createElement('a') as HTMLAnchorElement)
      ..href = href
      ..download = suggestedName ?? 'download'
      ..rel = 'noreferrer';

/// Add an element to a container and click it
void addElementToContainerAndClick(Element container, HTMLElement element) {
  // Add the element and click it
  // All previous elements will be removed before adding the new one
  container.appendChild(element);
  element.click();
}

/// Initializes a DOM container where elements can be injected.
Element ensureInitialized(String id) {
  Element? target = document.querySelector('#$id');
  if (target == null) {
    final Element targetElement = document.createElement('flt-x-file')..id = id;

    document.body!.appendChild(targetElement);
    target = targetElement;
  }
  return target;
}

/// Attempts to download an object (a [Blob]) from its [objectUrl], suggesting [name] as the filename.
///
/// [name] is a mere *suggestion* for the saved filename; users usually can rename
/// the file to whatever they want before it's actually saved.
///
/// Maybe some day: https://developer.mozilla.org/en-US/docs/Web/API/Window/showSaveFilePicker
void downloadObjectUrl(
  String objectUrl,
  String? name, {
  XFileTestOverrides? testOverrides,
}) {
  // Create a DOM container where the anchor can be injected.
  final Element target = ensureInitialized('__x_file_dom_element');

  // Create an <a> tag with the appropriate download attributes and click it
  // May be overridden with CrossFileTestOverrides
  final HTMLAnchorElement element = testOverrides != null
      ? testOverrides.createAnchorElement(objectUrl, name) as HTMLAnchorElement
      : createAnchorElement(objectUrl, name);

  // Clear the children in target.
  target.replaceChildren(JSArray<JSAny?>());
  // Add the new `element` and click.
  addElementToContainerAndClick(target, element);
}

/// Converts a [Blob] to [Uint8List] through a [FileReader].
Future<Uint8List> blobToBytes(Blob blob) async {
  final reader = FileReader();
  reader.readAsArrayBuffer(blob);
  await reader.onLoadEnd.first;

  final Uint8List? result = (reader.result as JSArrayBuffer?)?.toDart
      .asUint8List();
  if (result == null) {
    throw Exception('Cannot read bytes from Blob. Is it still available?');
  }

  return result;
}

/// Converts a bunch of [bytes] into a [Blob] and an optional [mimeType].
Blob bytesToBlob(Uint8List bytes, String? mimeType) {
  return Blob(
    <JSUint8Array>[bytes.toJS].toJS,
    BlobPropertyBag(type: mimeType ?? ''),
  );
}

/// Retrieves a [Blob] by its [objectUrl].
Future<Blob> fetchBlob(String objectUrl) async {
  try {
    final Response response = await window.fetch(objectUrl.toJS).toDart;
    return response.blob().toDart;
  } catch (e) {
    throw Exception('Could not fetch Blob by URL: $objectUrl');
  }
}

/// Overrides some functions to allow testing.
// TODO(dit): https://github.com/flutter/flutter/issues/91400
// Move this to web_helpers_test.dart
class XFileTestOverrides {
  /// Default constructor for overrides
  XFileTestOverrides({required this.createAnchorElement});

  /// For overriding the creation of the file input element.
  Element Function(String href, String? suggestedName) createAnchorElement;
}
